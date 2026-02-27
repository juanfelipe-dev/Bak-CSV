import os
import csv
import tempfile
from flask import Flask, request, render_template, send_from_directory
import pyodbc

# configure your SQL Server connection
CONN_STR = (
    'DRIVER={SQL Server};'
    'SERVER=localhost;'
    'Trusted_Connection=yes;'
)

# create Flask application instance
app = Flask(__name__)

def restore_backup(bak_path, database_name):
    """Restore .bak file to the specified temporary database."""
    conn = pyodbc.connect(CONN_STR, autocommit=True)
    cursor = conn.cursor()
    # drop if exists
    cursor.execute(f"IF DB_ID('{database_name}') IS NOT NULL DROP DATABASE [{database_name}]")
    restore_sql = f"RESTORE DATABASE [{database_name}] FROM DISK = ? WITH REPLACE"
    cursor.execute(restore_sql, bak_path)
    conn.close()


def dump_tables_to_csv(database_name, out_dir):
    """Export all user tables in the restored database to CSV files."""
    conn = pyodbc.connect(CONN_STR + f";DATABASE={database_name}")
    cursor = conn.cursor()
    cursor.execute("SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'")
    for schema, table in cursor.fetchall():
        full = f"{schema}.{table}"
        filename = f"{schema}_{table}.csv"
        path = os.path.join(out_dir, filename)
        with open(path, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            cursor.execute(f"SELECT * FROM {full}")
            cols = [column[0] for column in cursor.description]
            writer.writerow(cols)
            for row in cursor:
                writer.writerow(row)
    conn.close()


@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        bak_file = request.files['backup']
        if not bak_file:
            return 'No file uploaded', 400
        tmp = tempfile.mkdtemp()
        bak_path = os.path.join(tmp, bak_file.filename)
        bak_file.save(bak_path)
        dbname = f"bakdump_{os.path.splitext(bak_file.filename)[0]}"
        restore_backup(bak_path, dbname)
        csv_dir = os.path.join(tmp, 'csvs')
        os.makedirs(csv_dir, exist_ok=True)
        dump_tables_to_csv(dbname, csv_dir)
        # offer link to files
        files = os.listdir(csv_dir)
        return render_template('results.html', files=files, tmpdir=tmp)
    return render_template('index.html')


@app.route('/download/<path:filename>')
def download(filename):
    # we assume tmpdir is stored in session or passed otherwise; for simplicity, parse from query string
    tmpdir = request.args.get('tmp', '')
    return send_from_directory(os.path.join(tmpdir, 'csvs'), filename, as_attachment=True)


if __name__ == '__main__':
    app.run(debug=True)

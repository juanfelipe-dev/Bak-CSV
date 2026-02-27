# BAK-CSV Exporter

A Flask-based web application that converts SQL Server `.bak` (backup) files to CSV exports of all tables.

## Features

- 📤 **Upload `.bak` files** via a web interface
- 🔄 **Restore backups** to a temporary database
- 📊 **Export all tables** to individual CSV files
- 💾 **Download CSVs** directly from the browser
- 🚀 **Production-ready** with Gunicorn WSGI server
- ☁️ **Render.com deployment** support

## Project Structure

```
.
├── export_bak.py              # Main Flask application
├── requirements.txt           # Python dependencies
├── run_start.sh              # Startup script for Render
├── create_sample_bak.ps1     # PowerShell script to generate test .bak file
├── templates/
│   ├── index.html            # Upload form
│   └── results.html          # CSV download links
└── README.md                 # This file
```

## Prerequisites

- **Python 3.7+**
- **SQL Server** (local or remote) with backup files
- **pip** (Python package manager)

## Local Installation

1. **Clone or download** this repository

2. **Create a virtual environment** (optional but recommended):
   ```bash
   python -m venv .venv
   .\.venv\Scripts\activate  # Windows
   # or
   source .venv/bin/activate # macOS/Linux
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure SQL Server connection** in `export_bak.py`:
   ```python
   CONN_STR = (
       'DRIVER={SQL Server};'
       'SERVER=your_server;'
       'Trusted_Connection=yes;'
   )
   ```
   - Replace `your_server` with your SQL Server instance name (e.g., `localhost` or `MACHINE_NAME\SQLEXPRESS`)
   - Use `Trusted_Connection=yes` for Windows Authentication
   - For SQL Authentication, use: `UID=username;PWD=password;`

## Usage

### Local Testing

1. **Start the Flask app**:
   ```bash
   python export_bak.py
   ```

2. **Open your browser** and navigate to:
   ```
   http://127.0.0.1:5000
   ```

3. **Upload a `.bak` file** and the app will:
   - Restore it to a temporary database
   - Extract all tables as CSV files
   - Provide download links

### Creating a Sample `.bak` File

If you need a test backup file:

1. **Run the sample creator** (PowerShell on Windows):
   ```powershell
   .\create_sample_bak.ps1
   ```
   This creates `sample_test.bak` with sample tables: Customers, Orders, Products

2. **Upload** `sample_test.bak` to the web interface to test the full workflow

## Deployment on Render

### Prerequisites
- GitHub account with repository
- Render.com account

### Steps

1. **Push code to GitHub**:
   ```bash
   git add .
   git commit -m "Initial commit"
   git push origin main
   ```

2. **Create a Web Service on Render**:
   - Go to [Render.com](https://render.com)
   - Click "New +" → "Web Service"
   - Connect your GitHub repository
   - Select branch (usually `main`)

3. **Configure the service**:
   - **Name**: `bak-csv-exporter` (or any name)
   - **Runtime**: Python 3
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `bash run_start.sh`
   - **Instance Type**: Free tier or higher

4. **Set environment variables** (if using remote SQL Server):
   In Render dashboard, add environment variables:
   ```
   CONN_STR='DRIVER={ODBC Driver 17 for SQL Server};SERVER=your_server;UID=user;PWD=pass;'
   ```

5. **Deploy** - Click "Create Web Service" and Render will automatically deploy

## Configuration Options

### SQL Server Connection

Edit the `CONN_STR` variable in `export_bak.py`:

**Windows Authentication (local)**:
```python
CONN_STR = 'DRIVER={SQL Server};SERVER=localhost;Trusted_Connection=yes;'
```

**SQL Authentication (remote)**:
```python
CONN_STR = 'DRIVER={ODBC Driver 17 for SQL Server};SERVER=server.database.windows.net;UID=username;PWD=password;'
```

**Named Instance**:
```python
CONN_STR = 'DRIVER={SQL Server};SERVER=MACHINE_NAME\SQLEXPRESS;Trusted_Connection=yes;'
```

### Security Notes

⚠️ **For production on Render**:
- Store sensitive connection strings in environment variables, not in code
- Use SQL Server firewall rules to restrict access
- Consider using Azure SQL Database with managed identities
- Never commit credentials to GitHub

## Troubleshooting

### "No open ports detected" Error on Render
✅ **Fixed** - Script now reads the `PORT` environment variable that Render provides

### "ODBC Driver not found"
- Install ODBC Driver 17 or 18 for SQL Server:
  - Windows: Download from [Microsoft](https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server)
  - Linux: `sudo apt-get install odbc-mssql-tools18`

### Database Restore Permission Denied
- Ensure the SQL Server service account has write permissions to the temp directory
- Run SQL Server Management Studio as Administrator

### Large .bak Files
- Free tier Render instances have limited memory (512MB)
- Consider using a paid Render plan for backups >1GB
- Alternatively, restore the backup outside the app and use CSV export only

## Dependencies

```
flask          - Web framework
pyodbc         - SQL Server connection
gunicorn       - Production WSGI server
```

## License

This project is provided as-is for internal use.

## Support

For issues:
1. Check that SQL Server is running and accessible
2. Verify the `.bak` file is valid (test with SQL Server Management Studio)
3. Ensure ODBC drivers are installed on your system
4. Check that the temp directory has sufficient disk space

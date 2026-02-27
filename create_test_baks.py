#!/usr/bin/env python3
"""
Generate sample .bak files for testing BAK-CSV exporter
This creates compressed mock backup files with CSV data
"""

import os
import zipfile
import csv
from pathlib import Path

project_dir = Path(__file__).parent

def create_sample_bak(filename, tables_data):
    """Create a mock .bak file (actually a zip with CSVs inside)"""
    bak_path = project_dir / filename
    
    with zipfile.ZipFile(bak_path, 'w', zipfile.ZIP_DEFLATED) as zf:
        for table_name, headers, rows in tables_data:
            # Write CSV content to file in zip
            csv_content = []
            csv_content.append(','.join(headers))
            for row in rows:
                csv_content.append(','.join(str(v) for v in row))
            
            csv_text = '\n'.join(csv_content)
            zf.writestr(f'{table_name}.csv', csv_text)
    
    print(f'✓ Created: {bak_path}')
    return str(bak_path)

# Sample 1: Customers Database
customers_data = [
    ('Customers', 
     ['CustomerID', 'FirstName', 'LastName', 'Email', 'Phone', 'CreatedDate'],
     [
        (1, 'John', 'Doe', 'john@example.com', '555-0101', '2024-01-15'),
        (2, 'Jane', 'Smith', 'jane@example.com', '555-0102', '2024-01-20'),
        (3, 'Bob', 'Johnson', 'bob@example.com', '555-0103', '2024-02-05'),
     ]),
    ('Orders',
     ['OrderID', 'CustomerID', 'OrderAmount', 'OrderStatus', 'OrderDate'],
     [
        (1, 1, 1500.00, 'Delivered', '2024-02-01'),
        (2, 2, 750.50, 'Shipped', '2024-02-10'),
        (3, 3, 2200.00, 'Processing', '2024-02-20'),
     ]),
    ('OrderItems',
     ['OrderItemID', 'OrderID', 'ProductName', 'Quantity', 'UnitPrice'],
     [
        (1, 1, 'Laptop', 1, 1200.00),
        (2, 1, 'Mouse', 1, 300.00),
        (3, 2, 'Monitor', 1, 750.50),
     ]),
]

# Sample 2: Inventory Database
inventory_data = [
    ('Products',
     ['ProductID', 'ProductCode', 'ProductName', 'Category', 'Price'],
     [
        (1, 'LP001', 'Laptop Pro', 'Electronics', 1299.99),
        (2, 'MN001', 'Monitor 27inch', 'Electronics', 399.99),
        (3, 'KB001', 'Mechanical Keyboard', 'Peripherals', 149.99),
     ]),
    ('Inventory',
     ['InventoryID', 'ProductID', 'WarehouseLocation', 'Quantity'],
     [
        (1, 1, 'A-1-1', 15),
        (2, 2, 'A-2-3', 32),
        (3, 3, 'B-1-2', 50),
     ]),
    ('Suppliers',
     ['SupplierID', 'SupplierName', 'ContactPerson', 'Email', 'Phone'],
     [
        (1, 'TechSupply Inc', 'Mike Johnson', 'mike@techsupply.com', '555-2001'),
        (2, 'Global Electronics', 'Sarah Lee', 'sarah@globelec.com', '555-2002'),
     ]),
]

if __name__ == '__main__':
    print("=" * 40)
    print("BAK-CSV Test File Generator (Python)")
    print("=" * 40)
    print()
    
    print("Creating sample_customers.bak...")
    create_sample_bak('sample_customers.bak', customers_data)
    
    print("Creating sample_inventory.bak...")
    create_sample_bak('sample_inventory.bak', inventory_data)
    
    print()
    print("=" * 40)
    print("SUCCESS: Both test backup files created!")
    print("=" * 40)

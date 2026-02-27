# PowerShell script to create 2 sample SQL Server .bak files
# Requires SQL Server to be installed and running locally

Write-Host "Checking for SqlServer module..." -ForegroundColor Yellow
if (-not (Get-Module -ListAvailable -Name SqlServer)) {
    Write-Host "Installing SqlServer module..." -ForegroundColor Yellow
    Install-Module -Name SqlServer -Force -AllowClobber -Scope CurrentUser
}

Import-Module SqlServer -ErrorAction SilentlyContinue

$ServerInstance = "localhost"
$Database1Name = "SampleDB_Customers"
$Database2Name = "SampleDB_Inventory"
$BackupPath1 = "$(Get-Location)\sample_customers.bak"
$BackupPath2 = "$(Get-Location)\sample_inventory.bak"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "BAK-CSV Test File Generator" -ForegroundColor Cyan
Write-Host "Creating 2 sample databases and backups" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Create first database: Customers DB
$sql1 = "
IF EXISTS(SELECT * FROM sys.databases WHERE name = 'SampleDB_Customers') 
BEGIN ALTER DATABASE [SampleDB_Customers] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [SampleDB_Customers]; END
CREATE DATABASE [SampleDB_Customers];
"
Invoke-SqlCmd -ServerInstance $ServerInstance -Query $sql1 -ErrorAction SilentlyContinue

$sql1_tables = "
USE [SampleDB_Customers];
CREATE TABLE Customers (CustomerID INT PRIMARY KEY IDENTITY(1,1), FirstName NVARCHAR(50), LastName NVARCHAR(50), Email NVARCHAR(100), Phone NVARCHAR(20), CreatedDate DATETIME DEFAULT GETDATE());
CREATE TABLE Orders (OrderID INT PRIMARY KEY IDENTITY(1,1), CustomerID INT, OrderAmount DECIMAL(10,2), OrderStatus NVARCHAR(20), OrderDate DATETIME DEFAULT GETDATE());
CREATE TABLE OrderItems (OrderItemID INT PRIMARY KEY IDENTITY(1,1), OrderID INT, ProductName NVARCHAR(100), Quantity INT, UnitPrice DECIMAL(10,2));
INSERT INTO Customers (FirstName, LastName, Email, Phone) VALUES ('John', 'Doe', 'john@example.com', '555-0101'), ('Jane', 'Smith', 'jane@example.com', '555-0102'), ('Bob', 'Johnson', 'bob@example.com', '555-0103');
INSERT INTO Orders (CustomerID, OrderAmount, OrderStatus) VALUES (1, 1500.00, 'Delivered'), (2, 750.50, 'Shipped'), (3, 2200.00, 'Processing');
INSERT INTO OrderItems (OrderID, ProductName, Quantity, UnitPrice) VALUES (1, 'Laptop', 1, 1200.00), (1, 'Mouse', 1, 300.00), (2, 'Monitor', 1, 750.50);
"


try {
    Write-Host "Creating Customers database..." -ForegroundColor Yellow
    Invoke-SqlCmd -ServerInstance $ServerInstance -Query $sql1 -ErrorAction Stop
    Invoke-SqlCmd -ServerInstance $ServerInstance -Query $sql1_tables -ErrorAction Stop
    Write-Host "Created successfully!" -ForegroundColor Green
    
    Write-Host "Backing up Customers database..." -ForegroundColor Yellow
    Invoke-SqlCmd -ServerInstance $ServerInstance -Query "BACKUP DATABASE [SampleDB_Customers] TO DISK = N'$BackupPath1' WITH FORMAT, INIT, NAME = 'Customers Backup', COMPRESSION;" -ErrorAction Stop
    Write-Host "Backup created: $BackupPath1" -ForegroundColor Green
    Write-Host ""

    Write-Host "Creating Inventory database..." -ForegroundColor Yellow
    $sql2 = "
IF EXISTS(SELECT * FROM sys.databases WHERE name = 'SampleDB_Inventory') 
BEGIN ALTER DATABASE [SampleDB_Inventory] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [SampleDB_Inventory]; END
CREATE DATABASE [SampleDB_Inventory];
"
    Invoke-SqlCmd -ServerInstance $ServerInstance -Query $sql2 -ErrorAction Stop
    
    $sql2_tables = "
USE [SampleDB_Inventory];
CREATE TABLE Products (ProductID INT PRIMARY KEY IDENTITY(1,1), ProductCode NVARCHAR(20), ProductName NVARCHAR(100), Category NVARCHAR(50), Price DECIMAL(10,2));
CREATE TABLE Inventory (InventoryID INT PRIMARY KEY IDENTITY(1,1), ProductID INT, WarehouseLocation NVARCHAR(50), Quantity INT);
CREATE TABLE Suppliers (SupplierID INT PRIMARY KEY IDENTITY(1,1), SupplierName NVARCHAR(100), ContactPerson NVARCHAR(50), Email NVARCHAR(100), Phone NVARCHAR(20));
INSERT INTO Products (ProductCode, ProductName, Category, Price) VALUES ('LP001', 'Laptop Pro', 'Electronics', 1299.99), ('MN001', 'Monitor 27inch', 'Electronics', 399.99), ('KB001', 'Mechanical Keyboard', 'Peripherals', 149.99);
INSERT INTO Inventory (ProductID, WarehouseLocation, Quantity) VALUES (1, 'A-1-1', 15), (2, 'A-2-3', 32), (3, 'B-1-2', 50);
INSERT INTO Suppliers (SupplierName, ContactPerson, Email, Phone) VALUES ('TechSupply Inc', 'Mike Johnson', 'mike@techsupply.com', '555-2001'), ('Global Electronics', 'Sarah Lee', 'sarah@globelec.com', '555-2002');
"
    Invoke-SqlCmd -ServerInstance $ServerInstance -Query $sql2_tables -ErrorAction Stop
    Write-Host "Created successfully!" -ForegroundColor Green
    
    Write-Host "Backing up Inventory database..." -ForegroundColor Yellow
    Invoke-SqlCmd -ServerInstance $ServerInstance -Query "BACKUP DATABASE [SampleDB_Inventory] TO DISK = N'$BackupPath2' WITH FORMAT, INIT, NAME = 'Inventory Backup', COMPRESSION;" -ErrorAction Stop
    Write-Host "Backup created: $BackupPath2" -ForegroundColor Green
    Write-Host ""

    Write-Host "========================================" -ForegroundColor Green
    Write-Host "SUCCESS: Both test backups created!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    Write-Host "Check that SQL Server is installed and running" -ForegroundColor Yellow
}

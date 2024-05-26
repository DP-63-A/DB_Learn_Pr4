CREATE TABLE staging_orders (
    order_id SERIAL PRIMARY KEY,
    customer_id VARCHAR(50),
    employee_id INT,
    order_date DATE,
    required_date DATE,
    shipped_date DATE,
    ship_via INT,
    freight DECIMAL,
    ship_name VARCHAR(50),
    ship_address VARCHAR(100),
    ship_city VARCHAR(50),
    ship_region VARCHAR(50),
    ship_postal_code VARCHAR(20),
    ship_country VARCHAR(50)
);

CREATE TABLE staging_order_details (
    order_id INT,
    product_id INT,
    unit_price DECIMAL,
    quantity INT,
    discount DECIMAL
);

CREATE TABLE staging_products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(50),
    supplier_id INT,
    category_id INT,
    quantity_per_unit VARCHAR(20),
    unit_price DECIMAL,
    units_in_stock INT,
    units_on_order INT,
    reorder_level INT,
    discontinued INT
);

CREATE TABLE staging_customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    company_name VARCHAR(50),
    contact_name VARCHAR(50),
    contact_title VARCHAR(50),
    address VARCHAR(100),
    city VARCHAR(50),
    region VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    phone VARCHAR(20),
    fax VARCHAR(20)
);

CREATE TABLE staging_employees (
    employee_id SERIAL PRIMARY KEY,
    last_name VARCHAR(50),
    first_name VARCHAR(50),
    title VARCHAR(50),
    title_of_courtesy VARCHAR(50),
    birth_date DATE,
    hire_date DATE,
    address VARCHAR(100),
    city VARCHAR(50),
    region VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    home_phone VARCHAR(20),
    extension VARCHAR(10),
    photo BYTEA,
    notes TEXT,
    reports_to INT,
	photo_path VARCHAR(255)
);

CREATE TABLE staging_categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(50),
    description TEXT,
    picture BYTEA
);

CREATE TABLE staging_shippers (
    shipper_id SERIAL PRIMARY KEY,
    company_name VARCHAR(50),
    phone VARCHAR(20)
);

CREATE TABLE staging_suppliers (
    supplier_id SERIAL PRIMARY KEY,
    company_name VARCHAR(50),
    contact_name VARCHAR(50),
    contact_title VARCHAR(50),
    address VARCHAR(100),
    city VARCHAR(50),
    region VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    phone VARCHAR(20),
    fax VARCHAR(20),
    home_page TEXT
);



CREATE TABLE dim_customers (
    customer_id INT PRIMARY KEY,
    company_name VARCHAR(50),
    contact_name VARCHAR(50),
    contact_title VARCHAR(50),
    address VARCHAR(100),
    city VARCHAR(50),
    region VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    phone VARCHAR(20),
    fax VARCHAR(20)
);

CREATE TABLE dim_employees (
    employee_id INT PRIMARY KEY,
    last_name VARCHAR(50),
    first_name VARCHAR(50),
    title VARCHAR(50),
    title_of_courtesy VARCHAR(50),
    birth_date DATE,
    hire_date DATE,
    address VARCHAR(100),
    city VARCHAR(50),
    region VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    home_phone VARCHAR(20),
    extension VARCHAR(10),
    photo BYTEA,
    notes TEXT,
    reports_to INT
);

CREATE TABLE dim_products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    supplier_id INT,
    category_id INT,
    quantity_per_unit VARCHAR(20),
    unit_price DECIMAL,
    units_in_stock INT,
    units_on_order INT,
    reorder_level INT,
    discontinued BOOLEAN
);

CREATE TABLE dim_categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50),
    description TEXT,
    picture BYTEA
);

CREATE TABLE dim_shippers (
    shipper_id INT PRIMARY KEY,
    company_name VARCHAR(50),
    phone VARCHAR(20)
);

CREATE TABLE dim_suppliers (
    supplier_id INT PRIMARY KEY,
    company_name VARCHAR(50),
    contact_name VARCHAR(50),
    contact_title VARCHAR(50),
    address VARCHAR(100),
    city VARCHAR(50),
    region VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50),
    phone VARCHAR(20),
    fax VARCHAR(20),
    home_page TEXT
);



CREATE TABLE dim_date (
    date_id SERIAL PRIMARY KEY,
    date DATE,
    year INT,
    quarter INT,
    month INT,
    day INT,
    week INT,
    weekday INT,
    is_holiday BOOLEAN
);



CREATE TABLE fact_sales (
    sales_id SERIAL PRIMARY KEY,
    date_id INT,
    customer_id INT,
    product_id INT,
    employee_id INT,
    category_id INT,
    shipper_id INT,
    supplier_id INT,
    quantity_sold INT,
    unit_price DECIMAL,
    discount DECIMAL,
    total_amount DECIMAL GENERATED ALWAYS AS (quantity_sold * unit_price - discount) STORED,
    tax_amount DECIMAL,
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id),
    FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES dim_products(product_id),
    FOREIGN KEY (employee_id) REFERENCES dim_employees(employee_id),
    FOREIGN KEY (category_id) REFERENCES dim_categories(category_id),
    FOREIGN KEY (shipper_id) REFERENCES dim_shippers(shipper_id),
    FOREIGN KEY (supplier_id) REFERENCES dim_suppliers(supplier_id)
);



INSERT INTO staging_customers 
SELECT * FROM Customer;

INSERT INTO staging_categories 
SELECT * FROM Category;

INSERT INTO staging_order_details
SELECT * FROM orderdetail;

INSERT INTO staging_products
SELECT * FROM product;

INSERT INTO staging_shippers
SELECT * FROM shipper;

INSERT INTO staging_suppliers
SELECT * FROM supplier;

INSERT INTO staging_employees
SELECT * FROM employee;

INSERT INTO staging_orders
SELECT * FROM salesorder ;


INSERT INTO staging_employees
SELECT * FROM employee ;



INSERT INTO DimProduct (ProductID, ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock)
SELECT ProductID, ProductName, SupplierID, CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock
FROM staging_products;

INSERT INTO DimCustomer (CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone) 
SELECT custid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone 
FROM staging_customers;

INSERT INTO DimCategory (CategoryID, CategoryName, Description)
SELECT categoryid, categoryname, description
FROM staging_categories;

INSERT INTO DimEmployee (EmployeeID, LastName, FirstName, Title, BirthDate, HireDate, Address, City, Region, PostalCode, Country, HomePhone, Extension)
SELECT empid, lastname, firstname, title, birthdate, hiredate, address, city, region, postalcode, country, phone, extension
FROM staging_employees;

INSERT INTO DimShipper (ShipperID, CompanyName, Phone)
SELECT shipperid, companyname, phone
FROM staging_shippers;

INSERT INTO DimSupplier (SupplierID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone)
SELECT supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone
FROM staging_suppliers;

INSERT INTO DimDate (Date, Day, Month, Year, Quarter, WeekOfYear)
SELECT DISTINCT
    DATE(orderdate) AS Date,
    EXTRACT(DAY FROM DATE(orderdate)) AS Day,
    EXTRACT(MONTH FROM DATE(orderdate)) AS Month,
    EXTRACT(YEAR FROM DATE(orderdate)) AS Year,
    EXTRACT(QUARTER FROM DATE(orderdate)) AS Quarter,
    EXTRACT(WEEK FROM DATE(orderdate)) AS WeekOfYear
FROM staging_orders;



INSERT INTO FactSales (DateID, CustomerID, ProductID, EmployeeID, CategoryID, ShipperID, SupplierID, QuantitySold, UnitPrice, Discount, TotalAmount, TaxAmount) 
SELECT
    d.DateID,   
    c.custid,  
    p.ProductID,  
    e.empid,  
    cat.CategoryID,  
    s.ShipperID,  
    sup.SupplierID, 
    od.qty, 
    od.UnitPrice, 
    od.Discount,    
    (od.qty * od.UnitPrice - od.Discount) AS TotalAmount,
    (od.qty * od.UnitPrice - od.Discount) * 0.1 AS TaxAmount     
FROM staging_order_details od 
JOIN staging_orders o ON od.OrderID = o.OrderID 
JOIN staging_customers c ON o.custid = c.custid::varchar 
JOIN staging_products p ON od.ProductID = p.ProductID  
LEFT JOIN staging_employees e ON o.empid = e.empid  
LEFT JOIN staging_categories cat ON p.CategoryID = cat.CategoryID 
LEFT JOIN staging_shippers s ON o.shipperid = s.ShipperID  
LEFT JOIN staging_suppliers sup ON p.SupplierID = sup.SupplierID
LEFT JOIN DimDate d ON o.orderdate = d.Date;

SELECT * FROM FactSales;



SELECT 'DimDate' AS Table_Name, COUNT(*) AS Record_Count FROM DimDate
UNION ALL
SELECT 'DimCustomer', COUNT(*) FROM DimCustomer
UNION ALL
SELECT 'DimProduct', COUNT(*) FROM DimProduct
UNION ALL
SELECT 'DimEmployee', COUNT(*) FROM DimEmployee
UNION ALL
SELECT 'DimCategory', COUNT(*) FROM DimCategory
UNION ALL
SELECT 'DimShipper', COUNT(*) FROM DimShipper
UNION ALL
SELECT 'DimSupplier', COUNT(*) FROM DimSupplier
UNION ALL
SELECT 'FactSales', COUNT(*) FROM FactSales
UNION ALL
SELECT 'staging_customers', COUNT(*) FROM staging_customers
UNION ALL
SELECT 'staging_products', COUNT(*) FROM staging_products
UNION ALL
SELECT 'staging_categories', COUNT(*) FROM staging_categories
UNION ALL
SELECT 'staging_employees', COUNT(*) FROM staging_employees
UNION ALL
SELECT 'staging_shippers', COUNT(*) FROM staging_shippers
UNION ALL
SELECT 'staging_suppliers', COUNT(*) FROM staging_suppliers
UNION ALL
SELECT 'staging_order_details', COUNT(*) FROM staging_order_details
UNION ALL
SELECT 'staging_orders_unique_orderdates', COUNT(DISTINCT orderdate) FROM staging_orders;

SELECT COUNT(*) AS Broken_Record_Count 
FROM FactSales 
WHERE DateID NOT IN (SELECT DateID FROM DimDate)
   OR CustomerID NOT IN (SELECT CustomerID FROM DimCustomer)
   OR ProductID NOT IN (SELECT ProductID FROM DimProduct)
   OR EmployeeID NOT IN (SELECT EmployeeID FROM DimEmployee)
   OR CategoryID NOT IN (SELECT CategoryID FROM DimCategory)
   OR ShipperID NOT IN (SELECT ShipperID FROM DimShipper)
   OR SupplierID NOT IN (SELECT SupplierID FROM DimSupplier);



SELECT 
    p.ProductID,
    p.ProductName,
    c.CategoryName,
    COUNT(*) AS NumTransactions,
    SUM(fs.TotalAmount) AS TotalSales,
    SUM(fs.TaxAmount) AS TotalTax
FROM 
    FactSales fs
JOIN 
    DimProduct p ON fs.ProductID = p.ProductID
JOIN 
    DimCategory c ON fs.CategoryID = c.CategoryID
GROUP BY 
    p.ProductID, p.ProductName, c.CategoryName
ORDER BY 
    NumTransactions ASC, TotalSales ASC, TotalTax ASC
LIMIT 5;



SELECT
    c.CustomerID,
    c.ContactName,
    c.Region,
    c.Country,
    COUNT(fs.SalesID) AS TotalTransactions,
    SUM(fs.TotalAmount) AS TotalPurchaseAmount
FROM
    FactSales fs
JOIN
    DimCustomer c ON fs.CustomerID = c.CustomerID
GROUP BY
    c.CustomerID,
    c.ContactName,
    c.Region,
    c.Country
ORDER BY
    TotalTransactions ASC,
    TotalPurchaseAmount ASC
LIMIT 5;



SELECT 
    Month,
    SUM(TotalAmount) AS TotalSalesAmount,
    SUM(QuantitySold) AS TotalQuantitySold
FROM 
    FactSales
JOIN 
    DimDate ON FactSales.DateID = DimDate.DateID
WHERE 
    Day BETWEEN 1 AND 7
GROUP BY 
    Month
ORDER BY 
    Month;



SELECT 
    DP.CategoryID,
    DC.CategoryName,
    EXTRACT(WEEK FROM DD.Date) AS Week,
    EXTRACT(MONTH FROM DD.Date) AS Month,
    SUM(FS.QuantitySold) AS WeeklyQuantitySold,
    SUM(FS.TotalAmount) AS WeeklyTotalAmount,
    SUM(SUM(FS.TotalAmount)) OVER (PARTITION BY EXTRACT(MONTH FROM DD.Date)) AS MonthlyTotalAmount
FROM 
    FactSales FS
JOIN 
    DimDate DD ON FS.DateID = DD.DateID
JOIN 
    DimProduct DP ON FS.ProductID = DP.ProductID
JOIN 
    DimCategory DC ON DP.CategoryID = DC.CategoryID
GROUP BY 
    DP.CategoryID, DC.CategoryName, EXTRACT(WEEK FROM DD.Date), EXTRACT(MONTH FROM DD.Date)
ORDER BY 
    EXTRACT(MONTH FROM DD.Date), EXTRACT(WEEK FROM DD.Date), DP.CategoryID;



SELECT 
    DP.CategoryID,
    DC.CategoryName,
    SUM(FS.QuantitySold) AS TotalQuantitySold
FROM 
    FactSales FS
JOIN 
    DimProduct DP ON FS.ProductID = DP.ProductID
JOIN 
    DimCategory DC ON DP.CategoryID = DC.CategoryID
GROUP BY 
    DP.CategoryID, DC.CategoryName
ORDER BY 
    TotalQuantitySold DESC;



SELECT
    EXTRACT(month FROM d.Date) AS Month,
    p.CategoryID AS productcategory,
    c.Country,
    FLOOR(AVG(fs.TotalAmount)) AS MonthlySales
FROM
    FactSales fs
JOIN
    DimProduct p ON fs.ProductID = p.ProductID
JOIN
    DimCustomer c ON fs.CustomerID = c.CustomerID
JOIN
    DimDate d ON fs.DateID = d.DateID
GROUP BY
    EXTRACT(month FROM d.Date),
    p.CategoryID,
    c.Country
ORDER BY
    Month ASC;

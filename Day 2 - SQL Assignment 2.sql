-- 1
SELECT COUNT(ProductID) ProductCount
FROM Production.Product;

-- 2
SELECT COUNT(ProductID) ProductCount
FROM Production.Product 
WHERE ProductSubcategoryID IS NOT NULL;

-- 3
SELECT
	ProductSubcategoryID,
	COUNT(ProductID) CountedProducts
FROM Production.Product
WHERE ProductSubcategoryID IS NOT NULL
GROUP BY ProductSubcategoryID;

-- 4
SELECT
	ProductSubcategoryID,
	COUNT(ProductID) CountedProducts
FROM Production.Product
WHERE ProductSubcategoryID IS NULL
GROUP BY ProductSubcategoryID;

-- 5
SELECT 
	ProductID, 
	SUM(Quantity) Quantity 
FROM Production.ProductInventory 
GROUP BY ProductID;

-- 6
SELECT 
	ProductID, 
	SUM(Quantity) Quantity
FROM Production.ProductInventory
WHERE 
	LocationID = 40
	AND Quantity < 100
GROUP BY ProductID;

-- 7
SELECT
	Shelf,
	ProductID,
	SUM(Quantity) TheSum
FROM Production.ProductInventory
WHERE 
	LocationID = 40
	AND Quantity < 100
GROUP BY Shelf, ProductID;

-- 8 
SELECT
	LocationID,
	AVG(Quantity) AverageQuantity
FROM Production.ProductInventory
WHERE 
	LocationID = 10
GROUP BY LocationID;

-- 9
SELECT
	ProductID,
	Shelf,
	AVG(Quantity) AverageQuantityPerShelf
FROM Production.ProductInventory
GROUP BY ProductID, Shelf;

-- 10
SELECT
	ProductID,
	Shelf,
	AVG(Quantity) AverageQuantityPerShelf
FROM Production.ProductInventory
WHERE Shelf NOT LIKE 'N/A'
GROUP BY ProductID, Shelf;

--11
SELECT
	Color,
	Class,
	COUNT(ProductID) TheCount,
	AVG(ListPrice) AvgPrice
FROM Production.Product
WHERE
	Color IS NOT NULL
	AND CLASS IS NOT NULL
GROUP BY Color, Class;

-- 12
SELECT 
	cr.Name Country,
	sp.Name Province
FROM Person.StateProvince sp
LEFT JOIN Person.CountryRegion cr
ON sp.CountryRegionCode = cr.CountryRegionCode;

-- 13
SELECT 
	cr.Name Country,
	sp.Name Province
FROM Person.StateProvince sp
LEFT JOIN Person.CountryRegion cr
ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name in ('Germany', 'Canada')
ORDER BY Country, Province;

-- 14
SELECT
	DISTINCT p.ProductName
FROM Orders o
JOIN [Order Details] od
ON o.OrderID = od.OrderID
JOIN Products p
ON p.ProductID = od.ProductID
-- Had to use 30, 27 returned no data
WHERE o.OrderDate >= DATEADD(YEAR, -30, GETDATE());

-- 15
SELECT 
	*
FROM (
	SELECT
		o.ShipPostalCode,
		SUM(od.Quantity) TotalProductsSold,
		DENSE_RANK() OVER (ORDER BY SUM(od.Quantity) DESC) rnk
	FROM Orders o
	JOIN [Order Details] od
	ON o.OrderID = od.OrderID
	GROUP BY o.ShipPostalCode

) dt
WHERE rnk <= 5
ORDER BY TotalProductsSold DESC;

-- 16
SELECT 
	*
FROM (
	SELECT
		o.ShipPostalCode,
		SUM(od.Quantity) TotalProductsSold,
		DENSE_RANK() OVER (ORDER BY SUM(od.Quantity) DESC) rnk
	FROM Orders o
	JOIN [Order Details] od
	ON o.OrderID = od.OrderID
	-- Had to use 30, 27 returned no data
	WHERE o.OrderDate >= DATEADD(YEAR, -30, GETDATE())
	GROUP BY o.ShipPostalCode

) dt
WHERE rnk <= 5
ORDER BY TotalProductsSold DESC;

-- 17
SELECT
	City,
	COUNT(CustomerID) CustomerCount
FROM Customers
GROUP BY City;

-- 18
SELECT
	City,
	COUNT(CustomerID) CustomerCount
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) > 2;

-- 19
SELECT
	DISTINCT c.CompanyName
FROM Customers c
RIGHT JOIN Orders o
ON o.CustomerID = c.CustomerID
WHERE o.OrderDate >= '1998-01-01';

-- 20
SELECT
	c.CompanyName,
	MAX(o.OrderDate) MostRecentOrder
FROM Customers c
JOIN Orders o
ON o.CustomerID = c.CustomerID
GROUP BY c.CompanyName;

-- 21
SELECT
	c.CompanyName,
	SUM(od.quantity) CountOfProductsBought
FROM Customers c
JOIN Orders o
on C.CustomerID = o.CustomerID
JOIN [Order Details] od
on od.OrderID = o.OrderID
GROUP BY c.CompanyName;

-- 22
SELECT
	o.customerID
FROM Orders o
JOIN [Order Details] od
on od.OrderID = o.OrderID
GROUP BY o.CustomerID
HAVING SUM(od.quantity) > 100;

-- 23
SELECT DISTINCT
	s.CompanyName 'Supplier Company Name',
	sh.CompanyName 'Shipper Company Name'
FROM Suppliers s
JOIN Products p ON s.SupplierID = p.SupplierID
JOIN [Order Details] od ON p.ProductID = od.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
JOIN Shippers sh ON o.ShipVia = sh.ShipperID
ORDER BY s.CompanyName;

-- 24
SELECT DISTINCT
	o.OrderDate,
	p.ProductName
FROM Orders o
JOIN [Order Details] od on o.OrderID = od.OrderID
JOIN Products p on od.ProductID = p.ProductID
ORDER BY o.OrderDate;

-- 25
SELECT
	CONCAT(e1.FirstName, ' ', e1.LastName) emp1,
	CONCAT(e2.FirstName, ' ', e2.LastName) emp2
FROM Employees e1
JOIN Employees e2 
ON e1.title = e2.title
	AND e1.EmployeeID > e2.EmployeeID;

-- 26
WITH CTEDirectReports AS (
SELECT
	e1.employeeID
FROM Employees e1
LEFT JOIN Employees e2 ON e1.EmployeeID = e2.ReportsTo
GROUP BY e1.EmployeeID
HAVING COUNT(e2.employeeID) > 2
)
SELECT 
	CONCAT(e1.FirstName, ' ', e1.LastName) Mngr
FROM CTEDirectReports
JOIN Employees e1 ON e1.EmployeeID = CTEDirectReports.EmployeeID;

-- 27
SELECT
	City,
	CompanyName,
	ContactName,
	'Customer' 'Type'
FROM Customers
UNION ALL
SELECT
	City,
	CompanyName,
	ContactName,
	'Supplier' 'Type'
FROM Suppliers
ORDER BY City, CompanyName;

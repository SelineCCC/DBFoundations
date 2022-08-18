--*************************************************************************--
-- Title: Assignment06
-- Author: SChen
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
-- 2022-08-17,SChen,Completed File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_SChen')
	 Begin 
	  Alter Database [Assignment06DB_SChen] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_SChen;
	 End
	Create Database Assignment06DB_SChen;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_SChen;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToproducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'
go

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
Create View vCategories
 With Schemabinding
 As
  Select [CategoryID], [CategoryName]
   From [dbo].[Categories];
go

Select CategoryID, CategoryName
 From vCategories;
go

Create View vProducts
 With Schemabinding
 As
  Select [ProductID], [ProductName], [CategoryID], [UnitPrice]
   From [dbo].[Products];
go

Select ProductID, ProductName, CategoryID, UnitPrice
 From vProducts;
go

Create View vInventories
 With Schemabinding
 As
  Select [InventoryID], [InventoryDate], [EmployeeID], [ProductID], [Count]
   From [dbo].[Inventories];
go

Select InventoryID, InventoryDate, EmployeeID, ProductID, [Count]
 From vInventories;
go

Create View vEmployees
 With Schemabinding
 As
  Select [EmployeeID], [EmployeeFirstName], [EmployeeLastName], [ManagerID]
   From [dbo].[Employees];
go

Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
 From vEmployees;
go

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
Deny Select On [dbo].[Categories] to Public;
Deny Select On [dbo].[Products] to Public;
Deny Select On [dbo].[Inventories] to Public;
Deny Select On [dbo].[Employees] to Public;

Grant Select On [dbo].[vCategories] to Public;
Grant Select On [dbo].[vProducts] to Public;
Grant Select On [dbo].[vInventories] to Public;
Grant Select On [dbo].[vEmployees] to Public;
go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00
Create View vProductsByCategories
 With Schemabinding
 As
  Select Top 1000000000
  [CategoryName], [ProductName], [UnitPrice] 
   From [dbo].[Products] as p Join [dbo].[Categories] as c
	On p.CategoryID = c.CategoryID
	 Order By CategoryName, ProductName;
go

Select CategoryName, ProductName, UnitPrice
 From vProductsByCategories;
go

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33
Create View vInventoriesByProductsByDates
 With Schemabinding
 As
 Select Top 1000000000
 [ProductName], [InventoryDate], [Count]
   From [dbo].[Products] as p Inner Join [dbo].[Inventories] as i
	On p.ProductID = i.ProductID
	 Order By ProductName, InventoryDate, [Count];
go

Select ProductName, InventoryDate, [Count]
 From vInventoriesByProductsByDates;
go

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth
Create View vInventoriesByEmployeesByDates
 With Schemabinding
 As
 Select Distinct
 Top 1000000000
 [InventoryDate], [EmployeeFirstName] + ' ' + [EmployeeLastName] AS EmployeeName
   From [dbo].Inventories as i Join [dbo].Employees as e
	On i.EmployeeID = e.EmployeeID
	 Order By InventoryDate;
go

Select InventoryDate, EmployeeName
 From vInventoriesByEmployeesByDates;
go


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37
Create View vInventoriesByProductsByCategories
 With Schemabinding
 As
 Select Top 1000000000
  [CategoryName], [ProductName], [InventoryDate], [Count]
   From [dbo].Products as p
   Inner Join [dbo].Inventories as i
	On p.ProductID = i.ProductID
   Inner Join [dbo].Categories as c
    On p.CategoryID = c.CategoryID
	 Order By CategoryName, ProductName, InventoryDate, [Count];
go

Select CategoryName, ProductName, InventoryDate, [Count]
 From vInventoriesByProductsByCategories;
go


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  C�te de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaran� Fant�stica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalik��ri	      2017-01-01	  57	  Steven Buchanan
Create View vInventoriesByProductsByEmployees
 With Schemabinding
 As
 Select Top 1000000000
  [CategoryName], [ProductName], [InventoryDate], [Count], 
  [EmployeeFirstName] + ' ' + [EmployeeLastName] AS EmployeeName
   From [dbo].Products as p
   Inner Join [dbo].Inventories as i
	On p.ProductID = i.ProductID
   Inner Join [dbo].Categories as c
    On p.CategoryID = c.CategoryID
   Inner Join [dbo].Employees as e
    On e.EmployeeID = i.EmployeeID
	 Order By InventoryDate, CategoryName, ProductName, EmployeeName;
go

Select InventoryDate, CategoryName, ProductName, EmployeeName
 From vInventoriesByProductsByEmployees;
go


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth
Create View vInventoriesForChaiAndChangByEmployees
 With Schemabinding
 As
 Select Top 1000000000
  [CategoryName], [ProductName], [InventoryDate], [Count], 
  [EmployeeFirstName] + ' ' + [EmployeeLastName] AS EmployeeName
   From [dbo].Products as p
   Inner Join [dbo].Inventories as i
	On p.ProductID = i.ProductID
   Inner Join [dbo].Employees as e
    On e.EmployeeID = i.EmployeeID
   Inner Join [dbo].Categories as c
    On p.CategoryID = c.CategoryID
    Where p.ProductID in (Select ProductID
                        From [dbo].Products
					    Where ProductName = 'Chai' Or ProductName = 'Chang')
	  Order By CategoryName, ProductName, InventoryDate, [Count], EmployeeName;
go

Select InventoryDate, CategoryName, ProductName, EmployeeName
 From vInventoriesForChaiAndChangByEmployees;
go

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here are teh rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King
Create View vEmployeesByManager
 With Schemabinding
 As
 Select Top 1000000000
 mgr.EmployeeFirstName + ' ' + mgr.EmployeeLastName AS Manager, 
 emp.EmployeeFirstName + ' ' + emp.EmployeeLastName AS Employee
  FROM [dbo].Employees as emp
   Inner Join [dbo].Employees as mgr
    On mgr.EmployeeID = emp.ManagerID
     Order By Manager, Employee;
go

Select Manager, Employee
 From vEmployeesByManager;
go

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth
Create View vInventoriesByProductsByCategoriesByEmployees
 With Schemabinding
 As
 Select Top 1000000000
  c.[CategoryID], [CategoryName], p.[ProductID], [ProductName], 
  [UnitPrice], i.[InventoryID], [InventoryDate], [Count], i.[EmployeeID], 
  emp.EmployeeFirstName + ' ' + emp.EmployeeLastName AS Employee, 
  mgr.EmployeeFirstName + ' ' + mgr.EmployeeLastName AS Manager
  FROM [dbo].Employees as emp
   Inner Join [dbo].Employees as mgr
    On mgr.EmployeeID = emp.ManagerID
   Inner Join [dbo].Inventories as i
    On i.EmployeeID = emp.EmployeeID
   Inner Join [dbo].Products as p
    On i.ProductID = p.ProductID
   Inner Join [dbo].Categories as c
    On p.CategoryID = c.CategoryID
	 Order By CategoryName, ProductName, InventoryID, Employee;
go

Select InventoryDate, CategoryName, ProductName, EmployeeName
 From vInventoriesByProductsByEmployees;
go

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/
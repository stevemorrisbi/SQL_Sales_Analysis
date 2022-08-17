-- Rounding Item Price and Total Sales
-- Extracting just the date from the date + timestamp
-- Turning query into a CTE. Using window functions on cleaned CTE query
-- Percentage of grand total calculatde for each Customers contribution to Sales Grand Total
-- Sales running total calculated using the Order Date 
-- Previous Order Difference calculated as a rolling total - Could be developed further.
-- Running totals added for month to date and year to date

WITH Sales_cte
AS
(
SELECT CUSTOMERNAME Customer_Name
		, ROUND(PRICEEACH,2) Item_Price
		, ROUND(SALES, 2) Total_Sales
		, QUANTITYORDERED Quantity_Ordered
		, CONVERT(date,ORDERDATE) Order_Date
FROM [dbo].[sales]
)
SELECT *
	, SUM(Item_Price) OVER (PARTITION BY Order_Date) AS Sales_By_Date
	, COUNT(Item_Price) OVER (PARTITION BY Customer_Name) AS Lifetime_Orders_by_Customer 
	, SUM(Item_Price) OVER (PARTITION BY Order_Date, Customer_Name ) AS Daily_Customer_Sales
	, SUM(Item_Price) OVER (PARTITION BY Customer_Name) AS Customer_Sales_Total
	, SUM(Item_Price) OVER() AS Sales_Grand_Total
	, ROUND(100.00 * SUM(Item_Price) OVER (PARTITION BY Customer_Name) / SUM(Item_Price) OVER() ,2) AS Pecentage_of_Total
	, ROUND(SUM(Total_Sales) OVER (ORDER BY Order_Date),2) AS Sales_Running_Total
	, ROUND(Total_Sales - LAG(Total_Sales, 1) OVER (ORDER BY Customer_Name),2) as Prev_Order_Difference
	, SUM(Item_Price) OVER (PARTITION BY year(Order_Date), month(Order_Date)) AS Sales_Month_to_Date
	, SUM(Item_Price) OVER (PARTITION BY year(Order_Date)) AS Sales_Year_to_Date
FROM Sales_cte


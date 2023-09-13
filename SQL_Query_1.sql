WITH QuarterlySales AS (
    SELECT 
        si.[Stock Item] AS ProductName,
        SUM(o.[Quantity]) AS SalesQuantity,
        SUM(o.[Quantity] * o.[Unit Price]) AS SalesRevenue,
        CASE 
            WHEN d.[Calendar Month Number] IN (1,2,3) THEN 1
            WHEN d.[Calendar Month Number] IN (4,5,6) THEN 2
            WHEN d.[Calendar Month Number] IN (7,8,9) THEN 3
            ELSE 4
        END AS Quarter,
        d.[Calendar Year] AS Year
    FROM [Fact].[Order] o
    JOIN [Dimension].[Stock Item] si ON o.[Stock Item Key] = si.[Stock Item Key]
    JOIN [Dimension].[Date] d ON o.[Order Date Key] = d.[Date]
    GROUP BY si.[Stock Item], 
        CASE 
            WHEN d.[Calendar Month Number] IN (1,2,3) THEN 1
            WHEN d.[Calendar Month Number] IN (4,5,6) THEN 2
            WHEN d.[Calendar Month Number] IN (7,8,9) THEN 3
            ELSE 4
        END,
        d.[Calendar Year]
)

SELECT 
    ProductName,
    SalesQuantity,
    SalesRevenue,
    Quarter,
    Year
FROM (
    SELECT 
        ProductName, 
        SalesQuantity, 
        SalesRevenue, 
        Quarter, 
        Year,
        ROW_NUMBER() OVER(PARTITION BY Quarter, Year ORDER BY SalesRevenue DESC) AS rn
    FROM QuarterlySales
) AS RankedSales
WHERE rn <= 10
ORDER BY Year, Quarter, rn;

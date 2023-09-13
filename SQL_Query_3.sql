WITH TotalSales AS (
    SELECT
        DATEPART(QUARTER, d.[Date]) AS [Quarter],
        d.[Calendar Year] AS [Year],
        SUM(f.[Total Including Tax]) AS TotalRevenue,
        SUM(f.[Quantity]) AS TotalQuantity
    FROM [Fact].[Order] f
    JOIN [Dimension].[Date] d ON f.[Order Date Key] = d.[Date]
    GROUP BY DATEPART(QUARTER, d.[Date]), d.[Calendar Year]
)

, CustomerSales AS (
    SELECT
        c.[Customer],
        DATEPART(QUARTER, d.[Date]) AS [Quarter],
        d.[Calendar Year] AS [Year],
        SUM(f.[Total Including Tax]) AS CustomerRevenue,
        SUM(f.[Quantity]) AS CustomerQuantity
    FROM [Fact].[Order] f
    JOIN [Dimension].[Date] d ON f.[Order Date Key] = d.[Date]
    JOIN [Dimension].[Customer] c ON f.[Customer Key] = c.[Customer Key]
    GROUP BY c.[Customer], DATEPART(QUARTER, d.[Date]), d.[Calendar Year]
)

SELECT 
    cs.[Customer] AS [CustomerName],
    (CAST(cs.CustomerRevenue AS float) / CAST(ts.TotalRevenue AS float)) * 100 AS [TotalRevenuePercentage],
    (CAST(cs.CustomerQuantity AS float) / CAST(ts.TotalQuantity AS float)) * 100 AS [TotalQuantityPercentage],
    cs.[Quarter],
    cs.[Year]
FROM CustomerSales cs
JOIN TotalSales ts ON cs.[Quarter] = ts.[Quarter] AND cs.[Year] = ts.[Year]
ORDER BY cs.[Year], cs.[Quarter], [TotalRevenuePercentage] DESC;

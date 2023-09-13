WITH QuarterlySales AS (
    SELECT 
        o.[Stock Item Key],
        si.[Stock Item] AS ProductName,
        DATEPART(QUARTER, d.[Date]) AS CurrentQuarter,
        d.[Calendar Year] AS CurrentYear,
        SUM(o.[Total Including Tax]) AS Revenue,
        SUM(o.[Quantity]) AS Quantity
    FROM [Fact].[Order] o
    JOIN [Dimension].[Stock Item] si ON si.[Stock Item Key] = o.[Stock Item Key]
    JOIN [Dimension].[Date] d ON d.[Date] = o.[Order Date Key]
    GROUP BY o.[Stock Item Key], si.[Stock Item], DATEPART(QUARTER, d.[Date]), d.[Calendar Year]

)

SELECT 
    cur.ProductName,
	cur.Revenue AS CurrentRevenue,
	cur.Quantity AS CurrentQty,
	prev.Revenue AS PreviousRevenue,
	prev.Quantity AS PreviousQty,
  CASE 
    WHEN ISNULL(prev.Revenue, 0) = 0 THEN NULL
    ELSE (100.0 * (cur.Revenue - ISNULL(prev.Revenue, 0))) / prev.Revenue
END AS GrowthRevenueRate,
CASE 
    WHEN ISNULL(prev.Quantity, 0) = 0 THEN NULL
    ELSE (100.0 * (cur.Quantity - ISNULL(prev.Quantity, 0))) / prev.Quantity
END AS GrowthQuantityRate,


    cur.CurrentQuarter,
    cur.CurrentYear,
    CASE 
        WHEN cur.CurrentQuarter = 1 THEN 4
        ELSE cur.CurrentQuarter - 1
    END AS PreviousQuarter,
    CASE 
        WHEN cur.CurrentQuarter = 1 THEN cur.CurrentYear - 1
        ELSE cur.CurrentYear
    END AS PreviousYear
FROM QuarterlySales cur
LEFT JOIN QuarterlySales prev ON cur.[Stock Item Key] = prev.[Stock Item Key]
    AND cur.CurrentQuarter = CASE 
                                WHEN prev.CurrentQuarter = 1 THEN 4
                                ELSE prev.CurrentQuarter - 1
                             END
    AND cur.CurrentYear = CASE 
                             WHEN prev.CurrentQuarter = 1 THEN prev.CurrentYear - 1
                             ELSE prev.CurrentYear
                          END

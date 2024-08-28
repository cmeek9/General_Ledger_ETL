SELECT  -- is good 
  HASHBYTES('SHA2_256', CONCAT(h.DOCCODE, h.DOCNUM, l.DOCLINENUM)) AS UniqueID
 ,l.[EL2]  AS [AccountLfKey]
 ,l.[EL3] + '.' + l.[EL4] AS [BusinessUnitLfKey]
 ,l.[EL5] AS ProductCodeLfKey
 ,l.[EL6] AS IndustryLfKey
 ,l.[EL7] AS SalesrepLfKey
 ,l.REF1 AS REF1
 ,l.REF2 AS REF2
 ,l.REF3 AS REF3
 ,l.REF4 AS REF4
 ,l.REF5 AS REF5
 ,l.REF6 AS REF6
 ,h.DOCCODE AS [DOCCODE]
 ,h.DOCNUM as [DOCNUM]
 ,l.DOCLINENUM AS [DOCLINENUM]
 ,case
  when h.[period] = 0 THEN try_cast(CAST(h.[yr] AS VARCHAR) + '-01-01' AS DATE)
  when h.[period] between 1 and 12 then try_cast(CAST(h.[yr] AS VARCHAR) + '-' + RIGHT('00' + CAST(h.[period] AS VARCHAR), 2) + '-01' AS DATE)
  when h.[period] IN (9998, 9999) then try_cast(CAST(h.[yr] + 1 AS VARCHAR) + '-01-01' AS DATE)
  else try_cast(CAST(h.[yr] AS VARCHAR) + '-01-01' AS DATE)
  END
  AS DateLfKey
 ,cast(h.DOCDATE as date) AS [DocDate]
 ,cast(l.MODDATE as datetime) AS [ModDate]
 ,'CODA G/L' AS [Source] 
 ,CASE when year(h.[DOCDATE]) = h.[yr] and month(h.[DOCDATE]) = h.[period] then 0 else 1 end as DocDateSetToPeriod
 ,l.VALUEHOME * POWER(10, 2 - l.VALUEHOME_DP) AS [Actual]
 ,CAST(0.00 AS NUMERIC(18, 2)) AS [Forecast]
  ,CAST(0.00 AS NUMERIC(18, 2)) AS [ForecastSL]
 ,case when d.[Account01Name] in ('Sales') then l.VALUEHOME * POWER(10, 2 - l.VALUEHOME_DP) else 0.00 end AS [ActualSales]
 ,CAST(0.00 AS NUMERIC(18, 2)) AS [ForecastSales]
 ,CAST(0.00 AS NUMERIC(18, 2)) AS [ForecastSLSales]
 ,case when d.[Account01Name] in ('Cost of Sales') then l.VALUEHOME * POWER(10, 2 - l.VALUEHOME_DP) else 0.00 end AS [ActualCOS]
 ,CAST(0.00 AS NUMERIC(18, 2)) AS [ForecastCOS]
 ,CAST(0.00 AS NUMERIC(18, 2)) AS [ForecastSLCOS]
 ,case when d.[Account01Name] in ('Sales','Cost of Sales') then l.VALUEHOME * POWER(10, 2 - l.VALUEHOME_DP) else 0.00 end AS [ActualGP]
 ,CAST(0.00 AS NUMERIC(18, 2)) AS [ForecastGP]
 ,CAST(0.00 AS NUMERIC(18, 2)) AS [ForecastSLGP]
 ,CAST(0.00 AS NUMERIC(18, 2))  AS [ActualPY]
 ,CAST(0.00 AS NUMERIC(18, 2))  AS [ForecastPY]
 ,CAST(0.00 AS NUMERIC(18, 2))  AS [ForecastSLPY]
 ,CAST(0.00 AS NUMERIC(18, 2))  AS [ActualSalesPY]
 ,CAST(0.00 AS NUMERIC(18, 2))  AS [ForecastSalesPY]
 ,CAST(0.00 AS NUMERIC(18, 2))  AS [ForecastSLSalesPY]
 ,CAST(0.00 AS NUMERIC(18, 2))  AS [ActualCOSPY]
 ,CAST(0.00 AS NUMERIC(18, 2))  AS [ForecastCOSPY]
 ,CAST(0.00 AS NUMERIC(18, 2))  AS [ForecastSLCOSPY]
 ,CAST(0.00 AS NUMERIC(18, 2))  AS [ActualGPPY]
 ,CAST(0.00 AS NUMERIC(18, 2))  AS [ForecastGPPY]
 ,CAST(0.00 AS NUMERIC(18, 2))  AS [ForecastSLGPPY]
,CAST(0.00 AS NUMERIC(18, 2)) as Cycle_1
,CAST(0.00 AS NUMERIC(18, 2)) as Cycle_2
,CAST(0.00 AS NUMERIC(18, 2)) as Cycle_3
,CAST(0.00 AS NUMERIC(18, 2)) as Cycle_4
,CAST(0.00 AS NUMERIC(18, 2)) as Cycle_5
,CAST(0.00 AS NUMERIC(18, 2)) as Cycle_P
,CAST(0.00 AS NUMERIC(18, 2)) as Cycle_X
 ,l.el2 as EL2
 ,l.el3 as EL3
 ,l.el4 as EL4
 ,l.el5 as EL5
 ,l.el6 as EL6
 ,l.el7 as EL7
 ,l.el8 as EL8
 ,l.descr as lineDesc
,CAST(h.[yr] AS VARCHAR(4)) + '/' + CAST(h.[period] AS VARCHAR(2)) AS [YYYYMM]
 ,h.descr as headerDesc
 ,h.INPDATE as inpDate
 ,'' as EL2Name
  ,'' as EL3Name
  ,'' as EL4Name
  ,'' as EL5Name
  ,'' as EL6Name
  ,'' as EL7Name
  ,'' as EL8Name
 ,h.XREF as XREF
 ,'' as XREF_name
 ,'' as XREF_sname
INTO Targit.stage_factOS
FROM [CODA].[OAS_DOCHEAD] h  --[CODA].[OAS_DOCHEAD] [CODA].[OAS_DOCHEAD]
LEFT JOIN [CODA].[OAS_DOCLINE]    l
ON h.DOCCODE = l.DOCCODE AND h.DOCNUM = l.DOCNUM AND h.CMPCODE = l.CMPCODE 
LEFT JOIN [Targit].[dimAccountOS] d
 ON l.[EL2] = d.[AccountLfKey]
WHERE l.[EL2] BETWEEN '300000' AND '999999'
 AND h.[PERIOD] BETWEEN 1 AND 12
 AND h.[STATUS] = 78
 AND h.[yr] >= YEAR(GETDATE()) - 3


 update Targit.stage_factOS
set BusinessUnitLfKey = '00.IE'
where AccountLfKey = '680040'



--combine everything at this step always
WITH cte1 AS (
select distinct-- is good
t1.[AccountLfKey],
t1.[BusinessUnitLfKey],
t1.[ProductCodeLfKey],
t1.[IndustryLfKey],
t1.[SalesrepLfKey],
t1.[REF1],
t1.[REF2],
t1.[REF3],
t1.[REF4],
t1.[REF5],
t1.[REF6],
t1.[DOCCODE],
t1.[DateLfKey],
t1.[DOCDATE],
t1.[DOCNUM],
t1.[DOCLINENUM],
t1.[Actual],
t1.[Forecast],
t1.[ForecastSL],
t1.[ActualSales],
t1.[ForecastSales],
t1.[ForecastSLSales],
t1.[ActualCOS],
t1.[ForecastCOS],
t1.[ForecastSLCOS],
t1.[ActualGP],
t1.[ForecastGP],
t1.[ForecastSLGP],
t1.[ActualPY],
t1.[ForecastPY],
t1.[ForecastSLPY],
t1.[ActualSalesPY],
t1.[ForecastSalesPY],
 t1.[ForecastSLSalesPY],
t1.[ActualCOSPY],
t1.[ForecastCOSPY],
t1.[ForecastSLCOSPY],
t1.[ActualGPPY],
t1.[ForecastGPPY],
t1.[ForecastSLGPPY],
t1.Cycle_1,
t1.Cycle_2,
t1.Cycle_3,
t1.Cycle_4,
t1.Cycle_5,
t1.Cycle_P,
t1.Cycle_X,
EL2,
EL3,
EL4,
EL5,
EL6,
EL7,
EL8,
lineDesc,
[YYYYMM],
headerDesc,
inpDate,
EL2Name,
EL3Name,
EL4Name,
EL5Name,
 EL6Name,
 EL7Name,
 EL8Name,
XREF,
XREF_name,
XREF_sname
from Targit.stage_factOS t1
where len(AccountLfKey) = 6 and substring(AccountLfKey,5,2) <> 'ce' and AccountLfKey < '600000' 
),


/* expense accounts that don't have suffixes set up */

-- need to add this into a temp table called 'stage_noSuffixes
cte2 AS (
/* expense accounts with suffixes, where cost center can only go to one suffix */

select distinct
t1.[AccountLfKey],
t1.[BusinessUnitLfKey],
t1.[ProductCodeLfKey],
t1.[IndustryLfKey],
t1.[SalesrepLfKey],
t1.[REF1],
t1.[REF2],
t1.[REF3],
t1.[REF4],
t1.[REF5],
t1.[REF6],
t1.[DOCCODE],
t1.[DateLfKey],
t1.[DOCDATE],
t1.[DOCNUM],
t1.[DOCLINENUM],
t1.[Actual],
t1.[Forecast],
t1.[ForecastSL],
t1.[ActualSales],
t1.[ForecastSales],
t1.[ForecastSLSales],
t1.[ActualCOS],
t1.[ForecastCOS],
t1.[ForecastSLCOS],
t1.[ActualGP],
t1.[ForecastGP],
t1.[ForecastSLGP],
t1.[ActualPY],
t1.[ForecastPY],
t1.[ForecastSLPY],
t1.[ActualSalesPY],
t1.[ForecastSalesPY],
 t1.[ForecastSLSalesPY],
t1.[ActualCOSPY],
t1.[ForecastCOSPY],
t1.[ForecastSLCOSPY],
t1.[ActualGPPY],
t1.[ForecastGPPY],
t1.[ForecastSLGPPY],
t1.Cycle_1,
t1.Cycle_2,
t1.Cycle_3,
t1.Cycle_4,
t1.Cycle_5,
t1.Cycle_P,
t1.Cycle_X,
EL2,
EL3,
EL4,
EL5,
EL6,
EL7,
EL8,
lineDesc,
[YYYYMM],
headerDesc,
inpDate,
EL2Name,
EL3Name,
EL4Name,
EL5Name,
 EL6Name,
 EL7Name,
 EL8Name,
XREF,
XREF_name,
XREF_sname
from Targit.stage_factOS t1
left join Targit.stage_noSuffixes t2
on t1.AccountLfKey = t2.Code
left join (select CostCenter, Suffix from targit.xrefElement2Splits where Account = '******') t3
on right(t1.BusinessUnitLfKey,2) = t3.CostCenter
left join targit.xrefElement2Splits t3a
on t1.AccountLfKey = t3a.Account and right(t1.BusinessUnitLfKey,2) = t3a.CostCenter
where (len(t1.AccountLfKey) = 6 and substring(t1.AccountLfKey,5,2) <> 'ce' and t1.AccountLfKey >= '600000')
AND (t2.code IS NOT NULL AND LTRIM(RTRIM(t2.code)) <> '') -- OLD CODE isNullOrEmpty(t2.code) = FALSE
),


/* expense accounts with suffixes, where cost center can only go to one suffix */
cte3 AS ( 
select distinct
t1.[AccountLfKey] +
 case
  when (t3a.Account IS NOT NULL AND LTRIM(RTRIM(t3a.Account)) <> '') then '-' + t3a.Suffix
  when (t3.CostCenter IS NOT NULL AND LTRIM(RTRIM(t3.CostCenter)) <> '') then '-' + t3.Suffix
  else ''
 end as AccountLfKey,
t1.[BusinessUnitLfKey],
t1.[ProductCodeLfKey],
t1.[IndustryLfKey],
t1.[SalesrepLfKey],
t1.[REF1],
t1.[REF2],
t1.[REF3],
t1.[REF4],
t1.[REF5],
t1.[REF6],
t1.[DOCCODE],
t1.[DateLfKey],
t1.[DOCDATE],
t1.[DOCNUM],
t1.[DOCLINENUM],
t1.[Actual],
t1.[Forecast],
t1.[ForecastSL],
t1.[ActualSales],
t1.[ForecastSales],
t1.[ForecastSLSales],
t1.[ActualCOS],
t1.[ForecastCOS],
t1.[ForecastSLCOS],
t1.[ActualGP],
t1.[ForecastGP],
t1.[ForecastSLGP],
t1.[ActualPY],
t1.[ForecastPY],
t1.[ForecastSLPY],
t1.[ActualSalesPY],
t1.[ForecastSalesPY],
t1.[ForecastSLSalesPY],
t1.[ActualCOSPY],
t1.[ForecastCOSPY],
t1.[ForecastSLCOSPY],
t1.[ActualGPPY],
t1.[ForecastGPPY],
t1.[ForecastSLGPPY],
t1.Cycle_1,
t1.Cycle_2,
t1.Cycle_3,
t1.Cycle_4,
t1.Cycle_5,
t1.Cycle_P,
t1.Cycle_X,
EL2,
EL3,
EL4,
EL5,
EL6,
EL7,
EL8,
lineDesc,
[YYYYMM],
headerDesc,
inpDate,
EL2Name,
EL3Name,
EL4Name,
EL5Name,
EL6Name,
EL7Name,
EL8Name,
XREF,
XREF_name,
XREF_sname
from Targit.stage_factOS t1
left join Targit.stage_noSuffixes t2
on t1.AccountLfKey = t2.Code
left join (select CostCenter, Suffix from targit.xrefElement2Splits where Account = '******') t3
on right(t1.BusinessUnitLfKey,2) = t3.CostCenter
left join targit.xrefElement2Splits t3a
on t1.AccountLfKey = t3a.Account and right(t1.BusinessUnitLfKey,2) = t3a.CostCenter
where (len(t1.AccountLfKey) = 6 and substring(t1.AccountLfKey,5,2) <> 'ce' and t1.AccountLfKey >= '600000')
AND (t2.code IS NULL OR LTRIM(RTRIM(t2.code)) = '')  -- OLD CODE FROM TARGIT: isNullOrEmpty(t2.code) = TRUE
),


/* Rental History - no suffixes set up */
cte4 AS (
select distinct
t1.[AccountLfKey],
t1.[BusinessUnitLfKey],
t1.[ProductCodeLfKey],
t1.[IndustryLfKey],
t1.[SalesrepLfKey],
t1.[REF1],
t1.[REF2],
t1.[REF3],
t1.[REF4],
t1.[REF5],
t1.[REF6],
t1.[DOCCODE],
t1.[DateLfKey],
t1.[DOCDATE],
t1.[DOCNUM],
t1.[DOCLINENUM],
t1.[Actual],
t1.[Forecast],
t1.[ForecastSL],
t1.[ActualSales],
t1.[ForecastSales],
t1.[ForecastSLSales],
t1.[ActualCOS],
t1.[ForecastCOS],
t1.[ForecastSLCOS],
t1.[ActualGP],
t1.[ForecastGP],
t1.[ForecastSLGP],
t1.[ActualPY],
t1.[ForecastPY],
t1.[ForecastSLPY],
t1.[ActualSalesPY],
t1.[ForecastSalesPY],
 t1.[ForecastSLSalesPY],
t1.[ActualCOSPY],
t1.[ForecastCOSPY],
t1.[ForecastSLCOSPY],
t1.[ActualGPPY],
t1.[ForecastGPPY],
t1.[ForecastSLGPPY],
t1.Cycle_1,
t1.Cycle_2,
t1.Cycle_3,
t1.Cycle_4,
t1.Cycle_5,
t1.Cycle_P,
t1.Cycle_X,
EL2,
EL3,
EL4,
EL5,
EL6,
EL7,
EL8,
lineDesc,
[YYYYMM],
headerDesc,
inpDate,
EL2Name,
EL3Name,
EL4Name,
EL5Name,
 EL6Name,
 EL7Name,
 EL8Name,
XREF,
XREF_name,
XREF_sname
from Targit.stage_factOS t1
where (len(t1.AccountLfKey) = 4 or substring(t1.AccountLfKey,5,2) = 'ce')
)


SELECT *
INTO Targit.stage_factOS_Step2
FROM (
    SELECT * FROM cte1
    UNION ALL 
    SELECT * FROM cte2
    UNION ALL
    SELECT * FROM cte3
	UNION ALL
    SELECT * FROM cte4
) t

--still yet to validate or use this, but is a cleaner code solution
WITH combined_cte AS (
    SELECT DISTINCT
        CASE 
            WHEN len(t1.AccountLfKey) = 6 AND substring(t1.AccountLfKey,5,2) <> 'ce' AND t1.AccountLfKey < '600000' THEN t1.AccountLfKey
            WHEN len(t1.AccountLfKey) = 6 AND substring(t1.AccountLfKey,5,2) <> 'ce' AND t1.AccountLfKey >= '600000' THEN 
                t1.AccountLfKey + 
                CASE
                    WHEN ISNULL(t3a.Account, '') <> '' THEN '-' + t3a.Suffix 
                    WHEN ISNULL(t3.CostCenter, '') <> '' THEN '-' + t3.Suffix
                    ELSE ''
                END
            ELSE t1.AccountLfKey
        END AS AccountLfKey,
        t1.[BusinessUnitLfKey],
        t1.[ProductCodeLfKey],
        t1.[IndustryLfKey],
        t1.[SalesrepLfKey],
        t1.REF1 AS REF1
 ,t1.REF2 AS REF2
 ,t1.REF3 AS REF3
 ,t1.REF4 AS REF4
 ,t1.REF5 AS REF5
 ,t1.REF6 AS REF6
 ,t1.DOCCODE AS [DOCCODE]
 ,t1.DOCNUM as [DOCNUM]
 ,t1.DOCLINENUM AS [DOCLINENUM]
 ,t1.DateLfKey
 ,t1.[DocDate]
 ,t1.[ModDate]
 ,t1.[Source] 
 ,t1.DocDateSetToPeriod
 ,t1.[Actual]
 ,t1.[Forecast]
 ,t1.[ForecastSL]
 ,t1.[ActualSales]
 ,t1.[ForecastSales]
 ,t1.[ForecastSLSales]
 ,t1.[ActualCOS]
 ,t1.[ForecastCOS]
 ,t1.[ForecastSLCOS]
 ,t1.[ActualGP]
 ,t1.[ForecastGP]
 ,t1.[ForecastSLGP]
 ,t1.[ActualPY]
 ,t1.[ForecastPY]
 ,t1.[ForecastSLPY]
 ,t1.[ActualSalesPY]
 ,t1.[ForecastSalesPY]
 ,t1.[ForecastSLSalesPY]
 ,t1.[ActualCOSPY]
 ,t1.[ForecastCOSPY]
 ,t1.[ForecastSLCOSPY]
 ,t1.[ActualGPPY]
 ,t1.[ForecastGPPY]
 ,t1.[ForecastSLGPPY]
,t1.Cycle_1
,t1.Cycle_2
,t1.Cycle_3
,t1.Cycle_4
,t1.Cycle_5
,t1.Cycle_P
,t1.Cycle_X
 ,t1.el2 as EL2
 ,t1.el3 as EL3
 ,t1.el4 as EL4
 ,t1.el5 as EL5
 ,t1.el6 as EL6
 ,t1.el7 as EL7
 ,t1.el8 as EL8
 ,t1.lineDesc
 ,t1.[YYYYMM]
 ,t1.headerDesc
 ,t1.inpDate
 ,'' as EL2Name
  ,t1.EL3Name
  ,t1.EL4Name
  ,t1.EL5Name
  ,t1.EL6Name
  ,t1.EL7Name
  ,t1.EL8Name
 ,t1.XREF
 ,t1.XREF_name
 ,t1.XREF_sname
    FROM Targit.stage_factOS t1
    LEFT JOIN Targit.stage_noSuffixes t2 ON t1.AccountLfKey = t2.Code
    LEFT JOIN (SELECT CostCenter, Suffix FROM targit.xrefElement2Splits WHERE Account = '******') t3
        ON right(t1.BusinessUnitLfKey,2) = t3.CostCenter
    LEFT JOIN targit.xrefElement2Splits t3a
        ON t1.AccountLfKey = t3a.Account AND right(t1.BusinessUnitLfKey,2) = t3a.CostCenter

)
SELECT *
INTO Targit.stage_factOS_Step2
FROM combined_cte;
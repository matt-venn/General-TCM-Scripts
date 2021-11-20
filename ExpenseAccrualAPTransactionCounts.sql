select min(apDate) AS MinDate, max(apDate) AS MaxDate, count(*) AS TotalTransactions --, MIN(apType), MAX(apType)
From APTransactions WITH (NOLOCK)
where apSource=5
and apDate>=cast((select codeDescription from UniqueCodes('SYS') WHERE codeCode='ACCRSTARTDATE') AS datetime)
group by year(apDate), month(apDate)
order by year(apDate), month(apDate)

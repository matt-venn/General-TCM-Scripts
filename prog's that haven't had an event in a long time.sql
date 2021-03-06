/****** This script identifies Community Car Programs that have ACTIVE status and amount of time since last created event ******/

USE TCMDATA
GO

WITH CTE AS(
	SELECT
		ROW_NUMBER() OVER (PARTITION BY pgCode ORDER BY CE.evDate DESC) AS RN
		,PG.pgCode
		,PG.pgStart
		,CE.evDate
		,PG.pgType
		,PG.pgStatus
		,PG.pgTeam
--		,(PG.Program_Care_Manager_Firstname + ' ' + PG.Program_Care_Manager_Surname) AS Worker
		,PG.pgID
		,CE.evRevokeDate
	FROM ClientEvents CE
	INNER JOIN Programs PG
	ON CE.evProgramID = PG.pgID
	WHERE PG.pgStatus NOT IN (N'COM', N'DNP')
	)
SELECT
	CTE.pgCode
	,CTE.pgType
	,CTE.pgTeam
--	,CTE.Worker
	,CTE.pgStart
	,CTE.evDate AS 'Date of Last Event'
	,DATEDIFF(wk,CTE.evDate,GETDATE()) AS 'Number Weeks Since Last Event'
	,DATEDIFF(mm,CTE.evDate,GETDATE()) AS 'Number Months Since Last Event'
	,DATEDIFF(yy,CTE.evDate,GETDATE()) AS 'Number Years Since Last Event'
FROM CTE
WHERE CTE.RN = 1
AND CTE.evRevokeDate IS NULL
AND CTE.pgType = 'COMMCAR'
AND DATEDIFF(yy,CTE.evDate,GETDATE()) > 0
ORDER BY DATEDIFF(wk,CTE.evDate,GETDATE()) DESC
 
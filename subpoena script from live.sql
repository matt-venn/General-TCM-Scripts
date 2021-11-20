USE TCMData
GO

SELECT
	CONVERT(VARCHAR(10),CE.evDate,103) AS 'Event Date'
	,CONVERT(VARCHAR(10),CE.evTime,108) AS 'Event Time'
	,CONVERT(VARCHAR(10),CE.evRevokeDate,103) AS 'Revoked Date'
	,PROGT.codeDescription AS 'Program Type'
	,CE.evType AS 'Note Type'
	,CASE
		WHEN NOTETYPE.codeDescription = 'Assessment visit' THEN DOCTYPE.codeDescription
		WHEN NOTETYPE.codeDescription IS NULL THEN CE.evType
		ELSE NOTETYPE.codeDescription
		END AS 'Note SubType'
	,TCM_Lookup.dbo.udf_StripHTML (REPLACE(CONVERT(VARCHAR(MAX),CE.evNote), '&nbsp;','')) AS 'Event Note'
	,CASE
		WHEN CE.evLink IS NULL THEN 'No'
		ELSE 'Yes'
		END AS 'Event Contains Attached File'
	,evCreateUser
	,EP.epGiven + ' ' + EP.epSurname as 'Client Name'

FROM
ClientEvents CE
INNER JOIN Programs PROG WITH (NOLOCK) ON CE.evProgramID = PROG.pgID
INNER JOIN TCMDATA.dbo.ClientData CD WITH (NOLOCK) ON CD.cID = PROG.cID
INNER JOIN TCMDATA.dbo.Episode EP WITH (NOLOCK) ON EP.cID = CD.cID
LEFT JOIN (SELECT [codeDescription], codeCode 
			FROM [TCMDATA].[dbo].[Codes]
			WHERE codetype = 'NOT') NOTETYPE ON NOTETYPE.codeCode = CE.evSubType
LEFT JOIN (SELECT [codeDescription], codeCode 
			FROM [TCMDATA].[dbo].[Codes]
			WHERE codetype = 'PROGT') PROGT ON PROGT.codeCode = PROG.pgType
LEFT JOIN (SELECT [codeDescription], codeCode 
			FROM [TCMDATA].[dbo].[Codes]
			WHERE codetype = 'DOCTYPE') DOCTYPE ON DOCTYPE.codeCode = evSubType

WHERE EP.epRecent = 1 
--AND RIGHT(CE.evDate,4) = '2021'
AND CE.evNote IS NOT NULL

ORDER BY CE.evDate DESC, CE.evTime
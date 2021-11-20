USE TCMData
GO

WITH CTE AS(
SELECT 
--Note that the respParent element links with ClientEvents.evID
	[respParent],
	DEXClient
FROM 
(
	SELECT SQ.qName, SR.respParent, SR.respValue 
	FROM dbo.SurveyResponses SR WITH (NOLOCK)
	INNER JOIN dbo.SurveyQuestions SQ WITH (NOLOCK) ON SQ.qID = SR.qID AND SQ.qMasterQuestionID IS NULL
	INNER JOIN dbo.Surveys S WITH (NOLOCK) ON SQ.svyID = S.svyID AND S.svyName = 'DSS DEX' 
) SV
PIVOT
(
MAX(respValue)
FOR qName IN (
	DEXClient
)
) as PVT
WHERE PVT.respParent IS NOT NULL
)

SELECT 
	PG.pgType,
	EP.epUR, PG.pgCode,
	EP.epGiven + ' ' + EP.epSurname as 'Client Name',
	DEXClient,
	pgOutletActivityId AS 'Outlet Activity',
	PG.pgNote

FROM CTE
INNER JOIN Episode EP WITH (NOLOCK) ON CTE.respParent = EP.epID
INNER JOIN ClientData CD WITH (NOLOCK) ON EP.cID = CD.cID
INNER JOIN Programs PG WITH (NOLOCK) ON PG.cID = CD.cID

WHERE PG.pgType = 'GCHASS'
AND EP.epRecent = 1
AND pgNote LIKE '%CHSP%'
--AND DEXClient = 'False'

ORDER BY  DEXClient	--pgOutletActivityId
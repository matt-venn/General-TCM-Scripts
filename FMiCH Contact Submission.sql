--Creates the FMiCH Contact Report

USE Test_Live_Data
GO

 SET ANSI_NULLS ON
 SET QUOTED_IDENTIFIER ON;

WITH CTE AS (
SELECT 
--Note that the respParent element links with ClientEvents.evID
	[respParent],
	FMH_C_ContactDate,
	FMH_C_Disc,
	FMH_C_Med,
	FMH_C_Loc,
	FMH_C_Consult
FROM 
(
	SELECT SQ.qName, SR.respParent, SR.respValue 
	FROM dbo.SurveyResponses SR WITH (NOLOCK)
	INNER JOIN dbo.SurveyQuestions SQ WITH (NOLOCK) ON SQ.qID = SR.qID AND SQ.qMasterQuestionID IS NULL
	INNER JOIN dbo.Surveys S WITH (NOLOCK) ON SQ.svyID = S.svyID AND S.svyName = 'Note with FMH Contact' 
) SV
PIVOT
(
MAX(respValue)
FOR qName IN (
	FMH_C_ContactDate,
	FMH_C_Disc,
	FMH_C_Med,
	FMH_C_Loc,
	FMH_C_Consult
)
) as PVT
WHERE PVT.respParent IS NOT NULL
)

SELECT
	'3050' AS COMMUNITY_HEALTH_SERVICE,  -- Need to get this from FMH Ep of Service Event
	pgCode AS EPISODE_IDENTIFIER,
	REPLACE(CONVERT(VARCHAR, CTE.FMH_C_ContactDate,103),'/','') + '0000' AS CONTACT_DATE,
	CTE.FMH_C_Disc AS DISCIPLINE,
	CTE.FMH_C_Med AS MEDIUM,
	CTE.FMH_C_Loc AS LOCATION_TYPE,
	CE.evadmContactTime AS DIRECT_TIME,
	ISNULL(CE.evadmIndirectTime, '') AS INDIRECT_TIME,
	0 AS INTERPRETING_TIME,
	ISNULL(cte.FMH_C_Consult, '') AS SECONDARY_CONSULTATION

FROM CTE 
	Inner Join ClientEvents CE WITH (NOLOCK) on CE.evID=CTE.respParent
	INNER JOIN Programs WITH (NOLOCK) ON CE.evProgramID = Programs.pgID
	INNER JOIN Episode EP WITH (NOLOCK) ON ce.epID = EP.epID

WHERE CE.evRevokeDate IS NULL
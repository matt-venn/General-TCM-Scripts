USE Test_Live_Data
GO

SELECT 
--Note that the respParent element links with ClientEvents.evID
	[respParent],
	[LGBFlag],
	[RefugeeStatus],
	[SexAtBirth],
	[AccommodationType],
	[EmploymentStatus],
	[VicUnivPatId],
	[ConcessionCardType]
FROM 
(
	SELECT SQ.qName, SR.respParent, SR.respValue 
	FROM dbo.SurveyResponses SR WITH (NOLOCK)
	INNER JOIN dbo.SurveyQuestions SQ WITH (NOLOCK) ON SQ.qID = SR.qID AND SQ.qMasterQuestionID IS NULL
	INNER JOIN dbo.Surveys S WITH (NOLOCK) ON SQ.svyID = S.svyID AND S.svyName = 'Client Details Survey' 
) SV
PIVOT
(
MAX(respValue)
FOR qName IN (
	[LGBFlag],
	[RefugeeStatus],
	[SexAtBirth],
	[AccommodationType],
	[EmploymentStatus],
	[VicUnivPatId],
	[ConcessionCardType]
)
) as PVT
WHERE PVT.respParent IS NOT NULL
AND ConcessionCardType IS NULL
ORDER BY VicUnivPatId
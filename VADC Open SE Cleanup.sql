USE TCMDATA;

WITH CTE AS(
		SELECT 
			[respParent],
			EventType,
			EndDate,
			OutletCode
		FROM 
		(
			SELECT SQ.qName, SR.respParent, SR.respValue 
			FROM TCMDATA.dbo.SurveyResponses SR WITH (NOLOCK)
			INNER JOIN TCMDATA.dbo.SurveyQuestions SQ WITH (NOLOCK) ON SQ.qID = SR.qID AND SQ.qMasterQuestionID IS NULL
			INNER JOIN TCMDATA.dbo.Surveys S WITH (NOLOCK) ON SQ.svyID = S.svyID AND S.svyName = 'VADC Service Event' 
		) SV
		PIVOT
		(
		MAX(respValue)
		FOR qName IN (
			EventType,
			EndDate,
			OutletCode
		)
		) as PVT
		WHERE PVT.respParent IS NOT NULL
		)
SELECT 
	CTE.respParent,
	CTE.OutletCode,
	SE.OutletServiceEventIdentifierFormatted,
		(SELECT MAX(evDate)
		FROM TCMDATA.dbo.ClientEvents CE
		INNER JOIN TCMDATA.dbo.Programs PG ON CE.evProgramID = PG.pgID
		WHERE evType = 'Note with VADC Contact'
		GROUP BY PG.pgID
		) AS 'Date_Last_Note'
FROM CTE 
INNER JOIN ClientEvents CE ON CTE.respParent = CE.evID
INNER JOIN Programs PG ON PG.pgID = CE.evProgramID
INNER JOIN VADCOutletServiceEventIdentifier SE ON SE.evID = CTE.respParent

WHERE CTE.EndDate IS NULL
AND evRevokeDate IS NOT NULL

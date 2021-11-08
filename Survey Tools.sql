-- Get the SurveyID from the svyName
SELECT * FROM TCMDATA.dbo.Surveys 
--WHERE svyName = 'VADC Service Event'
ORDER BY svyName

-- Now put the svyID into the line below
SELECT * FROM TCMData.dbo.SurveyQuestions WHERE svyID = 'AFC02909-E647-4065-A923-FF387D42B79C'
ORDER BY qName

-- Now you can grab the qID and enter it into script below
SELECT *
FROM TCMDATA.dbo.SurveyResponses
WHERE qID = 'EBB90865-A85D-4BC3-834C-793170B0E79E'

-- SurveyResponses.respParent = ClientEvents.evID
--Note that if you're analysing a 'Program Survey' then the SurveyResponses.respParent = ClientEvents.evProgramID


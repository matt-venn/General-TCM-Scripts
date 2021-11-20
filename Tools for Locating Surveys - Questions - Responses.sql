-- Get the SurveyID from the svyName
SELECT * FROM TCMDATA.dbo.Surveys 
WHERE svyName = 'VADC Service Event'
ORDER BY svyName

-- Now put the svyID into the line below
SELECT * FROM TCMData.dbo.SurveyQuestions WHERE svyID = 'F675E87F-80F7-43C1-A7CA-A9916FEBBF15'
ORDER BY qName

-- Now you can grab the qID and enter it into script below
SELECT *
FROM TCMDATA.dbo.SurveyResponses
WHERE qID = '228452A0-0B00-44A9-AC7A-59D994D05696'

-- SurveyResponses.respParent = ClientEvents.evID
--Note that if you're analysing a 'Program Survey' then the SurveyResponses.respParent = ClientEvents.evProgramID


USE [TCMDATA]
GO

SELECT 
	  EP.epUR AS 'TCM UR Number'
	  ,PG.pgCode as 'TCM Program Code'
	  , EP.epGiven + ' ' + EP.epSurname AS 'Client Name'
	  ,CONVERT(VARCHAR(10),[PlannedDate],103) AS 'Planned Date'
      ,PG.pgType AS 'Program Type'
	  ,PG.pgTeam AS 'Program Team'
	  ,SERLOC.codeDescription AS 'Service Location'
      ,SER.serName AS 'Service Name'
      ,[Cancelled]
      ,[Confirmed]
      ,[Occurred]
      ,ISNULL(VAR.codeDescription, '') AS 'Variation'
      ,CONVERT(VARCHAR(10),[StartTime],108) AS 'Start Time'
      ,CONVERT(VARCHAR(10),[EndTime],108) AS 'End Time'
FROM ServiceAppointmentViewBase SAVB
INNER JOIN ServiceDelivery SD WITH (NOLOCK) ON SD.sdID = SAVB.ServiceDeliveryID
INNER JOIN [Service] SER WITH (NOLOCK) ON SER.serID = SAVB.ServiceID
INNER JOIN Programs PG WITH (NOLOCK) ON PG.pgID = SAVB.ProgramID
INNER JOIN Episode EP WITH (NOLOCK) ON EP.cID = PG.cID
LEFT JOIN (SELECT codeDescription, codeCode
			FROM Codes
			WHERE codetype = 'SERLOC') SERLOC ON SERLOC.codeCode = SD.sdServiceLocation
LEFT JOIN (SELECT codeDescription, codeCode
			FROM Codes
			WHERE codetype = 'VAR') VAR ON VAR.codeCode = SAVB.VariationCode


WHERE PlannedDate >= '2021-08-16'
AND EP.epRecent = 1

ORDER BY PlannedDate, pgCode

GO
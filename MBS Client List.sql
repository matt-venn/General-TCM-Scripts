USE TCMDATA
GO

WITH CTE AS (
	SELECT
		SAVB.ClientID,
		MAX(SAVB.OccurrenceDate) AS Most_Recent_Appt
	FROM ServiceAppointmentViewBase SAVB
	INNER JOIN Programs PG WITH (NOLOCK) ON SAVB.ProgramID = PG.pgID
	WHERE SAVB.PlannedDate >= '2020-01-01'
		AND SAVB.Occurred = 1
		AND PG.pgType = 'BLPC'
	GROUP BY SAVB.ClientID, SAVB.Occurred
)

SELECT
	EP.epGiven AS Given,
	EP.epSurname AS Surname,
	EP.epAddress1 AS Address1,
	ISNULL(EP.epAddress2,'') AS Address2,
	EP.epSuburb AS Suburb,
	EP.epState AS State,
	EP.epPostcode AS Postcode,
	ISNULL(EP.epEmail,'') AS Email,
	ISNULL(EP.epPh,'') AS Phone,
	ISNULL(EP.epMobile,'') AS Mobile,
	CONVERT(varchar,CTE.Most_Recent_Appt, 103) AS 'Most Recent Occurred Appt'
FROM Episode EP
INNER JOIN CTE ON CTE.ClientID = EP.cID

ORDER BY EP.epSurname, EP.epGiven
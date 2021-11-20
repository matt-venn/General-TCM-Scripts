/*
TCM Data Migration
Select Statement creates Appointments csv file from TCM Database

Note that script currently contains Care Note Events that have been converted to Service Instances.
		... To remove you would include "WHERE SAVB.EndDate IS NOT NULL"

Created by Matt Venn on 24/5/2020
Modified on 15/7/20

*/

SELECT 
Worker.uFirstname + ' ' + Worker.uSurname AS StaffName
,EP.epUR
,CONVERT(CHAR(20),StartDate,103) + CONVERT(CHAR(5),StartTime,108) AS StartTime
,CONVERT(CHAR(20),EndDate,103) + CONVERT(CHAR(5),EndTime,108) AS EndTime
,'' AS Subject
,SAVB.Note AS Notes
,'' AS Type
,SAVB.Cancelled
,SAVB.Confirmed
,SAVB.Occurred
,CASE
	WHEN SAVB.Cancelled = 1 THEN 'Cancelled'
	WHEN SAVB.Confirmed = 1 AND SAVB.Occurred = 0 THEN 'Arrived'
	WHEN SAVB.Occurred = 1 THEN 'Occurred'
	ELSE 'Booked'
	END AS Status
,SERLOC.codeDescription AS Resource		--Have pulled the Service Location for this element


FROM TCMDATA.dbo.ServiceAppointmentViewBase SAVB WITH (NOLOCK)
  INNER JOIN TCMDATA.dbo.ClientData CD WITH (NOLOCK)  ON CD.cID = SAVB.ClientID  
  INNER JOIN TCMDATA.dbo.Episode EP WITH (NOLOCK)  ON CD.cID = EP.cID  
  INNER JOIN TCMDATA.dbo.ServiceDelivery SD WITH (NOLOCK) ON SD.sdID = SAVB.ServiceDeliveryID
  Inner JOIN TCMDATA.dbo.Worker WITH (NOLOCK) ON SAVB.WorkerID = Worker.uID
  left join (SELECT [codeDescription], codeCode 
			FROM [TCMDATA].[dbo].[Codes]
			WHERE codetype = 'SERLOC') SERLOC ON SERLOC.codeCode = SD.sdServiceLocation

WHERE EP.epRecent = 1
 AND SAVB.WorkerID is not null

 ORDER BY StartDate
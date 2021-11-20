/*
TCM Data Migration
Select Statement creates NOK csv file from TCM Database

Elements not available in TCM: Country (in Address)

Created by Matt Venn on 25/5/2020
*/

SELECT
EP.cID,
CAST(EP.epUR as varchar(20)) as UR
,ROL.codeDescription AS ContactType
,REL.codeDescription AS Relationship
,ccSurname AS Surname
,ccGiven AS FirstName
,ccAddress1 AS AddressLine1
,ccAddress2 AS AddressLine2
,ccAddress3 AS AddressLine3
,ccSuburb AS Suburb
,ccState AS State
,ccPostCode AS PostCode
,NULL AS Country
,ccPhone2 AS PhoneBH
,ccPhone1 AS PhoneAH
,ccPhone3 AS Mobile
,ccEmail AS Email

FROM [TCMDATA].[dbo].ClientContact CC
INNER JOIN [TCMDATA].[dbo].ClientContactRel CCR WITH (NOLOCK) ON CC.ccID = CCR.ccID 
INNER JOIN [TCMDATA].[dbo].[Episode] EP WITH (NOLOCK) ON EP.cID = CCR.cID
INNER JOIN [TCMDATA].[dbo].ClientContactRole CCROLE WITH (NOLOCK) ON CCROLE.crID = CCR.crID
  left join (SELECT [codeDescription], codeCode 
			FROM [TCMDATA].[dbo].[Codes]
			WHERE codetype = 'REL') REL ON REL.codeCode = CCR.ccRelationship
  left join (SELECT [codeDescription], codeCode 
			FROM [TCMDATA].[dbo].[Codes]
			WHERE codetype = 'ROL') ROL ON ROL.codeCode = CCROLE.ccrRole

WHERE EP.epRecent = 1
AND EP.epStatus  IN ('A', 'P', 'L')
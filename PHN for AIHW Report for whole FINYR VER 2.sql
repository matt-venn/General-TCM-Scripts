USE TCMDATA
GO

with cte as (
	SELECT 
	RespParent AS Ep_ID_from_Contact,
			
	CASE  PHN_AODT_Client_Type
		WHEN 'others use' THEN CAST('2' AS Varchar(2))
		ELSE CAST('1' AS Varchar(2))
		END AS PHN_AODT_Client_Type,

	PHN_AODT_Ref_Src,
	PHN_AODT_EoC_Start_Date,
	PHN_AODT_Cessation_Date,
	PHN_AODT_Cessation_Reason,
	PHN_AODT_Treatment_Type,

	CASE 
		WHEN PHN_AODT_Method_of_Use = 'Injests' THEN CAST('1' AS Varchar(2))
		WHEN PHN_AODT_Method_of_Use = 'Smokes' THEN CAST('2' AS Varchar(2))
		WHEN PHN_AODT_Method_of_Use = 'Injects' THEN CAST('3' AS Varchar(2))
		WHEN PHN_AODT_Method_of_Use = 'Sniffs' THEN CAST('4' AS Varchar(2))
		WHEN PHN_AODT_Method_of_Use = 'Inhales' THEN CAST('5' AS Varchar(2))
		WHEN PHN_AODT_Method_of_Use = 'Other' THEN CAST('6' AS Varchar(2))
		WHEN PHN_AODT_Method_of_Use = 'Not Stated/Inadequately Described' THEN CAST('9' AS Varchar(2))
		WHEN PHN_AODT_Method_of_Use IS NULL THEN CAST('9' AS Varchar(2))
		ELSE PHN_AODT_Method_of_Use
		END AS PHN_AODT_Method_of_Use,
	
	CASE 
		WHEN PHN_AODT_Inject = '<3 Months ago' THEN CAST('1' AS Varchar(2))
		WHEN PHN_AODT_Inject = '3 - 12 months ago' THEN CAST('2' AS Varchar(2))
		WHEN PHN_AODT_Inject = '>12 months ago' THEN CAST('3' AS Varchar(2))
		WHEN PHN_AODT_Inject = 'Never Injected' THEN CAST('4' AS Varchar(2))
		WHEN PHN_AODT_Inject = 'Not Stated/Inadequately Described' THEN CAST('9' AS Varchar(2))
		WHEN PHN_AODT_Client_Type = 'others use' THEN CAST('' AS Varchar(2))
		ELSE CAST('9' AS Varchar(2))
		END AS PHN_AODT_Inject,

	CASE     --Note that NULL has a value of zero
		WHEN PHN_AODT_Principal_Drug = 'Alcohol' THEN CAST('2101' AS Varchar(4))
		WHEN PHN_AODT_Principal_Drug = 'Cannabis' THEN CAST('7101' AS Varchar(4))
		WHEN PHN_AODT_Principal_Drug = 'Cannabinoid agonists (synthetics)' THEN CAST('7102' AS Varchar(4))
		WHEN PHN_AODT_Principal_Drug = 'Amphetamines' THEN CAST('3101' AS Varchar(4))
		WHEN PHN_AODT_Principal_Drug = 'Methamphetamines' THEN CAST('3103' AS Varchar(4))
		WHEN PHN_AODT_Principal_Drug = 'Heroin' THEN CAST('1202' AS Varchar(4))
		WHEN PHN_AODT_Principal_Drug = 'Benzodiazepines, nec' THEN CAST('2499' AS Varchar(4))
		WHEN PHN_AODT_Principal_Drug = 'Codeine' THEN CAST('1101' AS Varchar(4))
		WHEN PHN_AODT_Principal_Drug = 'Ecstasy' THEN CAST('3405' AS Varchar(4))
		WHEN PHN_AODT_Principal_Drug = 'Other Hallucinogens' THEN CAST('3999' AS Varchar(4))
		WHEN PHN_AODT_Principal_Drug = 'Cocaine' THEN CAST('3903' AS Varchar(4))
		WHEN PHN_AODT_Principal_Drug = 'Painkillers (or other analgesics)' THEN CAST('1000' AS Varchar(4))
		WHEN PHN_AODT_Principal_Drug = 'Gamma Hydroxybutyrate (GHB)' THEN CAST('2501' AS Varchar(4))
		WHEN PHN_AODT_Principal_Drug = 'Ketamine' THEN CAST('2202' AS Varchar(4)) --2202 
		WHEN PHN_AODT_Principal_Drug = 'Volatile Solvents' THEN CAST('6999' AS Varchar(4))
--		WHEN PHN_AODT_Ref_Src IN ('Other', 'Court Diversion', 'Police Diversion', 'Not Stated/Inadeqately Described') THEN CAST('0000' AS Varchar(4))
--		WHEN PHN_AODT_Client_Type = 'others use' THEN CAST('' AS Varchar(2))
		ELSE CAST('0000' AS Varchar(4))		
		--Principal drug must have value other than 0000 or 0001 except where Source of referral is '9' (police diversion), '10' (court diversion), '98' (Other), or '99' (not stated).
		END AS PHN_AODT_Principal_Drug,

--			PHN_AODT_Principal_Drug,
			PHN_AODT_Main_Treatment,
			PHN_AODT_Accom
			
	FROM 
	(
		SELECT SQ.qName, SR.respParent, SR.respValue 
		FROM dbo.SurveyResponses SR WITH (NOLOCK)
		INNER JOIN dbo.SurveyQuestions SQ WITH (NOLOCK) ON SQ.qID = SR.qID AND SQ.qMasterQuestionID IS NULL
		INNER JOIN dbo.Surveys S WITH (NOLOCK) ON SQ.svyID = S.svyID AND S.svyName = 'PHN AODT Data Entry Form'
	) SV
	PIVOT
	(
	MAX(respValue)
	FOR qName IN (
			PHN_AODT_Client_Type,
			PHN_AODT_Ref_Src,
			PHN_AODT_EoC_Start_Date,
			PHN_AODT_Cessation_Date,
			PHN_AODT_Cessation_Reason,
			PHN_AODT_Treatment_Type,
			PHN_AODT_Method_of_Use,
			PHN_AODT_Inject,
			PHN_AODT_Principal_Drug,
			PHN_AODT_Main_Treatment,
			PHN_AODT_Accom
	)
	) as PVT
	WHERE PVT.respParent IS NOT NULL
)
--	PG.pgType AS 'Program Type',

/* This bit sets up the csv header but throws a format error up at the cte table
SELECT
	'' AS Establishment_identifier,'' AS Person_identifier,'' AS Sex,'' AS Date_of_birth,'' AS Country_of_birth,'' AS Indigenous_status,'' AS Preferred_language,
	'' AS Client_type_alcohol_and_other_drug_treatment_services,'' AS Source_of_referral_to_alcohol_and_other_drug_treatment_service,
	'' AS Date_of_commencement_of_treatment_episode_for_alcohol_and_other_drugs,'' AS Date_of_cessation_of_treatment_episode_for_alcohol_and_other_drugs,
	'' AS Reason_for_cessation_of_treatment_episode_for_alcohol_and_other_drugs,'' AS Treatment_delivery_setting_for_alcohol_and_other_drugs,
	'' AS Method_of_use_for_principal_drug_of_concern,'' AS Injecting_drug_use_status,'' AS Principal_drug_of_concern,'' AS Other_drug_of_concern_1,
	'' AS Other_drug_of_concern_2,'' AS Other_drug_of_concern_3,'' AS Other_drug_of_concern_4,'' AS Other_drug_of_concern_5,
	'' AS Main_treatment_type,'' AS Other_treatment_type_1,'' AS Other_treatment_type_2,'' AS Other_treatment_type_3,'' AS Other_treatment_type_4,'' AS Other_treatment_type_5,
	'' AS Date_accuracy_indicator,'' AS SLK_581,'' AS Postcode_of_Client,'' AS Accommodation_type_prior_to_episode_of_service
*/

SELECT

	'' AS 'Establishment identifier',
	PG.pgCode AS 'Person identifier',
	CASE CD.cGender
		WHEN 'M' THEN 1
		WHEN 'F' THEN 2
		WHEN 'I' THEN 3
		ELSE 9 
		END AS Sex,
	REPLACE(CONVERT(CHAR(10), CD.cDOB, 103), '/', '') AS 'Date of birth',
	CASE CWH_COU_Map.CH_MDS_Code
		WHEN 9999 THEN '0003'
		ELSE CWH_COU_Map.CH_MDS_Code
		END AS 'Country of birth',
	CASE EP.epAboriginal 
		WHEN 1 THEN 4
		WHEN 2 THEN 1
		WHEN 3 THEN 2
		WHEN 4 THEN 3
		ELSE 9
		END AS 'Indigenous status',
	1201 AS 'Preferred language',
	  CTE.PHN_AODT_Client_Type AS 'Client type (alcohol and other drug treatment services)',
	CASE  
		WHEN CTE.PHN_AODT_Ref_Src = 'Self' THEN CAST('01' AS Varchar(2))
		WHEN CTE.PHN_AODT_Ref_Src = 'Family member/Friend' THEN CAST('02' AS Varchar(2))
		WHEN CTE.PHN_AODT_Ref_Src = 'Medical Practioner' THEN CAST('03' AS Varchar(2))
		WHEN CTE.PHN_AODT_Ref_Src = 'Hospital' THEN CAST('04' AS Varchar(2))
		WHEN CTE.PHN_AODT_Ref_Src = 'Mental health care service' THEN CAST('05' AS Varchar(2))			
		WHEN CTE.PHN_AODT_Ref_Src = 'AODT Other Agency' THEN CAST('06' AS Varchar(2))
		WHEN CTE.PHN_AODT_Ref_Src = 'Other Community Health Care Service' THEN CAST('07' AS Varchar(2))
		WHEN CTE.PHN_AODT_Ref_Src = 'Correctional Service' THEN CAST('08' AS Varchar(2))
		WHEN CTE.PHN_AODT_Ref_Src = 'Police Diversion' THEN CAST('09' AS Varchar(2))					
		WHEN CTE.PHN_AODT_Ref_Src = 'Court Diversion' THEN CAST('10' AS Varchar(2))
		WHEN CTE.PHN_AODT_Ref_Src = 'Other' THEN CAST('98' AS Varchar(2))
		ELSE CAST('99' AS Varchar(2))
		END AS 'Source of referral to alcohol and other drug treatment service',
	SUBSTRING(CTE.PHN_AODT_EoC_Start_Date,1,2) + SUBSTRING(CTE.PHN_AODT_EoC_Start_Date,4,2) + SUBSTRING(CTE.PHN_AODT_EoC_Start_Date,7,4) AS 'Date of commencement of treatment episode for alcohol and other drugs',
	SUBSTRING(CTE.PHN_AODT_Cessation_Date,1,2) + SUBSTRING(CTE.PHN_AODT_Cessation_Date,4,2) + SUBSTRING(CTE.PHN_AODT_Cessation_Date,7,4) AS 'Date of cessation of treatment episode for alcohol and other drugs',
	CASE CTE.PHN_AODT_Cessation_Reason 
		WHEN 'Treatment Completed' THEN 01						WHEN 'Change in Main Treatment Type' THEN 02
		WHEN 'Change in Delivery Setting' THEN 03				WHEN 'Change Principal Drug Concern' THEN 04
		WHEN 'Transferred to Another Service Provider' THEN 05	WHEN 'Ceased to Participate Against Advice' THEN 06
		WHEN 'Ceased to Participate Without Notice' THEN 07		WHEN 'Ceased to Participate Involuntarily' THEN 08
		WHEN 'Ceased to Participate at Expiation' THEN 09		WHEN 'Ceased to Participate by Mutual Agreement' THEN 10
		WHEN 'Sanctioned by Court' THEN 11						WHEN 'Imprisoned' THEN 12
		WHEN 'Deceased' THEN 13
		ELSE 01
		END AS 'Reason for cessation of treatment episode for alcohol and other drugs',
	1 AS 'Treatment delivery setting for alcohol and other drugs',

	CASE 
		WHEN CTE.PHN_AODT_Client_Type = 2 THEN ''
		ELSE CTE.PHN_AODT_Method_of_Use
		END AS 'Method of use for principal drug of concern',

	CASE
		WHEN CTE.PHN_AODT_Client_Type = 2 THEN ''
		ELSE PHN_AODT_Inject
		END AS 'Injecting Drug Use Status',

	CASE 
		WHEN CTE.PHN_AODT_Client_Type = 2 THEN ''
		ELSE PHN_AODT_Principal_Drug
		END AS 'Principal drug of concern',

	'' AS 'Other drug of concern (1)',
	'' AS 'Other drug of concern (2)',
	'' AS 'Other drug of concern (3)',
	'' AS 'Other drug of concern (4)',
	'' AS 'Other drug of concern (5)',

	CASE CTE.PHN_AODT_Main_Treatment 
		WHEN 'Withdrawal Management' THEN 1
		WHEN 'Counselling' THEN 2
		WHEN 'Rehabilitation' THEN 3
		WHEN 'Pharmacotherapy' THEN 4
		WHEN 'Support and Case Management' THEN 5
		WHEN 'Information and Education' THEN 6
		WHEN 'Assessment only' THEN 7
		ELSE 88
		END AS 'Main treatment type',
		'' AS 'Other treatment type (1)',
		'' AS 'Other Treatment Type (2)',
		'' AS 'Other Treatment Type (3)',
		'' AS 'Other Treatment Type (4)',
		'' AS 'Other Treatment Type (5)',
	ISNULL(CD.cDOBAccuracy, 'AAA') AS 'Date accuracy indicator',
CASE
	WHEN CD.cGender = 'F' THEN
			UPPER(SUBSTRING(EP.epSurname, 2,2))
			+ UPPER(SUBSTRING(EP.epSurname, 1,1)) --This line means the script does not folow SLK-581 rules
			+ UPPER(SUBSTRING(EP.epGiven, 2,2))
			+ REPLACE(CONVERT(CHAR(10), CD.cDOB, 103), '/', '')
			+ '2'
	WHEN CD.cGender = 'M' THEN
			UPPER(SUBSTRING(EP.epSurname, 2,2))
			+ UPPER(SUBSTRING(EP.epSurname, 1,1)) --This line means the script does not folow SLK-581 rules
			+ UPPER(SUBSTRING(EP.epGiven, 2,2))
			+ REPLACE(CONVERT(CHAR(10), CD.cDOB, 103), '/', '')
			+ '1'
	ELSE 	UPPER(SUBSTRING(EP.epSurname, 2,2))
			+ UPPER(SUBSTRING(EP.epSurname, 1,1)) --This line means the script does not folow SLK-581 rules
			+ UPPER(SUBSTRING(EP.epGiven, 2,2))
			+ REPLACE(CONVERT(CHAR(10), CD.cDOB, 103), '/', '')
			+ '9'	
	END AS 'SLK-581',
	EP.epPostcode AS 'Postcode of Client',
	CASE CTE.PHN_AODT_Accom
		WHEN 'Private Residence' THEN '11'										WHEN 'Boarding House/Private Hotel' THEN '12'
		WHEN 'Informal Housing' THEN '13'										WHEN 'None/Homeless/Public Place' THEN '14'
		WHEN 'Domestic-scale Supported Living Facility' THEN '21'				WHEN 'Supported Accommodation Facility' THEN '22'
		WHEN 'Short Term Crisis, Emergency, or Transitional Accom' THEN '23'	WHEN 'Acute Hospitals' THEN	'31.1'							
		WHEN 'Psychiatric Hospital' THEN '31.2'									WHEN 'Rehabilitation Hospital' THEN	'31.3'						
		WHEN 'Other Hospital' THEN '31.8'										WHEN 'Residential Aged Care Facility' THEN '32.1'
		WHEN 'Mental Health' THEN '33.1'										WHEN 'AOD' THEN '33.2'
		WHEN 'Other Specialised Community Residential' THEN '33.8'				WHEN 'Prison/Remand Centre/Youth Trng Centre' THEN '34'
		ELSE '99'
		END AS 'Accommodation type – prior to episode of service'

FROM CTE
INNER JOIN ClientEvents CE WITH (NOLOCK)
	ON CE.evID = CTE.Ep_ID_from_Contact
INNER JOIN Programs PG WITH (NOLOCK)
	ON CE.evProgramID = PG.pgID
INNER JOIN ClientData CD WITH (NOLOCK)
	ON CD.cID = PG.cID
INNER JOIN Episode EP WITH (NOLOCK)
	ON EP.cID = CD.cID
INNER JOIN TCM_Lookup.dbo.CWH_COU_Map
	ON TCM_Code COLLATE DATABASE_DEFAULT = CD.cCountryOfBirth COLLATE DATABASE_DEFAULT

WHERE evRevokeDate IS NULL
AND EP.epRecent = 1
AND (
	(SUBSTRING(CTE.PHN_AODT_Cessation_Date,7,4) = 2020 
		AND SUBSTRING(CTE.PHN_AODT_Cessation_Date,4,2) IN (07, 08, 09, 10, 11, 12))
	OR
	(SUBSTRING(CTE.PHN_AODT_Cessation_Date,7,4) = 2021 
		AND SUBSTRING(CTE.PHN_AODT_Cessation_Date,4,2) IN (01, 02, 03, 04, 05, 06))
	)
AND PG.pgType = 'GADBRIINT'  -- BETLIFDD   GADBRIINT    GADSHBW

AND PG.pgCode IN ('0056865', '0057187', '0057510')

ORDER BY PG.pgCode


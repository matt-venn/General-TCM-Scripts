-- These Scripts are tools regarding Code Sets and includes
-- a tool to turn a non-editable code set into an editable one

SELECT *
FROM [Test_Live_Data].[dbo].[Codes]
WHERE codeCode = 'LASTPLANDATE'

/*
--Script to turn a non-editable code set into an editable one ...

UPDATE [Test_Live_Data].[dbo].[Codes]
SET [codeSysType] = 0
FROM [Test_Live_Data].[dbo].[Codes]
WHERE codeCode = 'LASTPLANDATE'		--IN (N'VADCEVT', N'VADCCNM', N'VADCCNT', N'VADCFND', N'VADCSDS', N'VADCSST', N'VADCTPP')

*/

/*

-- Info below may help to identify the elements that make up this table ...

INSERT INTO [dbo].[Codes]([codeType], [codeCode], [codeDescription], [codeMemo], [codeText], [codeLink], [codeLink2], [codeLink3], [codeSysType], [codeBoolean], [codeJurisdiction], [codeStart], [codeEnd])
	VALUES('SYS', 'LASTPLANDATE', '20210630', 'Date that the Planned services are currently generated to. (Maintained by tcm)', NULL, NULL, NULL, NULL, 1, 0, NULL, NULL, NULL)

*/
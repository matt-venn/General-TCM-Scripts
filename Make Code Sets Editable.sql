UPDATE [TCMDATA].[dbo].[Codes]

SET [codeSysType] = 0

FROM [TCMData].[dbo].[Codes]

WHERE codeCode IN (N'VADCEVT', N'VADCCNM', N'VADCCNT', N'VADCFND', N'VADCSDS', N'VADCSST', N'VADCTPP')

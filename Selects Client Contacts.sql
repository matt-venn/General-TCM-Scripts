USE [TCMDATA]

SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

-- Explainer ...




Select *

	from ClientContact CC WITH (NOLOCK)
	INNER JOIN ClientData CD ON cd.cID = CC.cID
		
	Inner Join episode as ep WITH (NOLOCK) on ep.cID=CD.cID and ep.eprecent=1
	
--WHERE CC.cSurname = 'Rich'

ORDER BY ccSurname DESC
		
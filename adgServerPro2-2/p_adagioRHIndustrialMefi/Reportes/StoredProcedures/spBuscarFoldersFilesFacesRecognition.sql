USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc Reportes.spBuscarFoldersFilesFacesRecognition(
	@dtFiltros Nomina.dtFiltrosRH readonly,
	@IDUsuario int
) as
	SELECT 
		p.PersonId AS FolderName,
		f.FaceId + '.jpg' as Files
		--JSON_QUERY('["' + STRING_AGG(f.FaceId + '.jpg', '","') + '"]') AS Files
	FROM [AzureCognitiveServices].[tblPersons] p
		JOIN [AzureCognitiveServices].[tblPersonsFaces] f ON p.PersonId = f.PersonId
	--GROUP BY 
	--	p.PersonId
	--FOR JSON PATH;
GO

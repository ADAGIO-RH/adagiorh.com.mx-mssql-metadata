USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc Reportes.spBuscarPersonsFacesRecognition(
	@dtFiltros Nomina.dtFiltrosRH readonly,
	@IDUsuario int
) as
	SELECT 
		PersonId
		,PersonGroupId
		,[Name]
		,UserData
		,IDEmpleado
	FROM [AzureCognitiveServices].[tblPersons] p
GO

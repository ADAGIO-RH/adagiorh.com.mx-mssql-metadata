USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [Reportes].[spReporteBasicoCatalogoTematicasSTPS]
(
	  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)
AS
BEGIN

		select 
		UPPER(CT.Codigo) as Codigo
		,UPPER(CT.Descripcion) as Descripcion	
	From [STPS].[tblCatTematicas] CT
	
END
GO

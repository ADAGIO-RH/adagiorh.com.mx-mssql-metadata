USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteBasicoCatModalidadesSTPS]
(
	  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)
AS
BEGIN

		select 
		UPPER(Codigo) as Codigo
		,UPPER(Descripcion) as Descripcion
		From [STPS].[tblCatModalidades]
	
END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteBasicoCatalogoEstudiosSTPS]
(
  @dtFiltros Nomina.dtFiltrosRH readonly,
    @IDUsuario int
)
AS
BEGIN
  
		select 
	
		UPPER(Codigo) as Codigo
		,UPPER(Descripcion) as Descripcion   
		From [STPS].[tblCatEstudios]
	
END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spBuscarInstituciones]
(
	@IDInstitucion int = null
)
AS
BEGIN
	
		select 
		IDInstitucion
		,UPPER(Codigo) as Codigo
		,UPPER(Descripcion) as Descripcion
		From [STPS].[tblCatInstituciones]
		where IDInstitucion = @IDInstitucion or @IDInstitucion is null
END
GO

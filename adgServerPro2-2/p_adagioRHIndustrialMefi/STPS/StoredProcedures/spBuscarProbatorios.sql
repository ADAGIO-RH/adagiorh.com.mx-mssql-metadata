USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spBuscarProbatorios]
(
	@IDProbatorio int = null
)
AS
BEGIN
	
		select 
		IDProbatorio
		,UPPER(Codigo) as Codigo
		,UPPER(Descripcion) as Descripcion
		From [STPS].[tblCatProbatorios]
		where IDProbatorio = @IDProbatorio or @IDProbatorio is null
END
GO

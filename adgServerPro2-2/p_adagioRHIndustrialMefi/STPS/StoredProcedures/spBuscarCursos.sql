USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spBuscarCursos]
(
	@Curso Varchar(50) = ''
)
AS
BEGIN
	IF(@Curso = '' or @Curso is null)
	BEGIN
		select 
		IDCursos
		,UPPER(Codigo) as Codigo
		,UPPER(Descripcion) as Descripcion
		,Horas
		From [STPS].[tblCatCursos]
	END
	ELSE
	BEGIN
		select 
		IDCursos
		,UPPER(Codigo) as Codigo
		,UPPER(Descripcion) as Descripcion
		,Horas
		From [STPS].[tblCatCursos]
		where Descripcion like @Curso +'%'
			OR Codigo like @Curso+'%'
	END
END
GO

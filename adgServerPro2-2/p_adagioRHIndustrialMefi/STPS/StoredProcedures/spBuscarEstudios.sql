USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spBuscarEstudios]
(
	@Estudio Varchar(50) = ''
)
AS
BEGIN
	IF(@Estudio = '' or @Estudio is null)
	BEGIN
		select 
		IDEstudio
		,UPPER(Codigo) as Codigo
		,UPPER(Descripcion) as Descripcion
		From [STPS].[tblCatEstudios]
	END
	ELSE
	BEGIN
		select 
		IDEstudio
		,UPPER(Codigo) as Codigo
		,UPPER(Descripcion) as Descripcion
		From [STPS].[tblCatEstudios]
		where Descripcion like @Estudio +'%'
			OR Codigo like @Estudio+'%'
	END
END
GO

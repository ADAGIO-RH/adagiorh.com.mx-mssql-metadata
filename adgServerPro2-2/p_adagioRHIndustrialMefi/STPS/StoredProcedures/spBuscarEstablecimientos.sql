USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [STPS].[spBuscarEstablecimientos]
(
	@Establecimiento Varchar(50) = ''
)
AS
BEGIN
	IF(@Establecimiento = '' or @Establecimiento is null)
	BEGIN
		select 
		IDEstablecimientos
		,UPPER(Codigo) as Codigo
		,UPPER(Descripcion) as Descripcion
		From [STPS].[tblCatEstablecimientos]
	END
	ELSE
	BEGIN
		select 
		IDEstablecimientos
		,UPPER(Codigo) as Codigo
		,UPPER(Descripcion) as Descripcion
		From [STPS].[tblCatEstablecimientos]
		where Descripcion like @Establecimiento +'%'
			OR Codigo like @Establecimiento+'%'
	END
END
GO

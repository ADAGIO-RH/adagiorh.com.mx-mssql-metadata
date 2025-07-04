USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [IMSS].[spBuscarCatTiposJornada]
(
	@TipoJornada Varchar(50) = ''
)
AS
BEGIN
	IF(@TipoJornada = '' or @TipoJornada is null)
	BEGIN
		select 
			IDTipoJornada
			,UPPER(Codigo)AS Codigo
			,UPPER(Descripcion) AS Descripcion
		From [IMSS].[tblCatTipoJornada]
	END
	ELSE
	BEGIN
		select 
			IDTipoJornada
			,UPPER(Codigo)AS Codigo
			,UPPER(Descripcion) AS Descripcion 
		From [IMSS].[tblCatTipoJornada]
		where Descripcion like @TipoJornada +'%'
			OR Codigo like @TipoJornada+'%'
	END
END
GO

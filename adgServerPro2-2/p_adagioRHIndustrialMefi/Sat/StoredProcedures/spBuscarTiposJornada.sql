USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarTiposJornada]
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
		From [Sat].[tblCatTiposJornada]
	END
	ELSE
	BEGIN
		select 
			IDTipoJornada
			,UPPER(Codigo)AS Codigo
			,UPPER(Descripcion) AS Descripcion 
		From [Sat].[tblCatTiposJornada]
		where Descripcion like @TipoJornada +'%'
			OR Codigo like @TipoJornada+'%'
	END
END
GO

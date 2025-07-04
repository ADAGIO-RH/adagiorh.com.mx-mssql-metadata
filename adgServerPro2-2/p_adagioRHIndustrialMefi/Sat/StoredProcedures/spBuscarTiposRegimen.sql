USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarTiposRegimen]
(
	@TipoRegimen Varchar(50) = ''
)
AS
BEGIN
	IF(@TipoRegimen = '' or @TipoRegimen is null)
	BEGIN
		select 
			IDTipoRegimen
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion
		From [Sat].[tblCatTiposRegimen]
	END
	ELSE
	BEGIN
		select 
			IDTipoRegimen
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion
		From [Sat].[tblCatTiposRegimen]
		where Descripcion like @TipoRegimen +'%'
			OR Codigo like @TipoRegimen+'%'
	END
END
GO

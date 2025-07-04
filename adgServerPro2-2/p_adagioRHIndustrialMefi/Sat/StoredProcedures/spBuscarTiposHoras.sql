USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarTiposHoras]
(
	@TipoHora Varchar(50) = ''
)
AS
BEGIN
	IF(@TipoHora = '' or @TipoHora is null)
	BEGIN
		select 
			IDTipoHora
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion
		From [Sat].[tblCatTiposHoras]
	END
	ELSE
	BEGIN
		select 
			IDTipoHora
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion 
		From [Sat].[tblCatTiposHoras]
		where Descripcion like @TipoHora +'%'
			OR Codigo like @TipoHora+'%'
	END
END
GO

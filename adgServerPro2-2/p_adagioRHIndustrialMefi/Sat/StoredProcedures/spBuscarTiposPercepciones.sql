USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarTiposPercepciones]
(
	@TipoPercepcion Varchar(50) = ''
)
AS
BEGIN
	IF(@TipoPercepcion = '' or @TipoPercepcion is null)
	BEGIN
		select 
			IDTipoPercepcion
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion
		From [Sat].[tblCatTiposPercepciones]
	END
	ELSE
	BEGIN
		select 
			IDTipoPercepcion
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion 
		From [Sat].[tblCatTiposPercepciones]
		where Descripcion like @TipoPercepcion +'%'
			OR Codigo like @TipoPercepcion+'%'
	END
END
GO

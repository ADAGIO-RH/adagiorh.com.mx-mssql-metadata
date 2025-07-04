USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Sat].[spBuscarTiposNomina](
	@TipoNomina Varchar(50) = ''   
)
AS
BEGIN
	SET FMTONLY OFF;  

	IF(@TipoNomina = '' or @TipoNomina is null)
	BEGIN
		select 
			IDTipoNomina
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion)  AS Descripcion
		From [Sat].[tblCatTiposNomina]
	END
	ELSE
	BEGIN
		select 
			IDTipoNomina
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion)  AS Descripcion 
		From [Sat].[tblCatTiposNomina]
		where (Descripcion like @TipoNomina +'%'
			OR Codigo like @TipoNomina+'%')
	END
END
GO

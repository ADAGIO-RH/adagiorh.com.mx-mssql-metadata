USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarRegimenesFiscales]
(
	@RegimenFiscal Varchar(50) = ''
)
AS
BEGIN
	IF(@RegimenFiscal = '' or @RegimenFiscal is null)
	BEGIN
		select 
			IDRegimenFiscal
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion
			,PersonaFisica
			,PersonaMoral 
		From [Sat].[tblCatRegimenesFiscales]
	END
	ELSE
	BEGIN
		select 
			IDRegimenFiscal
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion
			,PersonaFisica
			,PersonaMoral 
		From [Sat].[tblCatRegimenesFiscales]
		where Descripcion like @RegimenFiscal +'%'
			OR Codigo like @RegimenFiscal+'%'
	END
END
GO

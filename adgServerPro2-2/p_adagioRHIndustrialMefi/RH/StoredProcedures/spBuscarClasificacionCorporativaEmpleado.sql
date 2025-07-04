USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarClasificacionCorporativaEmpleado]
(
	@IDEmpleado int
	,@IDUsuario int = 0	
)
AS
BEGIN
		DECLARE @IDIdioma VARCHAR(MAX)				
		SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', @IDUsuario, 'esmx');		

		Select 
		    PE.IDClasificacionCorporativaEmpleado,
			PE.IDEmpleado,
			PE.IDClasificacionCorporativa,
			P.Codigo,
			--P.Descripcion,
			ISNULL(JSON_VALUE(P.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') AS Descripcion,
			PE.FechaIni,
			PE.FechaFin
		From RH.tblClasificacionCorporativaEmpleado PE
			Inner join RH.tblCatClasificacionesCorporativas P
				on PE.IDClasificacionCorporativa = P.IDClasificacionCorporativa
		Where PE.IDEmpleado = @IDEmpleado
		ORDER BY PE.FechaIni Desc

END
GO

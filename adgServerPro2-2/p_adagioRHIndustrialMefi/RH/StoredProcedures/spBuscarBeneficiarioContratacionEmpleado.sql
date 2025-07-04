USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [RH].[spBuscarBeneficiarioContratacionEmpleado]
(
	@IDEmpleado int,
	@IDUsuario int
)
AS

BEGIN

	DECLARE @IDIdioma VARCHAR(20)
				;

		SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', CASE WHEN ISNULL(@IDUsuario,0) = 0 THEN 1 ELSE @IDUsuario END, 'esmx');

		Select 
		     DE.IDBeneficiarioContratacionEmpleado,
			DE.IDEmpleado,
			DE.FechaIni,
			DE.FechaFin
		From RH.tblBeneficiarioContratacionEmpleado DE with(nolock)
		Where DE.IDEmpleado = @IDEmpleado
		ORDER BY DE.FechaIni DESC
END
GO

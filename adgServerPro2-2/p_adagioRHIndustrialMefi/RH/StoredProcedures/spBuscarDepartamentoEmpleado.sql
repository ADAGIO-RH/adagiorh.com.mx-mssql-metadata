USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarDepartamentoEmpleado]
(
	@IDEmpleado int
)
AS

BEGIN

	DECLARE @IDIdioma VARCHAR(20)
				;

		SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', 1, 'esmx');

		Select 
		     DE.IDDepartamentoEmpleado,
			DE.IDEmpleado,
			DE.IDDepartamento,
			D.Codigo,
			JSON_VALUE(d.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))as Departamento,
			DE.FechaIni,
			DE.FechaFin
		From RH.tblDepartamentoEmpleado DE
			inner join RH.tblCatDepartamentos D
				on DE.IDDepartamento = D.IDDepartamento
		Where DE.IDEmpleado = @IDEmpleado
		ORDER BY DE.FechaIni DESC
END
GO

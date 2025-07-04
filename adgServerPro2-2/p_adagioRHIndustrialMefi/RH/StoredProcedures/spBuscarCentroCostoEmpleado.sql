USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCentroCostoEmpleado]
(
	@IDEmpleado int
)
AS
BEGIN
 DECLARE
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')
		Select 
			   CCO.IDCentroCostoEmpleado,
		        CCO.IDEmpleado,
			   CCO.IDCentroCosto,
			   CO.Codigo,
			  JSON_VALUE(CO.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as CentroCosto,
			   CO.CuentaContable,
			   CCO.FechaFin,
			   CCO.FechaIni 
		from RH.tblCentroCostoEmpleado CCO
			inner join RH.tblCatCentroCosto CO
				on CCO.IDCentroCosto = CO.IDCentroCosto
		where CCO.IDEmpleado = @IDEmpleado
		ORDER BY CCO.FechaIni DESC
END
GO

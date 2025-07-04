USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [RH].[spBuscarTipoNominaEmpleado]
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
		    PE.IDTipoNominaEmpleado,
			PE.IDEmpleado,
			c.IDCliente,
			JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente,
			PE.IDTipoNomina,
			P.Descripcion,
			PE.FechaIni,
			PE.FechaFin
		From RH.tblTipoNominaEmpleado PE with(nolock)
			Inner join Nomina.tblCatTipoNomina P with(nolock)
				on PE.IDTipoNomina = P.IDTipoNomina
			Inner join RH.tblCatClientes c  with(nolock)
				on p.IDCliente = c.IDCliente
		Where PE.IDEmpleado = @IDEmpleado
		ORDER BY PE.FechaIni Desc

END
GO

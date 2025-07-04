USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarClienteEmpleado]
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
			CE.IDClienteEmpleado,
			CE.IDEmpleado,
			CE.IDCliente,
			JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente,
			c.Codigo,
			CE.FechaIni,
			CE.FechaFin 
		from RH.tblClienteEmpleado CE
			inner join RH.tblCatClientes C
				on CE.IDCliente = C.IDCliente
		WHERE CE.IDEmpleado = @IDEmpleado
		ORDER by Ce.FechaIni DESC
END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spBuscarAprobadoresPredeterminadosPlazasPosiciones](
	@IDAprobadorPredeterminadoPlazaPosicion int = 0,
	@IDCliente int = 0,
	@IDUsuarioAprobador int = 0,
	@IDUsuario int
) as

	DECLARE   @IDIdioma varchar(max);
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select
		afpp.IDAprobadorPredeterminadoPlazaPosicion,
		afpp.IDCliente,
		c.Codigo as CodigoCliente,
		JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente,
		afpp.IDUsuario as IDUsuarioAprobador,
		u.Cuenta, 
		coalesce(u.Nombre, '') + ' ' +  coalesce(u.Apellido, '')  as NombreUsuario, 
		u.Email, 
		isnull(u.IDEmpleado,0) as IDEmpleado,
		isnull(afpp.Orden, 0) as Orden,
		afpp.FechaReg
	from RH.tblAprobadoresPredeterminadosPlazasPosiciones afpp with (nolock)
		join RH.tblCatClientes c with (nolock) on c.IDCliente = afpp.IDCliente
		join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = afpp.IDUsuario
	where 
		(afpp.IDAprobadorPredeterminadoPlazaPosicion = @IDAprobadorPredeterminadoPlazaPosicion or ISNULL(@IDAprobadorPredeterminadoPlazaPosicion, 0) = 0)		
		and (afpp.IDCliente = @IDCliente or ISNULL(@IDCliente, 0) = 0)		
		and (afpp.IDUsuario = @IDUsuarioAprobador or ISNULL(@IDUsuarioAprobador, 0) = 0)
	order by isnull(afpp.Orden, 0)asc
GO

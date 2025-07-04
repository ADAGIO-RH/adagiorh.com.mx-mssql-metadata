USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spIUAprobadorPredeterminadoPlazaPosicion](
	@IDAprobadorPredeterminadoPlazaPosicion int = 0,
	@IDCliente int,
	@IDUsuarioAprobador int,
	@Orden int = 0,
	@IDUsuario int
) as
		 	
	declare 
		@OldJSON varchar(Max),
		@NewJSON varchar(Max),
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (ISNULL(@IDAprobadorPredeterminadoPlazaPosicion, 0) = 0)
	begin
		insert RH.tblAprobadoresPredeterminadosPlazasPosiciones(IDCliente, IDUsuario, Orden)
		select @IDCliente, @IDUsuarioAprobador, @Orden

		set @IDAprobadorPredeterminadoPlazaPosicion = SCOPE_IDENTITY()

		select @NewJSON = a.JSON 
		from (
			select
				afpp.*,
				c.Codigo as CodigoCliente,
				JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente,
				u.Cuenta, 
				coalesce(u.Nombre, '') + ' ' +  coalesce(u.Apellido, '')  as NombreUsuario, 
				u.Email, 
				u.IDEmpleado
			from RH.tblAprobadoresPredeterminadosPlazasPosiciones afpp 
				join RH.tblCatClientes c on c.IDCliente = afpp.IDCliente
				join Seguridad.tblUsuarios u on u.IDUsuario = afpp.IDUsuario
				
			where IDAprobadorPredeterminadoPlazaPosicion = @IDAprobadorPredeterminadoPlazaPosicion
		) b
		cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		EXEC [Auditoria].[spIAuditoria] 
			@IDUsuario,
			'[RH].[tblAprobadoresPredeterminadosPlazasPosiciones]',
			'[RH].[spIUAprobadiorPredeterminadoPlazaPosicion]',
			'INSERT',
			@NewJSON,''
	end else
	begin
		select @OldJSON = a.JSON 
		from (
			select
				afpp.*,
				c.Codigo as CodigoCliente,
				JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente,
				u.Cuenta, 
				coalesce(u.Nombre, '') + ' ' +  coalesce(u.Apellido, '')  as NombreUsuario, 
				u.Email, 
				u.IDEmpleado
			from RH.tblAprobadoresPredeterminadosPlazasPosiciones afpp 
				join RH.tblCatClientes c on c.IDCliente = afpp.IDCliente
				join Seguridad.tblUsuarios u on u.IDUsuario = afpp.IDUsuario
			where IDAprobadorPredeterminadoPlazaPosicion = @IDAprobadorPredeterminadoPlazaPosicion
		) b
		cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		update RH.tblAprobadoresPredeterminadosPlazasPosiciones
			set
				IDUsuario = @IDUsuarioAprobador,
				Orden = @Orden
		where IDAprobadorPredeterminadoPlazaPosicion = @IDAprobadorPredeterminadoPlazaPosicion

		select @NewJSON = a.JSON 
		from (
			select
				afpp.*,
				c.Codigo as CodigoCliente,
				JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente,
				u.Cuenta, 
				coalesce(u.Nombre, '') + ' ' +  coalesce(u.Apellido, '')  as NombreUsuario, 
				u.Email, 
				u.IDEmpleado
			from RH.tblAprobadoresPredeterminadosPlazasPosiciones afpp 
				join RH.tblCatClientes c on c.IDCliente = afpp.IDCliente
				join Seguridad.tblUsuarios u on u.IDUsuario = afpp.IDUsuario
				
			where IDAprobadorPredeterminadoPlazaPosicion = @IDAprobadorPredeterminadoPlazaPosicion
		) b
		cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		EXEC [Auditoria].[spIAuditoria] 
			@IDUsuario,
			'[RH].[tblAprobadoresPredeterminadosPlazasPosiciones]',
			'[RH].[spIUAprobadiorPredeterminadoPlazaPosicion]',
			'UPDATE',
			@NewJSON,
			@OldJSON
	end
GO

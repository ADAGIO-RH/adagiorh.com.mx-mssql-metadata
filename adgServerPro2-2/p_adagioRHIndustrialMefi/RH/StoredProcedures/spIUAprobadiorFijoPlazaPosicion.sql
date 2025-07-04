USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spIUAprobadiorFijoPlazaPosicion](
	@IDAprobadorFijoPlazaPosicion int = 0,
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

	if (ISNULL(@IDAprobadorFijoPlazaPosicion, 0) = 0)
	begin
		insert RH.tblAprobadoresFijosPlazasPosiciones(IDCliente, IDUsuario, Orden)
		select @IDCliente, @IDUsuarioAprobador, @Orden

		set @IDAprobadorFijoPlazaPosicion = SCOPE_IDENTITY()

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
			from RH.tblAprobadoresFijosPlazasPosiciones afpp 
				join RH.tblCatClientes c on c.IDCliente = afpp.IDCliente
				join Seguridad.tblUsuarios u on u.IDUsuario = afpp.IDUsuario
				
			where IDAprobadorFijoPlazaPosicion = @IDAprobadorFijoPlazaPosicion
		) b
		cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		EXEC [Auditoria].[spIAuditoria] 
			@IDUsuario,
			'[RH].[tblAprobadoresFijosPlazasPosiciones]',
			'[RH].[spIUAprobadiorFijoPlazaPosicion]',
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
			from RH.tblAprobadoresFijosPlazasPosiciones afpp 
				join RH.tblCatClientes c on c.IDCliente = afpp.IDCliente
				join Seguridad.tblUsuarios u on u.IDUsuario = afpp.IDUsuario
			where IDAprobadorFijoPlazaPosicion = @IDAprobadorFijoPlazaPosicion
		) b
		cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		update RH.tblAprobadoresFijosPlazasPosiciones
			set
				IDUsuario = @IDUsuarioAprobador,
				Orden = @Orden
		where IDAprobadorFijoPlazaPosicion = @IDAprobadorFijoPlazaPosicion

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
			from RH.tblAprobadoresFijosPlazasPosiciones afpp 
				join RH.tblCatClientes c on c.IDCliente = afpp.IDCliente
				join Seguridad.tblUsuarios u on u.IDUsuario = afpp.IDUsuario
				
			where IDAprobadorFijoPlazaPosicion = @IDAprobadorFijoPlazaPosicion
		) b
		cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

		EXEC [Auditoria].[spIAuditoria] 
			@IDUsuario,
			'[RH].[tblAprobadoresFijosPlazasPosiciones]',
			'[RH].[spIUAprobadiorFijoPlazaPosicion]',
			'UPDATE',
			@NewJSON,
			@OldJSON
	end
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Crear y modificar Usuarios del sistema
** Autor			: Jose Rafael Román
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2017-11-01
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2018-07-06		Aneudy Abreu		Se agregó el parámetro @IDUsuarioQueCrea qeu se usa para
									saber que usuario está registrando el nuevo usuario.
							 
									Se agregó validación para que no se intenten guardar Cuentas/Emails 
									que ya exististen.

2018-12-14		Aneudy Abreu		Se agregó el parámetro @Password y una validación para que
									las cuentas nuevas de activen si la contraseña tiene algún valor.

2019-01-24		Aneudy Abreu		Se agregó validación para que si el usuario es un Empleado y no tiene
									email registrado busque un posible email en la tabla de contactos del 
									empleado.

2019-05-13		Aneudy Abreu		Se agregó una validación para que en caso de que el usuario sea
									un empleado se tome el nombre de la tabla de empleado y se guarde
									en la tabla de usuarios.

									Se agregó el campo de Sexo a la tabla de usuarios

2021-02-21		Aneudy Abreu		Se validación para que cuando el usuario sea un empleado se le asigne
									su empleado a su cuenta de usuario de forma inmediata.

2023-01-16		Aneudy Abreu		Se cambia la forma de buscar el email de colaborador cuando el @Email
									por parámetro sea NULL

									Se agrega una validación cuando el @Email no es válido con la
									función [Utilerias].[fsValidarEmail]
***************************************************************************************************/
CREATE PROCEDURE [Seguridad].[spUIUsuario]
(
	@IDUsuario int = 0
	,@Cuenta VARCHAR(50)
	,@Nombre VARCHAR(255)
	,@Apellido VARCHAR(255)
	,@Email VARCHAR(255)
	--,@Activo BIT = 1
	,@IDPerfil Int
	,@IDUsuarioQueCrea int
	,@key varchar(255)
	,@IDEmpleado int = null
	,@Password varchar(255) = null
	,@Supervisor bit = 0
)
AS
BEGIN
	declare @Sexo char(1) = null
	;
    DECLARE @OldJSON Varchar(Max), 
            @NewJSON Varchar(Max);

	select @Nombre = UPPER(@Nombre)
		 ,@Apellido = UPPER(@Apellido)
	;	

	-- En caso de que el usuario no sea un empleado es necesario
	-- asignar null a la variable @IDEmpleado para que no genere
	-- un error el Constraint con la tabla [RH].[tblEmpleados]
	if (@IDEmpleado = 0) set @IDEmpleado = null;

	--En caso de que el usuario sea un empleado se buscar su nombre
	--en la tabla de empleado.
	if (@IDEmpleado is not null)
	begin
		select 
			@Nombre		= coalesce(Nombre,'')+' '+coalesce(SegundoNombre,'')
			,@Apellido	= coalesce(Paterno,'')+' '+coalesce(Materno,'')
			,@Sexo	 = Sexo
		from [RH].tblEmpleados with (nolock)
		where IDEmpleado = @IDEmpleado	
	end;

	-- Validamos que el usuario sea un empleado y que sea un nuevo registro.
	-- Luego se valida si el parámetro @Email tiene valor, en caso contrario
	-- Se intenta buscar un email del empleado en la tabla [RH].[tblContactoEmpleado]
	if (@IDEmpleado is not null and @IDUsuario = 0)
	begin
		if (@Email is null or @Email = '')
		begin
			set @Email = [Utilerias].[fnGetCorreoEmpleado](@IDEmpleado, 0, null)

			if exists(select top 1 1 
					from Seguridad.tblUsuarios
					where Email = @Email) and isnull(@Email, '') != ''
			begin
				set @Email = null
			end
		end;		
	end; 

	IF(@IDUsuario = 0)
	BEGIN
		if exists (select top 1 1 
			from [Seguridad].[tblUsuarios] with (NOLOCK)
			where (Cuenta = @Cuenta) or (Email = @Email))
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuarioQueCrea, @CodigoError = '0000006'
			return 0;
		END;

		if ( 
			(select [Utilerias].[fsValidarEmail](@Email)) = 0
			 and (isnull(@Email, '') != '' )
			)
		BEGIN
			raiserror('El email no es válido', 16, 1)
			return 0;
		END;
	   
		INSERT INTO Seguridad.tblUsuarios(Cuenta,Nombre,Apellido,Email,Activo,IDPerfil, IDEmpleado,[Password],Sexo, Supervisor)
		VALUES(@Cuenta,@Nombre,@Apellido,@Email,case when @Password is not null then 1 else 0 end,@IDPerfil,@IDEmpleado, @Password,@Sexo, @Supervisor)

         
		set @IDUsuario = @@IDENTITY

	    SELECT @NewJSON = (SELECT * FROM Seguridad.tblUsuarios WHERE IDUsuario = @IDUsuario FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
         EXEC [Auditoria].[spIAuditoria] @IDUsuarioQueCrea,'[Seguridad].[tblUsuarios]','[Seguridad].[spUIUsuario]','INSERT',@NewJSON,''

		if (isnull(@IDEmpleado,0) > 0) 		
		begin
			insert  Seguridad.tblDetalleFiltrosEmpleadosUsuarios (IDUsuario, IDEmpleado, Filtro, ValorFiltro, IDCatFiltroUsuario)
			values(@IDUsuario, @IDEmpleado, 'Empleados', 'Empleados | '+coalesce(@Nombre,'')+' '+coalesce(@Apellido, ''), null)
		end

		insert into [Seguridad].TblUsuariosKeysActivacion(IDUsuario,ActivationKey,AvaibleUntil,Activo)
		select @IDUsuario,@key,dateadd(day,30,getdate()),1

		exec Seguridad.spTransferirPermisosPerfilUsuario @IDUsuario = @IDUsuario,@IDUsuarioLogueado =@IDUsuarioQueCrea,@IDPerfil = @IDPerfil
		exec [Seguridad].[spBuscarUsuario] @IDUsuario = @IDUsuario
	END
	ELSE
	BEGIN
		if exists (select top 1 1 
			from [Seguridad].[tblUsuarios]
			where (Cuenta = @Cuenta or (Email = @Email)) and IDUsuario <> @IDUsuario)
		BEGIN
			exec [App].[spObtenerError] @IDUsuario = @IDUsuarioQueCrea, @CodigoError = '0000006'
			return 0;
		END;
	   
		IF(
			(Select IDPerfil 
				from Seguridad.tblUsuarios with (NOLOCK) 
				where IDUsuario= @IDUsuario) <> @IDPerfil
				)
		BEGIN
			exec Seguridad.spTransferirPermisosPerfilUsuario @IDUsuario = @IDUsuario,@IDUsuarioLogueado =@IDUsuarioQueCrea,@IDPerfil = @IDPerfil
		END
        	    SELECT @OldJSON = (SELECT * FROM Seguridad.tblUsuarios WHERE IDUsuario = @IDUsuario FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

		UPDATE Seguridad.tblUsuarios
		set Cuenta		= @Cuenta
			,Nombre		= @Nombre
			,Apellido		= @Apellido
			,Email		= @Email
			,Activo		= case when @Password is not null then 1 else 0 end
			,IDPerfil		= @IDPerfil
			,[Password]	= case when @Password is not null then @Password else [Password] end
			,Sexo			= @Sexo
			,Supervisor	= @Supervisor
		WHERE IDUsuario	= @IDUsuario

		 SELECT @NewJSON = (SELECT * FROM Seguridad.tblUsuarios WHERE IDUsuario = @IDUsuario FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
         EXEC [Auditoria].[spIAuditoria] @IDUsuarioQueCrea,'[Seguridad].[tblUsuarios]','[Seguridad].[spUIUsuario]','UPDATE',@NewJSON,@OldJSON

		if (len(@key) > 0)
		begin
			insert into [Seguridad].TblUsuariosKeysActivacion(IDUsuario,ActivationKey,AvaibleUntil,Activo)
			select @IDUsuario,@key,dateadd(day,30,getdate()),1
		end;

		exec [Seguridad].[spBuscarUsuario] @IDUsuario = @IDUsuario
	END
END
GO

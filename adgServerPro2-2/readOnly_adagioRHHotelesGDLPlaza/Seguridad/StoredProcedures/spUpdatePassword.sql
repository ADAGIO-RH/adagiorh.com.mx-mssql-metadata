USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




create proc Seguridad.spUpdatePassword(
	@IDUsuario int,
	@PasswordActual varchar(255),
	@PasswordNueva varchar(255)
) as
	declare
		@PasswordDB varchar(255)
	;

	if not exists (select top 1 1 
					from Seguridad.tblUsuarios with (nolock)  
					where IDUsuario = @IDUsuario
				)
	begin
		raiserror('El usuario no existe en la base de datos.', 16, 1)
		return 0;
	end

	select @PasswordDB = [Password]
	from Seguridad.tblUsuarios with (nolock) 
	where IDUsuario = @IDUsuario

	if (@PasswordDB <> @PasswordActual) 
	begin
		raiserror('La contraseña actual es incorrecta.', 16, 1)
		return 0;
	end

	update Seguridad.tblUsuarios
		set [Password] = @PasswordNueva
	where IDUsuario = @IDUsuario
GO

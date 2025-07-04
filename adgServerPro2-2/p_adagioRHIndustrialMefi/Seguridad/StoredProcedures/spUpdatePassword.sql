USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [Seguridad].[spUpdatePassword](
	@IDUsuario int,
	@PasswordActual varchar(255),
	@PasswordNueva varchar(255)
) as
	declare
		@PasswordDB varchar(255)        
		,@FechaHora datetime = GETDATE()
		,@registrosAfectados int		

	;
    DECLARE @OldJSON Varchar(Max), 
            @NewJSON Varchar(Max);
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

        declare @jsonstring NVARCHAR(max)
        select @jsonstring=Valor from app.tblConfiguracionesGenerales  where IDConfiguracion='SeguridadPasswordLogin'    
        declare @tempConfiguracion as table (
            clave NVARCHAR(MAX),
            valor NVARCHAR(MAX)
        );
        INSERT INTO @tempConfiguracion (clave, valor)
        SELECT [key], value FROM OPENJSON(@jsonstring);
 
        
        if( (select valor from @tempConfiguracion where clave='habilitar_historiales_usuario_password') = 'true' )
        BEGIN 
            
		    if exists(select top 1 1 
			from Seguridad.tblHistorialPasswordsUsuarios
			where IDUsuario = @IDUsuario and [Password] = @PasswordNueva)
			begin
				raiserror('No puedes ingresar una contraseña que ya hayas usado antes', 16, 1)
				return;
			end
        END
    SELECT @OldJSON = (SELECT * FROM Seguridad.tblUsuarios WHERE IDUsuario = @IDUsuario FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

	update Seguridad.tblUsuarios
		set [Password] = @PasswordNueva
	where IDUsuario = @IDUsuario
    set @registrosAfectados = @@ROWCOUNT

		 SELECT @NewJSON = (SELECT * FROM Seguridad.tblUsuarios WHERE IDUsuario = @IDUsuario FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);
         EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[tblUsuarios]','[Seguridad].[spUpdatePassword]','UPDATE',@NewJSON,@OldJSON

    insert into Seguridad.tblHistorialPasswordsUsuarios(IDUsuario, [Password], UltimaFechaActualizacion)
			values (@IDUsuario, @PasswordNueva, getdate())
		set @registrosAfectados = @registrosAfectados + @@ROWCOUNT
		
    select respuesta='Contraseña actualizada correctamente'
GO

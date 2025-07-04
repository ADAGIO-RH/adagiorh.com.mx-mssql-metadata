USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Seguridad].[spActualizarPassword]
(
	@IDUsuario int,
	@Password varchar(max),
	@ZonaHoraria varchar(70),
	@Browser varchar(max),
	@GeoLocation varchar(max),
	@IDUsuarioLogeado int

)
AS
BEGIN	
	begin try
		begin tran
		declare
			@FechaHora datetime = GETDATE(),
			@registrosAfectados int
			;
     DECLARE 
        @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

		if not exists (select top 1 1 
			from Seguridad.tblUsuarios with (nolock)  
			where IDUsuario = @IDUsuario
			)
		begin
			raiserror('El usuario no existe en la base de datos.', 16, 1)
			return;
		end

   --     declare @jsonstring NVARCHAR(max)
   --     select @jsonstring=Valor from app.tblConfiguracionesGenerales  where IDConfiguracion='SeguridadPasswordLogin'    
   --     declare @tempConfiguracion as table (
   --         clave NVARCHAR(MAX),
   --         valor NVARCHAR(MAX)
   --     );
   --     INSERT INTO @tempConfiguracion (clave, valor)
   --     SELECT [key], value FROM OPENJSON(@jsonstring);
 
        
   --     if( (select valor from @tempConfiguracion where clave='habilitar_historiales_usuario_password') = 'true' )
   --     BEGIN 
            
		 --   if exists(select top 1 1 
			--from Seguridad.tblHistorialPasswordsUsuarios
			--where IDUsuario = @IDUsuario and [Password] = @Password)
			--begin
			--	raiserror('No puedes ingresar una contraseña que ya hayas usado antes', 16, 1)
			--	return;
			--end
   --     END

     SELECT @OldJSON = (SELECT * FROM Seguridad.TblUsuarios 
    WHERE IDUsuario = @IDUsuario FOR JSON PATH, WITHOUT_ARRAY_WRAPPER); 

		update Seguridad.tblUsuarios
			set [Password] = @Password,
				Bloqueado = 0
		where IDUsuario = @IDUsuario

		set @registrosAfectados = @@ROWCOUNT

     SELECT @NewJSON = (SELECT * FROM Seguridad.TblUsuarios 
    WHERE IDUsuario = @IDUsuario FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

    EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogeado,'[Seguridad].[TblUsuarios]','[Seguridad].[spActualizarPassword]','UPDATE',@NewJSON,@OldJSON


		insert into Seguridad.tblHistorialPasswordsUsuarios(IDUsuario, [Password], UltimaFechaActualizacion)
			values (@IDUsuario, @Password, getdate())
		set @registrosAfectados = @registrosAfectados + @@ROWCOUNT

		exec [Seguridad].[spIHistorialLoginUsuario] @IDUsuario=@IDUsuario, @ZonaHoraria=@ZonaHoraria, @Browser=@Browser, @GeoLocation=@GeoLocation, @FechaHora=@FechaHora, @LoginCorrecto=1

		if @registrosAfectados = 2
			commit tran
		else
			rollback tran
	end try
	begin catch
		rollback tran
		SELECT ERROR_MESSAGE() AS ErrorMessage;
	end catch
END
GO

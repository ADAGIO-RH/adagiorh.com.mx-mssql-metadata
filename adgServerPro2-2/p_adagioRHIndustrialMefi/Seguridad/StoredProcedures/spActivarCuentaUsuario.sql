USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: 
** Autor			: ? (Jose Vargas)
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-08-07
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2024-08-07			Jose Vargas	    Se agregan validaciones relacionadas con la rama de `SeguridadPassword`, estos cambios implican que en base  a la configuracion general `SeguridadPasswordLogin`,
                                    El usuario no podra ingresar claves que ya haya tenido.

***************************************************************************************************/
CREATE proc [Seguridad].[spActivarCuentaUsuario](
    @IDUsuario int
    ,@Password varchar(255)
    ,@IDUsuarioKeysActivacion int
) as
     declare @jsonstring NVARCHAR(max)
    select @jsonstring=Valor from app.tblConfiguracionesGenerales  where IDConfiguracion='SeguridadPasswordLogin'    
    declare @tempConfiguracion as table (
        clave NVARCHAR(MAX),
        valor NVARCHAR(MAX)
    );

     DECLARE 
        @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

    INSERT INTO @tempConfiguracion (clave, valor)
    SELECT [key], value FROM OPENJSON(@jsonstring);

    
    if( (select valor from @tempConfiguracion where clave='habilitar_historiales_usuario_password') = 'true' )
    BEGIN 
        if exists(select top 1 1  from Seguridad.tblHistorialPasswordsUsuarios where IDUsuario = @IDUsuario and [Password] = @Password)
        begin
            raiserror('No puedes ingresar una contraseña que ya hayas usado antes', 16, 1)
            return;
        end
    END

     SELECT @OldJSON = (SELECT * FROM Seguridad.TblUsuarios 
    WHERE IDUsuario = @IDUsuario FOR JSON PATH, WITHOUT_ARRAY_WRAPPER); 

    update Seguridad.tblUsuarios
	   set [Password] = @Password
		  ,Activo = 1
		  ,Bloqueado = 0
    where IDUsuario = @IDUsuario

    SELECT @NewJSON = (SELECT * FROM Seguridad.TblUsuarios 
    WHERE IDUsuario = @IDUsuario FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[TblUsuarios]','[Seguridad].[spActivarCuentaUsuario]','UPDATE',@NewJSON,@OldJSON


	insert into Seguridad.tblHistorialPasswordsUsuarios(IDUsuario, [Password], UltimaFechaActualizacion)
		values (@IDUsuario, @Password, getdate())


    SELECT @OldJSON = (SELECT * FROM Seguridad.TblUsuariosKeysActivacion 
    WHERE IDUsuarioKeysActivacion = @IDUsuarioKeysActivacion FOR JSON PATH, WITHOUT_ARRAY_WRAPPER); 


    update Seguridad.TblUsuariosKeysActivacion
	   set Activo = 0
		  ,ActivationDate = getdate()
    where IDUsuarioKeysActivacion = @IDUsuarioKeysActivacion

     SELECT @NewJSON = (SELECT * FROM Seguridad.TblUsuariosKeysActivacion 
    WHERE IDUsuarioKeysActivacion = @IDUsuarioKeysActivacion FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);   

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[TblUsuariosKeysActivacion]','[Seguridad].[spActivarCuentaUsuario]','UPDATE',@NewJSON,@OldJSON
GO

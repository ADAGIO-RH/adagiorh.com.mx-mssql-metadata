USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select *
--from Seguridad.TblUsuarios


--select *
--from [Seguridad].[TblUsuariosKeysActivacion]

CREATE proc [Seguridad].[spActivarCuenta](
    @key nvarchar(max) 
)as
declare 
--@key nvarchar(max) = 'UWxRUXpuOHk1MUxSR0tzblMzVlZHcWdXam5FUUJra0dFWHc2MDBVOVlGdz06cG9sYnJhdTdAZ21haWwuY29tOjU='
    @IDUsuario int = 0;
	 DECLARE 
        @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

    select @IDUsuario=isnull(IDUsuario,0)	
    from [Seguridad].[TblUsuariosKeysActivacion] 
    where ActivationKey = @key and AvaibleUntil >= cast(Getdate() as date)
    and Activo = 1

    if (@IDUsuario = 0)
    begin
	   raiserror('La clave de activación no es válida!',16,0)
	   return;
    end;  
       SELECT @OldJSON = (SELECT * FROM Seguridad.TblUsuarios 
    WHERE IDUsuario = @IDUsuario FOR JSON PATH, WITHOUT_ARRAY_WRAPPER); 

        update Seguridad.TblUsuarios
        set Activo=1
        where IDUsuario=@IDUsuario 

      SELECT @NewJSON = (SELECT * FROM Seguridad.TblUsuarios 
    WHERE IDUsuario = @IDUsuario FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);

    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[TblUsuarios]','[Seguridad].[spActivarCuenta]','UPDATE',@NewJSON,@OldJSON

    SELECT @OldJSON = (SELECT * FROM Seguridad.TblUsuariosKeysActivacion 
    WHERE ActivationKey = @key FOR JSON PATH, WITHOUT_ARRAY_WRAPPER); 

    
     update [Seguridad].[TblUsuariosKeysActivacion] 
    set Activo = 0
    where ActivationKey = @key

    SELECT @NewJSON = (SELECT * FROM Seguridad.TblUsuariosKeysActivacion 
    WHERE ActivationKey = @key FOR JSON PATH, WITHOUT_ARRAY_WRAPPER);    
	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Seguridad].[TblUsuariosKeysActivacion]','[Seguridad].[spActivarCuenta]','UPDATE',@NewJSON,@OldJSON
GO

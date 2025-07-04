USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [App].[spModificarClaveColaborador](
	@IDEmpleado int,
    @ClaveEmpleadoNueva varchar(max),
	@IDUsuarioLogin int
) as

DECLARE
@Error VARCHAR(MAX)

BEGIN TRY
    BEGIN TRAN ClaveEmpleado
	DECLARE
     @OldJSON varchar(max)
    ,@NewJSON varchar(max)
    ,@ClaveEmpleado Varchar(Max);

    Select @ClaveEmpleado = ClaveEmpleado from rh.tblEmpleados where IDEmpleado = @IDEmpleado

    select @OldJSON = a.JSON from RH.tblEmpleados b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDEmpleado = @IDEmpleado
    
    Update rh.tblEmpleados 
    set ClaveEmpleado = @ClaveEmpleadoNueva
    Where IDEmpleado = @IDEmpleado  
    
    select @NewJSON = a.JSON from RH.tblEmpleados b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDEmpleado = @IDEmpleado

	EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogin,'[RH].[tblEmpleados]','[App].[spModificarClaveColaborador]','UPDATE CLAVE EMPLEADO',@NewJSON,@OldJSON



    select @OldJSON = a.JSON from Seguridad.tblUsuarios b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDEmpleado = @IDEmpleado
    
    Update Seguridad.tblUsuarios
    set Cuenta = @ClaveEmpleadoNueva 
    where IDEmpleado = @IDEmpleado and Cuenta = @ClaveEmpleado

    select @NewJSON = a.JSON from Seguridad.tblUsuarios b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDEmpleado = @IDEmpleado
    
	EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogin,'[Seguridad].[tblUsuarios]','[App].[spModificarClaveColaborador]','UPDATE CUENTA EMPLEADO',@NewJSON,@OldJSON



    Update AzureCognitiveServices.tblPersons
    set UserData = @ClaveEmpleadoNueva 
    where IDEmpleado = @IDEmpleado


    EXEC [RH].[spSincronizarEmpleadosMaster] @EmpleadoIni = @ClaveEmpleadoNueva, @EmpleadoFin = @ClaveEmpleadoNueva
  
        COMMIT TRAN ClaveEmpleado
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN ClaveEmpleado
        select  ERROR_MESSAGE ( ) 
        
        --EXEC [App].[spObtenerError] @IDUsuario = @IDUsuarioLogin, @CodigoError = '1700002', @CustomMessage= @ERROR
    END CATCH
GO

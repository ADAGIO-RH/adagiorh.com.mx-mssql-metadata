USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Insertar/Actualizar dirección empleado  
** Autor   : Aneudy Abreu  
** Email   : aneudy.abreu@adagio.com.mx  
** FechaCreacion : 2018-07-09  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
2018-07-09  Aneudy Abreu  Se agrega el parámetro IDUsuario  
***************************************************************************************************/  
CREATE PROC [RH].[spBorrarContactoEmpleado](  
     @IDContactoEmpleado int 
    ,@IDEmpleado int  
    ,@IDUsuario int  
) as  
   -- select @IDContactoEmpleado,@IDEmpleado,@IDTipoContactoEmpleado,@Value  
  
    exec [RH].[spBuscarContactoEmpleado] @IDContactoEmpleado =@IDContactoEmpleado , @IDUsuario = @IDUsuario
	
	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [RH].[tblContactoEmpleado] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDContactoEmpleado=@IDContactoEmpleado and b.IDEmpleado=@IDEmpleado  

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblContactoEmpleado]','[RH].[spBorrarContactoEmpleado]','DELETE','',@OldJSON

	delete RH.tblContactosEmpleadosTiposNotificaciones where IDContactoEmpleado=@IDContactoEmpleado

    DELETE [RH].[tblContactoEmpleado]  
    where IDContactoEmpleado=@IDContactoEmpleado and IDEmpleado=@IDEmpleado  
      
    --exec [Bk].[spIEmpleadoActualizado]  
    -- @IDEmpleado = @IDEmpleado  
    --,@Tabla = '[RH].[tblContactoEmpleado]'  
    --,@IDUsuario = @IDUsuario  
  
  EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
GO

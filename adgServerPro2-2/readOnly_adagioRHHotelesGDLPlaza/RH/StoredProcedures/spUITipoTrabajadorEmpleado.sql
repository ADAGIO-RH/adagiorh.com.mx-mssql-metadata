USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spUITipoTrabajadorEmpleado]  
(  
	@IDEmpleado int  
	,@IDTipoTrabajador int   
	,@IDTipoContrato int   
	,@IDUsuario int
)  
AS  
BEGIN  
    Declare @msj nvarchar(max) ;  
  
  	 DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
	

    IF(ISNULL(@IDTipoTrabajador,0) = 0)  
    BEGIN  
		RETURN;  
    END  
 
	if exists(select 1 from RH.tblTipoTrabajadorEmpleado  
	where IDEmpleado = @IDEmpleado)  
	begin  

	
			select @OldJSON = a.JSON from [RH].[tblTipoTrabajadorEmpleado] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDEmpleado = @IDEmpleado

		UPDATE RH.tblTipoTrabajadorEmpleado  
		SET IDTipoTrabajador = @IDTipoTrabajador,
			IDTipoContrato = @IDTipoContrato  
		WHERE IDEmpleado = @IDEmpleado  

			select @NewJSON = a.JSON from [RH].[tblTipoTrabajadorEmpleado] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDEmpleado = @IDEmpleado

			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblTipoTrabajadorEmpleado]','[RH].[spUITipoTrabajadorEmpleado]','UPDATE',@NewJSON,@OldJSON
		   
		 

	end
	else
	BEGIN
		INSERT INTO RH.tblTipoTrabajadorEmpleado(IDEmpleado,IDTipoTrabajador,IDTipoContrato)  
		VALUES(@IDEmpleado,@IDTipoTrabajador,@IDTipoContrato) 


			select @NewJSON = a.JSON from [RH].[tblTipoTrabajadorEmpleado] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDEmpleado = @IDEmpleado

			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblTipoTrabajadorEmpleado]','[RH].[spUITipoTrabajadorEmpleado]','INSERT',@NewJSON,''
		   
		 


	END 
  
	declare @tran int 
	set @tran = @@TRANCOUNT
	if(@tran = 0)
	BEGIN
		exec [RH].[spMapSincronizarEmpleadosMaster] @IDEmpleado = @IDEmpleado  
	END
  
END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [RH].[spIUBrigadaEmpleado](
    @IDEmpleado int
    ,@Brigadas varchar(100)
	,@IDUsuario int
 ) as
   
   declare @IDBrigadaEmpleado int = 0;
   	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

    if not exists(select 1 from [RH].[tblBrigadasEmpleado] where IDEmpleado = @IDEmpleado)
    begin
	   insert into [RH].[tblBrigadasEmpleado] (IDEmpleado,Brigadas)
	   select @IDEmpleado,@Brigadas

	   select @IDBrigadaEmpleado=@@IDENTITY

	    select @NewJSON = a.JSON from [RH].[tblBrigadasEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDBrigadaEmpleado=@IDBrigadaEmpleado;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblBrigadasEmpleado]','[RH].[spIUBrigadaEmpleado]','INSERT',@NewJSON,''

    end else
    begin
		 select @OldJSON = a.JSON from [RH].[tblBrigadasEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDBrigadaEmpleado=@IDBrigadaEmpleado;

	   update [RH].[tblBrigadasEmpleado]
	   set  
		  Brigadas=@Brigadas
	   where IDEmpleado=@IDEmpleado
			 select @NewJSON = a.JSON from [RH].[tblBrigadasEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDBrigadaEmpleado=@IDBrigadaEmpleado;
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblBrigadasEmpleado]','[RH].[spIUBrigadaEmpleado]','UPDATE',@NewJSON,@OldJSON
    end;

    exec [RH].[spBuscarBrigadaEmpleado] @IDBrigadaEmpleado =@IDBrigadaEmpleado

	EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
GO

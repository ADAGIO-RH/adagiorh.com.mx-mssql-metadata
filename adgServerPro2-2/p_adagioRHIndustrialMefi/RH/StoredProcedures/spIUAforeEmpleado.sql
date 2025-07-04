USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [RH].[spIUAforeEmpleado](
     @IDAforeEmpleado int =0
    ,@IDEmpleado int
    ,@IDAfore int = 0
	,@IDUsuario int

) as
   -- select @IDContactoEmpleado,@IDEmpleado,@IDTipoContactoEmpleado,@Value
   	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

	

    if not exists(select 1 from [RH].[tblAforeEmpleado] where IDEmpleado = @IDEmpleado)
    begin

	   insert into [RH].[tblAforeEmpleado] (IDEmpleado,IDAfore)
	   select @IDEmpleado,@IDAfore

	   select @IDAforeEmpleado=@@IDENTITY

	   select @NewJSON = a.JSON from [RH].[tblAforeEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDAforeEmpleado=@IDAforeEmpleado;
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblAforeEmpleado]','[RH].[spIUAforeEmpleado]','INSERT',@NewJSON,''
    end else
    begin
	  select @OldJSON = a.JSON from [RH].[tblAforeEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDEmpleado=@IDEmpleado
		
	   update [RH].[tblAforeEmpleado]
	   set  
		  IDAfore=@IDAfore
	   where IDEmpleado=@IDEmpleado

	     select @NewJSON = a.JSON from [RH].[tblAforeEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDEmpleado=@IDEmpleado

	   EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblAforeEmpleado]','[RH].[spIUAforeEmpleado]','UPDATE',@NewJSON,@NewJSON


    end;

    exec [RH].[spBuscarAforeEmpleado] @IDAforeEmpleado =@IDAforeEmpleado

	EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
GO

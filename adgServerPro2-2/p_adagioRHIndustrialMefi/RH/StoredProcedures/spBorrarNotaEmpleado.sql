USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spBorrarNotaEmpleado](
	@IDNotaEmpleado int
	,@IDUsuario int
) as

  DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [RH].[tblNotasEmpleados] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDNotaEmpleado = @IDNotaEmpleado
    	

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblNotasEmpleados]','[RH].[spBorrarNotaEmpleado]','DELETE','',@OldJSON



	delete from RH.tblNotasEmpleados where IDNotaEmpleado = @IDNotaEmpleado
GO

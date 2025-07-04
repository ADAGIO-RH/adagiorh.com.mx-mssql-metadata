USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarJornadaEmpleado]
(
	@IDJornadaEmpleado int,
	@IDUsuario int
)
AS
BEGIN
	declare @IDEmpleado int = 0;

	 
  DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [RH].[tblJornadaEmpleado] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDJornadaEmpleado = @IDJornadaEmpleado
    	

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblJornadaEmpleado]','[RH].[spBorrarJornadaEmpleado]','DELETE','',@OldJSON




	select @IDEmpleado = IDEmpleado from RH.tblJornadaEmpleado 
	where IDJornadaEmpleado = @IDJornadaEmpleado

	
	DELETE RH.tblJornadaEmpleado 
	where IDJornadaEmpleado = @IDJornadaEmpleado

	EXEC RH.spMapSincronizarEmpleadosMaster @IDEmpleado = @IDEmpleado
		
END
GO

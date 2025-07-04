USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Procedimiento para Borrar Historial de los creditos Infonavit
** Autor			: Jose Roman
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-09-06
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/


CREATE PROCEDURE [RH].[spBorrarInfonavitEmpleadosHistorial]
(
	@IDHistorialInfonavitEmpleado int 
	,@IDUsuario int
)
AS
BEGIN
  
  
  DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [RH].[tblHistorialInfonavitEmpleado] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDHistorialInfonavitEmpleado = @IDHistorialInfonavitEmpleado
    	

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblHistorialInfonavitEmpleado]','[RH].[spBorrarInfonavitEmpleadosHistorial]','DELETE','',@OldJSON


	DELETE RH.tblHistorialInfonavitEmpleado
	where IDHistorialInfonavitEmpleado = @IDHistorialInfonavitEmpleado
	
END
GO

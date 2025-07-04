USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Procedimiento para Borrar creditos Infonavit  
** Autor   : Jose Roman  
** Email   : jose.roman@adagio.com.mx  
** FechaCreacion : 2018-09-06  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
***************************************************************************************************/  
  
  
CREATE PROCEDURE [RH].[spBorrarInfonavitEmpleados]  
(  
 @IDInfonavitEmpleado int 
 ,@IDUsuario int  
)  
AS  
BEGIN  
  
  
  DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [RH].[tblInfonavitEmpleado] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDInfonavitEmpleado = @IDInfonavitEmpleado  
    	

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblInfonavitEmpleado]','[RH].[spBorrarInfonavitEmpleados]','DELETE','',@OldJSON



 DELETE RH.tblHistorialInfonavitEmpleado  
 where IDInfonavitEmpleado = @IDInfonavitEmpleado  
  
 DELETE RH.tblInfonavitEmpleado  
 where IDInfonavitEmpleado = @IDInfonavitEmpleado  
   
END
GO

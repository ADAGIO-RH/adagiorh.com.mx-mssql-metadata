USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
/****************************************************************************************************       
** Descripción  : Borrar los PTU's       
** Autor   : Jose Roman     
** Email   : jose.roman@adagio.com.mx      
** FechaCreacion : 2019-05-03      
** Paremetros  :                    
****************************************************************************************************      
HISTORIAL DE CAMBIOS      
Fecha(yyyy-mm-dd) Autor   Comentario      
------------------- ------------------- ------------------------------------------------------------      
    
***************************************************************************************************/   
  
CREATE PROCEDURE [Nomina].[spBorrarPTU]  
(  
 @IDPTU int ,  
 @IDUsuario int   
)  
AS  
BEGIN  
  	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spBorrarPTU]',
		@Tabla		varchar(max) = '[Nomina].[tblPTU]',
		@Accion		varchar(20)	= 'DELETE'

	Exec Nomina.spBuscarPTU @IDPTU  

	select @OldJSON = a.JSON 
	from Nomina.tblPTU b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	WHERE IDPTU = @IDPTU

	Delete Nomina.tblPTUEmpleados
	where IDPTU = @IDPTU

	Delete Nomina.tblPTU 
	where IDPTU = @IDPTU

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
END
GO

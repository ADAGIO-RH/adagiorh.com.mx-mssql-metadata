USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Procedimiento para Actualizar los datos para llenar los Layouts 
** Autor   : Jose Roman  
** Email   : jose.roman@adagio.com.mx  
** FechaCreacion : 2018-8-27  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
***************************************************************************************************/  
  
CREATE PROCEDURE [Nomina].[spUParametrosLayoutPago](  
	@IDLayoutPagoParametros int,  
	@Valor Varchar(255) = '',  
	@IDUsuario int  
)  
AS  
BEGIN  
	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spUParametrosLayoutPago]',
		@Tabla		varchar(max) = '[Nomina].[tblLayoutPagoParametros]',
		@Accion		varchar(20)	= 'UPDATE'
	;

	select @OldJSON = a.JSON 
	from [Nomina].tblLayoutPagoParametros b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	WHERE IDLayoutPagoParametros = @IDLayoutPagoParametros 

	update Nomina.tblLayoutPagoParametros  
		set Valor = @Valor  
	Where IDLayoutPagoParametros = @IDLayoutPagoParametros  
    
	select @NewJSON = a.JSON 
	from [Nomina].tblLayoutPagoParametros b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
	WHERE IDLayoutPagoParametros = @IDLayoutPagoParametros 

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
END
GO

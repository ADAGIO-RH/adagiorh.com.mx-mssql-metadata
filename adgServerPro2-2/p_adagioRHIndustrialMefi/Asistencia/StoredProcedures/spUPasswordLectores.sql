USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************   
** Descripción  : PROCEDIMIENTO PARA MODIFICAR LA CONTRASEÑA DE LOS LECTORES  
** Autor   : Aneudy Abreu 
** Email   : aneudy.abreu@adagio.com.mx  
** FechaCreacion : 2021-09-09  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd)	Autor								Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00			NombreCompleto						¿Qué cambió?  
***************************************************************************************************/  
  
create PROCEDURE [Asistencia].[spUPasswordLectores](  
	@IDLector int = 0  
	,@PasswordLector varchar(100)  
	,@IDUsuario int  
)  
AS  
BEGIN  
	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
	;

	select @OldJSON = a.JSON from [Asistencia].[tblLectores] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDLector = @IDLector
		
	UPDATE Asistencia.tblLectores  
		set PasswordLector = @PasswordLector
	WHERE IDLector = @IDLector  

	select @NewJSON = a.JSON from [Asistencia].[tblLectores] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDLector = @IDLector

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblLectores]','[Asistencia].[spUILectores]','UPDATE-PASSWORD',@NewJSON,@OldJSON
  
	EXEC Asistencia.spBuscarLectores @IDLector  
END
GO

USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : PROCEDIMIENTO PARA MODIFICAR LOS LECTORES  
** Autor   : JOSE ROMAN  
** Email   : jose.roman@adagio.com.mx  
** FechaCreacion : 2018-09-19  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd)	Autor						Comentario  
------------------- ------------------- ------------------------------------------------------------  
2021-09-09			Aneudy Abreu				Se quitó la actualización de la contraseña
***************************************************************************************************/  
CREATE PROCEDURE [Asistencia].[spUILectores](  
	@IDLector int = 0  
	,@Lector varchar(100)  
	,@CodigoLector varchar(100)  
	,@PasswordLector varchar(100)  
	,@IDTipoLector nvarchar(200)  
	,@IDZonaHoraria int = 0  
	,@IP Varchar(50)  
	,@Puerto Varchar(50) 
	,@Estatus Varchar(max) = null 
	,@EsComedor bit = 0
	,@Comida bit = 0
	,@IDCliente int = 0
	,@IDUsuario int  
)  
AS  
BEGIN  

	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
	;
	
	select 
		@IDZonaHoraria = CASE WHEN @IDZonaHoraria = 0 THEN NULL ELSE @IDZonaHoraria END
		,@IDCliente = CASE WHEN @IDCliente = 0 THEN NULL ELSE @IDCliente END

	IF(ISNULL(@IDLector,0) = 0)  
	BEGIN  
		INSERT INTO Asistencia.tblLectores(Lector,CodigoLector,PasswordLector,IDTipoLector,IDZonaHoraria,[IP],Puerto,IDCliente,EsComedor,Comida)  
		VALUES(@Lector,@CodigoLector,@PasswordLector,@IDTipoLector,@IDZonaHoraria,@IP, @Puerto,@IDCliente, isnull(@EsComedor,0), isnull(@Comida,0))  
  
		SET @IDLector = @@IDENTITY  

		select @NewJSON = a.JSON from [Asistencia].[tblLectores] b
			cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDLector = @IDLector

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblLectores]','[Asistencia].[spUILectores]','INSERT',@NewJSON,''
	END  
	ELSE  
	BEGIN  
		select @OldJSON = a.JSON from [Asistencia].[tblLectores] b
			cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDLector = @IDLector
		
		UPDATE Asistencia.tblLectores  
		set Lector = @Lector,  
			CodigoLector = @CodigoLector,  
			PasswordLector = @PasswordLector,  
			IDTipoLector = @IDTipoLector,  
			IDZonaHoraria = @IDZonaHoraria,  
			[IP] = @IP,  
			Puerto = @Puerto ,
			Estatus = @Estatus ,
			IDCliente = @IDCliente,
			EsComedor = ISNULL(@EsComedor,0),
			Comida = ISNULL(@Comida,0)
		WHERE IDLector = @IDLector  

		select @NewJSON = a.JSON from [Asistencia].[tblLectores] b
			cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDLector = @IDLector

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblLectores]','[Asistencia].[spUILectores]','UPDATE',@NewJSON,@OldJSON
	END  
  
	EXEC Asistencia.spBuscarLectores @IDLector  
END
GO

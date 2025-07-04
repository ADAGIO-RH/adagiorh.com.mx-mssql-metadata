USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: <Procedure para guardar y actualizar los huellas sacadas0 de checadores ZK>
** Autor			: <Denzel Ovando>
** Email			: <denzel.ovando@adagio.com.mx>
** FechaCreacion	: <2021-11-09>
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
0000-00-00		    NombreCompleto		    ¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE [Asistencia].[spUIUsuarioZKFingerprint]
(
	 @IDUsuarioZKFingerprint int = 0
	,@IDEmpleado int
	,@EnrollNumber varchar(25)
	,@FingerIndex int
	,@Size int
	,@Valid bit
	,@FingerPrintTemplate nvarchar(max)
	,@MajorVer varchar(25)
	,@MinorVer varchar(25) 
	,@Duress varchar(25)
	,@IDUsuario int = 1
)
AS
BEGIN
 
  DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max); 

	--IF(@IDUserFingerprintZK = 0)
	IF NOT EXISTS (SELECT top 1 1 FROM [Asistencia].[tblUsuariosZKFingerprints] WHERE [IDEmpleado] = @IDEmpleado and [FingerIndex] = @FingerIndex)
	BEGIN
	INSERT INTO [Asistencia].[tblUsuariosZKFingerprints]
			   ([IDEmpleado]
			   ,[EnrollNumber]
			   ,[FingerIndex]
			   ,[Size]
			   ,[Valid]
			   ,[FingerPrintTemplate]
			   ,[MajorVer]
			   ,[MinorVer]
			   ,[Duress])
		VALUES
			(@IDEmpleado
			,@EnrollNumber
			,@FingerIndex
			,@Size
			,@Valid
			,@FingerPrintTemplate
			,@MajorVer
			,@MinorVer
			,@Duress)

		SET @IDUsuarioZKFingerprint = @@IDENTITY

		select @NewJSON = a.JSON from [Asistencia].[tblUsuariosZKFingerprints] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDUsuarioZKFingerprint = @IDUsuarioZKFingerprint 

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblUsuariosZKFingerprints]','[Asistencia].[spUIUsuarioZKFingerprint]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN

		select @OldJSON = a.JSON from [Asistencia].[tblUsuariosZKFingerprints] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDUsuarioZKFingerprint = @IDUsuarioZKFingerprint 

			UPDATE [Asistencia].[tblUsuariosZKFingerprints]
			   SET [IDEmpleado] = @IDEmpleado
				  ,[EnrollNumber] = @EnrollNumber
				  ,[FingerIndex] = @FingerIndex
				  ,[Size] = @Size
				  ,[Valid] = @Valid
				  ,[FingerPrintTemplate] = @FingerPrintTemplate
				  ,[MajorVer] = @MajorVer
				  ,[MinorVer] = @MinorVer
				  ,[Duress] = @Duress
			 WHERE IDUsuarioZKFingerprint = @IDUsuarioZKFingerprint

		select @NewJSON = a.JSON from [Asistencia].[tblUsuariosZKFingerprints] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDUsuarioZKFingerprint = @IDUsuarioZKFingerprint

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblUsuariosZKFingerprints]','[Asistencia].[spUIUsuarioZKFingerprint]','UPDATE',@NewJSON,@OldJSON
	END
	

	SELECT [IDUsuarioZKFingerprint]
		  ,[IDEmpleado]
		  ,[EnrollNumber]
		  ,[FingerIndex]
		  ,[Size]
		  ,[Valid]
		  ,[FingerPrintTemplate]
		  ,[MajorVer]
		  ,[MinorVer]
		  ,[Duress]
	  FROM [Asistencia].[tblUsuariosZKFingerprints]
	  WHERE IDUsuarioZKFingerprint = @IDUsuarioZKFingerprint
	
END
GO

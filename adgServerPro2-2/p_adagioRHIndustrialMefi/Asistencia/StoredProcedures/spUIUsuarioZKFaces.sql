USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**************************************************************************************************** 
** Descripción		: <Procedure para guardar y actualizar los rostros sacados de checadores ZK>
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

CREATE PROCEDURE [Asistencia].[spUIUsuarioZKFaces]
(
	 @IDUsuariosZKFace int = 0
	,@IDEmpleado int
    ,@EnrollNumber varchar(25)
    ,@FaceIndex int
    ,@Size int
    ,@Valid bit
    ,@FaceTemplate nvarchar(max)
    ,@Version varchar(25)
	,@IDUsuario int = 1
)
AS
BEGIN
 
  DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max); 

	IF NOT EXISTS (SELECT top 1 1 FROM [Asistencia].[tblUsuariosZKFaces] WHERE [IDEmpleado] = @IDEmpleado and [FaceIndex] =@FaceIndex)
	BEGIN

	INSERT INTO [Asistencia].[tblUsuariosZKFaces]
           ([IDEmpleado]
           ,[EnrollNumber]
           ,[FaceIndex]
           ,[Size]
           ,[Valid]
           ,[FaceTemplate]
           ,[Version])
     VALUES
           (@IDEmpleado 
			,@EnrollNumber 
			,@FaceIndex 
			,@Size 
			,@Valid 
			,@FaceTemplate 
			,@Version)

		SET @IDUsuariosZKFace = @@IDENTITY

		select @NewJSON = a.JSON from [Asistencia].[tblUsuariosZKFaces] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDUsuariosZKFace = @IDUsuariosZKFace

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblUsuariosZKFaces]','[Asistencia].[tblUsuariosZKFaces]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN

		select @OldJSON = a.JSON from [Asistencia].[tblUsuariosZKFaces] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE  b.IDUsuariosZKFace = @IDUsuariosZKFace



		UPDATE [Asistencia].[tblUsuariosZKFaces]
		   SET [IDEmpleado] = @IDEmpleado
			  ,[EnrollNumber] = @EnrollNumber
			  ,[FaceIndex] = @FaceIndex
			  ,[Size] = @Size
			  ,[Valid] = @Valid
			  ,[FaceTemplate] = @FaceTemplate
			  ,[Version] = @Version
		 WHERE IDUsuariosZKFace = @IDUsuariosZKFace

		select @NewJSON = a.JSON from [Asistencia].[tblUsuariosZKFaces] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE  b.IDUsuariosZKFace = @IDUsuariosZKFace

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblUsuariosZKFaces]','[Asistencia].[tblUsuariosZKFaces]','UPDATE',@NewJSON,@OldJSON
	END
	
	SELECT [IDUsuariosZKFace]
		  ,[IDEmpleado]
		  ,[EnrollNumber]
		  ,[FaceIndex]
		  ,[Size]
		  ,[Valid]
		  ,[FaceTemplate]
		  ,[Version]
	  FROM [Asistencia].[tblUsuariosZKFaces]
	  WHERE IDUsuariosZKFace = @IDUsuariosZKFace
	
END
GO

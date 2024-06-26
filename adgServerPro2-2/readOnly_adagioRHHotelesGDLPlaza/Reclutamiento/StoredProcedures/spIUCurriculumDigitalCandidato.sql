USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reclutamiento].[spIUCurriculumDigitalCandidato]
(
      @IDCurriculumDigitalCandidato int = 0 
	 ,@IDCandidato int
     ,@Name varchar(50)
     ,@ContentType nvarchar(200)
     ,@Data varbinary(max)
)
AS
BEGIN
	
	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)


	IF(@IDCurriculumDigitalCandidato is null OR @IDCurriculumDigitalCandidato = 0)
	BEGIN


INSERT INTO [Reclutamiento].[tblCurriculumDigitalCandidato]
           ([IDCandidato]
           ,[Name]
           ,[ContentType]
           ,[Data])
     VALUES
           (@IDCandidato
           ,@Name
           ,@ContentType
           ,@Data)

		
		SET @IDCurriculumDigitalCandidato = @@IDENTITY

		/*SELECT @NewJSON = a.JSON 
		FROM [RH].[ExpedienteDigitalEmpleado] b WITH(NOLOCK)
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDExpedienteDigitalEmpleado = @IDExpedienteDigitalEmpleado

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[ExpedienteDigitalEmpleado]','[RH].[spIUExpedientesDigitalesEmpleado]','INSERT',@NewJSON,''*/

	END ELSE
	BEGIN
		
		/*SELECT @OldJSON = a.JSON from [RH].[ExpedienteDigitalEmpleado] b  WITH(NOLOCK)
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDExpedienteDigitalEmpleado = @IDExpedienteDigitalEmpleado*/

		UPDATE [Reclutamiento].[tblCurriculumDigitalCandidato]
		   SET [IDCandidato] = @IDCandidato
			  ,[Name] = @Name
			  ,[ContentType] = @ContentType
			  ,[Data] = @Data
		 WHERE [Reclutamiento].[tblCurriculumDigitalCandidato].IDCurriculumDigitalCandidato = @IDCurriculumDigitalCandidato



		/*select @NewJSON = a.JSON from [RH].[tblCatExpedientesDigitales] b WITH(NOLOCK)
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDExpedienteDigital = @IDExpedienteDigital

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[ExpedienteDigitalEmpleado]','[RH].[spIUExpedientesDigitalesEmpleado]','UPDATE',@NewJSON,@OldJSON*/
	END

	

END;
GO

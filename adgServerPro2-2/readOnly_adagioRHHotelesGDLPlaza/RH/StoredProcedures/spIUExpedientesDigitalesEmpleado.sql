USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUExpedientesDigitalesEmpleado]
(
	 @IDExpedienteDigitalEmpleado int = 0 
	 ,@IDEmpleado int
     ,@IDExpedienteDigital int
     ,@Name varchar(50)
     ,@ContentType nvarchar(200)
     ,@Data varbinary(max)
	 ,@IDUsuario int
)
AS
BEGIN
	
	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)


	IF(@IDExpedienteDigitalEmpleado is null OR @IDExpedienteDigitalEmpleado = 0)
	BEGIN

		INSERT INTO [RH].[ExpedienteDigitalEmpleado]
           ([IDEmpleado]
           ,[IDExpedienteDigital]
           ,[Name]
           ,[ContentType]
           ,[Data])
     VALUES
           (@IDEmpleado
           ,@IDExpedienteDigital
           ,@Name
           ,@ContentType
           ,@Data)
		
		SET @IDExpedienteDigitalEmpleado = @@IDENTITY

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

		UPDATE [RH].[ExpedienteDigitalEmpleado]
		   SET [IDEmpleado] = @IDEmpleado
			  ,[IDExpedienteDigital] = @IDExpedienteDigital
			  ,[Name] = @Name
			  ,[ContentType] = @ContentType
			  ,[Data] = @Data
		 WHERE [IDExpedienteDigitalEmpleado] = @IDExpedienteDigitalEmpleado

		/*select @NewJSON = a.JSON from [RH].[tblCatExpedientesDigitales] b WITH(NOLOCK)
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDExpedienteDigital = @IDExpedienteDigital

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[ExpedienteDigitalEmpleado]','[RH].[spIUExpedientesDigitalesEmpleado]','UPDATE',@NewJSON,@OldJSON*/
	END

	

END;
GO

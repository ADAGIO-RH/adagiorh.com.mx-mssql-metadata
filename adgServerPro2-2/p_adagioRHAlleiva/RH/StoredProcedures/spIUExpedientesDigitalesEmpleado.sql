USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: <Procedure para Guardar - Actualizar los Expedientes Digitales>
** Autor			: 
** Email			: 
** FechaCreacion	: 
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
0000-00-00		    NombreCompleto		    ¿Qué cambió?
2023-03-23			JOSÉ ROMÁN				REFACTORIZACIÓN CON PAGINACIÓN
***************************************************************************************************/

CREATE PROCEDURE [RH].[spIUExpedientesDigitalesEmpleado]
(
	  @IDExpedienteDigitalEmpleado int = 0 
	 ,@IDEmpleado int
     ,@IDExpedienteDigital int
     ,@Name varchar(100)
     ,@ContentType varchar(200)
     ,@PathFile varchar(max)
     ,@Size int
	 ,@IDUsuario int
)
AS
BEGIN
	
	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max),
		@NombreLocal Varchar(max)

		set @NombreLocal = UPPER((SELECT top 1 ClaveEmpleado from RH.tblEmpleados where IDEmpleado = @IDEmpleado)
							+ '_'
							+(SELECT top 1 Codigo from RH.tblCatExpedientesDigitales where IDExpedienteDigital = @IDExpedienteDigital)
							+'_'
							+(Select top 1 item from app.Split(@Name,'.') order by id asc))
							+'.'+ (Select top 1 item from app.Split(@Name,'.') order by id desc)
	


	IF(@IDExpedienteDigitalEmpleado is null OR @IDExpedienteDigitalEmpleado = 0)
	BEGIN
	
		INSERT INTO [RH].[TblExpedienteDigitalEmpleado]
           ([IDEmpleado]
           ,[IDExpedienteDigital]
           ,[Name]
           ,[ContentType]
           ,[PathFile]
		   ,[Size])
     VALUES
           (@IDEmpleado
           ,@IDExpedienteDigital
           ,@NombreLocal
           ,@ContentType
           ,@PathFile+@NombreLocal
		   ,@Size)
		
		SET @IDExpedienteDigitalEmpleado = @@IDENTITY

		SELECT @NewJSON = a.JSON 
		FROM [RH].[TblExpedienteDigitalEmpleado] b WITH(NOLOCK)
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDExpedienteDigitalEmpleado = @IDExpedienteDigitalEmpleado

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[TblExpedienteDigitalEmpleado]','[RH].[spIUExpedientesDigitalesEmpleado]','INSERT',@NewJSON,''

	END ELSE
	BEGIN
		
		SELECT @OldJSON = a.JSON from [RH].[TblExpedienteDigitalEmpleado] b  WITH(NOLOCK)
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDExpedienteDigitalEmpleado = @IDExpedienteDigitalEmpleado

		UPDATE [RH].[TblExpedienteDigitalEmpleado]
		   SET [IDEmpleado] = @IDEmpleado
			  ,[IDExpedienteDigital] = @IDExpedienteDigital
			  ,[Name] = @NombreLocal
			  ,[ContentType] = @ContentType
			  ,[PathFile] = @PathFile+@NombreLocal
			  ,[Size] = @Size
		 WHERE [IDExpedienteDigitalEmpleado] = @IDExpedienteDigitalEmpleado

		select @NewJSON = a.JSON from [RH].[TblExpedienteDigitalEmpleado] b WITH(NOLOCK)
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDExpedienteDigitalEmpleado = @IDExpedienteDigitalEmpleado

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[TblExpedienteDigitalEmpleado]','[RH].[spIUExpedientesDigitalesEmpleado]','UPDATE',@NewJSON,@OldJSON
	END

	Exec [RH].[spBuscarExpedientesDigitalesEmpleado] @IDExpedienteDigitalEmpleado = @IDExpedienteDigitalEmpleado, @IDUsuario = @IDUsuario

END;
GO

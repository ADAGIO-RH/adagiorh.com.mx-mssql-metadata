USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: <Procedure para guardar y actualizar los usuarios sacados de checadores ZK>
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

CREATE PROCEDURE [Asistencia].[spUIUsuariosZK]
(
	 @IDUsuarioZK int = 0
    ,@SerialDispositivo varchar(50)
    ,@EnrollNumber varchar(50)
    ,@NombreUsuario varchar(50)
    ,@Password varchar(100)
    ,@NumeroTarjeta varchar(25)
    ,@Grupo varchar(15)
    ,@TimeZone varchar(15)
	,@Privilegio varchar(15)
	,@IDUsuario int = 1
)
AS
BEGIN
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max); 

	/*Declare Variables*/
	DECLARE @IDEmpleado int,
			@IDLector int,
			@IDCliente int,
			@ClaveEmpleadoCalculada varchar(25)

			--set @IDLector =( select top 1 IDLector from Asistencia.tblLectores l where l.NumeroSerial = @SerialDispositivo );
			--set @IDCliente = ( select top 1 IDCliente from Asistencia.tblLectores l where  l.IDLector = @IDLector );

			select top 1 
				@IDLector = l.IDLector,
				@IDCliente = l.IDCliente
			from Asistencia.tblLectores l 
			where l.NumeroSerial = @SerialDispositivo 


			--select 
			--@IDLector ,
			--@IDCliente


			declare @TempClaveEmpleado table (
				ClaveEmpleado varchar(20)
			)

			insert @TempClaveEmpleado
			exec [RH].[spGenerarClaveEmpleado]
				 @IDCliente = @IDCliente,  
				 @MAXClaveID  = @EnrollNumber,  
				 @IDUsuario = @IDUsuario

			
			select top 1 @ClaveEmpleadoCalculada = ClaveEmpleado
			from @TempClaveEmpleado

			select @IDEmpleado = IDEmpleado
			from RH.tblEmpleados with (nolock)
			where ClaveEmpleado = @ClaveEmpleadoCalculada


			IF @IDEmpleado is null
			BEGIN
				RETURN;
			END
		

	IF NOT EXISTS (SELECT top 1 1 FROM [Asistencia].[tblUsuariosZK] WHERE [IDEmpleado] = @IDEmpleado) 
	BEGIN

	INSERT INTO [Asistencia].[tblUsuariosZK]
           ([IDEmpleado]
           ,[IDLector]
           ,[EnrollNumber]
           ,[NombreUsuario]
           ,[Password]
           ,[NumeroTarjeta]
           ,[Grupo]
           ,[TimeZone]
           ,[Privilegio])
     VALUES
           (@IDEmpleado
           ,@IDLector
           ,@EnrollNumber
           ,@NombreUsuario
           ,@Password
           ,@NumeroTarjeta
           ,@Grupo
           ,@TimeZone
           ,@Privilegio)
		
		SET @IDUsuarioZK = @@IDENTITY

		select @NewJSON = a.JSON from [Asistencia].[tblUsuariosZK] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDUsuarioZK = @IDUsuarioZK

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblUsuariosZK]','[RH].[spUIUsuariosZK]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN

	
		select @OldJSON = a.JSON from [Asistencia].[tblUsuariosZK] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE  b.IDUsuarioZK = @IDUsuarioZK

		UPDATE [Asistencia].[tblUsuariosZK]
		   SET [IDEmpleado] = @IDEmpleado
			  ,[IDLector] = @IDLector
			  ,[EnrollNumber] = @EnrollNumber
			  ,[NombreUsuario] = @NombreUsuario
			  ,[Password] = @Password
			  ,[NumeroTarjeta] = @NumeroTarjeta
			  ,[Grupo] = @Grupo
			  ,[TimeZone] = @TimeZone
			  ,[Privilegio] = @Privilegio
		 WHERE [IDEmpleado] = @IDEmpleado

		select @NewJSON = a.JSON from [Asistencia].[tblUsuariosZK] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDUsuarioZK = @IDUsuarioZK

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblUsuariosZK]','[RH].[spUIUsuariosZK]','UPDATE',@NewJSON,@OldJSON
	END
	
	SELECT [IDUsuarioZK]
		  ,[IDEmpleado]
		  ,[IDLector]
		  ,[EnrollNumber]
		  ,[NombreUsuario]
		  ,[Password]
		  ,[NumeroTarjeta]
		  ,[Grupo]
		  ,[TimeZone]
		  ,[Privilegio]
	  FROM [Asistencia].[tblUsuariosZK]
	  WHERE [IDEmpleado] = @IDEmpleado

END
GO

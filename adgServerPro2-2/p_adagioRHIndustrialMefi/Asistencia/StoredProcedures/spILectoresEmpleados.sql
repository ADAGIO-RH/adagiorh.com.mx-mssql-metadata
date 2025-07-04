USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Asistencia].[spILectoresEmpleados]
(
	@IDEmpleado int,
	@IDLector int,
	@IDUsuario int
)
AS
BEGIN
	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max),
		@DevSN Varchar(50),
		@Configuracion Varchar(max)
	;

	select @DevSN = NumeroSerial, @Configuracion = Configuracion from Asistencia.tblLectores with(nolock) where IDLector = @IDLector
	IF NOT EXISTS(Select top 1 1 from Asistencia.tblLectoresEmpleados where IDLector = @IDLector and IDEmpleado = @IDEmpleado)
	BEGIN
		INSERT INTO Asistencia.tblLectoresEmpleados(IDLector, IDEmpleado, Fecha)
		VALUES(@IDLector, @IDEmpleado, GETDATE())

		IF(isjson(@Configuracion) > 0 and (json_value(@Configuracion, '$.connectivity') = 'ADMS'))
		BEGIN
			EXEC zkteco.spCoreCommand_UpdateUserInfo	@DevSN = @DevSN,@IDEmpleado = @IDEmpleado,	@IDUsuario = @IDUsuario
			EXEC zkteco.spCoreCommand_UpdateFaceTmp		@DevSN = @DevSN,@IDEmpleado = @IDEmpleado,	@IDUsuario = @IDUsuario
			EXEC zkteco.spCoreCommand_UpdateFingerTmp	@DevSN = @DevSN,@IDEmpleado = @IDEmpleado,	@IDUsuario = @IDUsuario
			EXEC zkteco.spCoreCommand_UpdateBioPhoto	@DevSN = @DevSN,@IDEmpleado = @IDEmpleado,	@IDUsuario = @IDUsuario
			EXEC zkteco.spCoreCommand_UpdateUserPic		@DevSN = @DevSN,@IDEmpleado = @IDEmpleado,	@IDUsuario = @IDUsuario
		END

		select @NewJSON = a.JSON from [Asistencia].[tblLectoresEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDLectorEmpleado = @@IDENTITY

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblLectoresEmpleados]','[Asistencia].[spILectoresEmpleados]','INSERT',@NewJSON,''
	END
END
GO

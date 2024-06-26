USE [readOnly_adagioRHHotelesGDLPlaza]
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

  DECLARE @OldJSON Varchar(Max),
			@NewJSON Varchar(Max);

	IF NOT EXISTS(Select top 1 1 from Asistencia.tblLectoresEmpleados where IDLector = @IDLector and IDEmpleado = @IDEmpleado)
	BEGIN

	

		INSERT INTO Asistencia.tblLectoresEmpleados
		VALUES(@IDLector, @IDEmpleado, GETDATE())
		
		select @NewJSON = a.JSON from [Asistencia].[tblLectoresEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDLectorEmpleado = @@IDENTITY

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblLectoresEmpleados]','[Asistencia].[spILectoresEmpleados]','INSERT',@NewJSON,''

	END

END
GO

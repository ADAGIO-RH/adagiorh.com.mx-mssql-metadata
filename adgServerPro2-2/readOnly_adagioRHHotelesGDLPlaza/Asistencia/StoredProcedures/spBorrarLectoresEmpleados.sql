USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Asistencia].[spBorrarLectoresEmpleados]
(
	@IDEmpleado int,
	@IDLector int,
	@IDUsuario int
)
AS
BEGIN

   DECLARE @OldJSON Varchar(Max),
			@NewJSON Varchar(Max);

	

	IF EXISTS(Select top 1 1 from Asistencia.tblLectoresEmpleados where IDLector = @IDLector and IDEmpleado = @IDEmpleado)
	BEGIN

		select @OldJSON = a.JSON from [Asistencia].[tblLectoresEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDLector = @IDLector and IDEmpleado = @IDEmpleado

		Delete  Asistencia.[tblLectoresEmpleados]
		WHERE IDLector = @IDLector and IDEmpleado = @IDEmpleado
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblLectoresEmpleados]','[Asistencia].[spBorrarLectoresEmpleados]','DELETE','',@OldJSON
	END

END
GO

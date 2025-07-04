USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Asistencia].[spBorrarMensajeEmpleados]
(
	@IDMensajeEmpleado int,
	@IDUsuario int	
)
AS
BEGIN
	Exec Asistencia.spBuscarMensajeEmpleados @IDMensajeEmpleado

	
   DECLARE @OldJSON Varchar(Max),
			@NewJSON Varchar(Max);

			select @OldJSON = a.JSON from [Asistencia].[tblMensajesEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDMensajeEmpleado = @IDMensajeEmpleado

		Delete Asistencia.[tblMensajesEmpleados]
		where IDMensajeEmpleado = @IDMensajeEmpleado

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblMensajesEmpleados]','[Asistencia].[spBorrarMensajeEmpleados]','DELETE','',@OldJSON

END
GO

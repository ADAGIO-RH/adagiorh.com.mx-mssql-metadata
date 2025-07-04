USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Asistencia].[spUIMensajesEmpleados]
(
	@IDMensajeEmpleado int = 0,
	@IDEmpleado int,
	@FechaInicio Date,
	@FechaFin Date,
	@Mensaje Varchar(MAX),
	@IDUsuario int
)
AS
BEGIN


 DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);

	set @Mensaje = UPPER(@Mensaje)

	IF(isnull(@IDMensajeEmpleado,0) = 0)
	BEGIN
		INSERT INTO Asistencia.tblMensajesEmpleados(IDEmpleado,FechaInicio,FechaFin,Mensaje)
		VALUES(@IDEmpleado,@FechaInicio,@FechaFin,@Mensaje)

		SET @IDMensajeEmpleado = @@IDENTITY

		
			select @NewJSON = a.JSON from [Asistencia].[tblMensajesEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDMensajeEmpleado = @IDMensajeEmpleado

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblMensajesEmpleados]','[Asistencia].[spUIMensajesEmpleados]','INSERT',@NewJSON,''
		
	END
	ELSE
	BEGIN
		select @OldJSON = a.JSON from [Asistencia].[tblMensajesEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDMensajeEmpleado = @IDMensajeEmpleado
		UPDATE Asistencia.tblMensajesEmpleados
			set FechaInicio = @FechaInicio,
				FechaFin = @FechaFin,
				Mensaje = @Mensaje
		Where IDMensajeEmpleado = @IDMensajeEmpleado

			
			select @NewJSON = a.JSON from [Asistencia].[tblMensajesEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDMensajeEmpleado = @IDMensajeEmpleado

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblMensajesEmpleados]','[Asistencia].[spUIMensajesEmpleados]','UDPATE',@NewJSON,@OldJSON
		
	END
	Exec Asistencia.spBuscarMensajeEmpleados @IDMensajeEmpleado,@IDEmpleado
END
GO

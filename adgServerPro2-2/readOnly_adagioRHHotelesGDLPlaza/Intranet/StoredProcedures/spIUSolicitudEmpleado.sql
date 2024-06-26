USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Intranet].[spIUSolicitudEmpleado](
	 @IDSolicitud int = 0
	,@IDEmpleado int 
	,@IDTipoSolicitud int 
	,@IDEstatusSolicitud int 
	,@IDIncidencia varchar(10) null 
	,@FechaIni Date null
	,@CantidadDias int null
	,@DiasDescanso Varchar(20) null
	,@ComentarioEmpleado Varchar(MAX) =''
	,@ComentarioSupervisor Varchar(MAX) =''
	,@CantidadMonto Decimal(18,2) null
	,@IDUsuarioAutoriza int null 
	,@IDUsuario int  
)
AS
BEGIN
	
	IF(@IDSolicitud = 0)
	BEGIN
		IF(@IDTipoSolicitud = 1 OR @IDTipoSolicitud = 2)
		BEGIN
				INSERT INTO Intranet.tblSolicitudesEmpleado(IDEmpleado, IDTipoSolicitud,IDEstatusSolicitud,IDIncidencia, FechaIni, CantidadDias,FechaCreacion,ComentarioEmpleado, DiasDescanso)
				VALUES(@IDEmpleado,@IDTipoSolicitud,@IDEstatusSolicitud,@IDIncidencia, @FechaIni, @CantidadDias,GETDATE(), @ComentarioEmpleado,@DiasDescanso)
				
				set @IDSolicitud = @@IDENTITY
		END
		IF(@IDTipoSolicitud = 3)
		BEGIN
				INSERT INTO Intranet.tblSolicitudesEmpleado(IDEmpleado, IDTipoSolicitud,IDEstatusSolicitud,ComentarioEmpleado,FechaCreacion)
				VALUES(@IDEmpleado, @IDTipoSolicitud,@IDEstatusSolicitud,@ComentarioEmpleado,GETDATE())
				
				set @IDSolicitud = @@IDENTITY
		END
		IF(@IDTipoSolicitud = 4)
		BEGIN
				INSERT INTO Intranet.tblSolicitudesEmpleado(IDEmpleado, IDTipoSolicitud,IDEstatusSolicitud,ComentarioEmpleado,FechaCreacion,CantidadMonto)
				VALUES(@IDEmpleado, @IDTipoSolicitud,@IDEstatusSolicitud,@ComentarioEmpleado,GETDATE(),@CantidadMonto)

				set @IDSolicitud = @@IDENTITY
		END

		EXEC [App].[INotificacionSolicitudIntranet]@IDSolicitud = @IDSolicitud, @TipoCambio ='CREATE-SUPERVISOR'
		EXEC [App].[INotificacionSolicitudIntranet]@IDSolicitud = @IDSolicitud, @TipoCambio ='CREATE-USUARIO'

	END
	ELSE
	BEGIN
		IF(@IDTipoSolicitud = 1 OR @IDTipoSolicitud = 2)
		BEGIN
				UPDATE Intranet.tblSolicitudesEmpleado
					SET IDEstatusSolicitud = @IDEstatusSolicitud
						,FechaIni = @FechaIni
						,CantidadDias = @CantidadDias
						,DiasDescanso = @DiasDescanso
						,ComentarioEmpleado = @ComentarioEmpleado
						,ComentarioSupervisor = @ComentarioSupervisor
				WHERE IDSolicitud = @IDSolicitud
					and IDEmpleado = @IDEmpleado

		END
		IF(@IDTipoSolicitud = 3)
		BEGIN
				UPDATE Intranet.tblSolicitudesEmpleado
					SET IDEstatusSolicitud = @IDEstatusSolicitud
						,ComentarioEmpleado = @ComentarioEmpleado
						,ComentarioSupervisor = @ComentarioSupervisor
				WHERE IDSolicitud = @IDSolicitud
					and IDEmpleado = @IDEmpleado
		END
		IF(@IDTipoSolicitud = 4)
		BEGIN
				UPDATE Intranet.tblSolicitudesEmpleado
					SET IDEstatusSolicitud = @IDEstatusSolicitud
					    ,CantidadMonto = @CantidadMonto
						,ComentarioEmpleado = @ComentarioEmpleado
						,ComentarioSupervisor = @ComentarioSupervisor
				WHERE IDSolicitud = @IDSolicitud
					and IDEmpleado = @IDEmpleado

		END	
		EXEC [App].[INotificacionSolicitudIntranet]@IDSolicitud = @IDSolicitud, @TipoCambio ='UPDATE-SUPERVISOR'
		EXEC [App].[INotificacionSolicitudIntranet]@IDSolicitud = @IDSolicitud, @TipoCambio ='UPDATE-USUARIO'
	END

		

	EXEC Intranet.spBuscarSolicitudesEmpleados @IDSolicitud = @IDSolicitud,@IDEmpleado = @IDEmpleado, @IDUsuario = @IDUsuario

END
GO

USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Intranet].[spAutorizarDeclinarSolicitudSupervisor]
(
	@IDSolicitud int,
	@IDEstatusSolicitud int,
	@IDUsuario int
)
AS
BEGIN
	DECLARE @IDTipoSolicitud int,
			@IDEmpleado int,
			@Fecha Date,
			@Duracion int,
			@DiasDescanso varchar(20),
			@IDIncidencia Varchar(10),
			@FechaFin date     
	Select @IDTipoSolicitud = IDTipoSolicitud 
			,@IDEmpleado = IDEmpleado
			,@Fecha = FechaIni
			,@Duracion = CantidadDias
			,@DiasDescanso = DiasDescanso 
			,@IDIncidencia = IDIncidencia 
			,@FechaFin = dateadd(day,isnull(CantidadDias,0)-1,isnull(FechaIni,getdate()))
	from Intranet.tblSolicitudesEmpleado 
	where IDSolicitud = @IDSolicitud
	
	BEGIN TRY  
		IF(@IDTipoSolicitud = 1 and @IDEstatusSolicitud = 2)
		BEGIN
		  exec	[Asistencia].[spIUVacacionesEmpleados] @IDEmpleado = @IDEmpleado, @Fecha = @Fecha, @Duracion= @Duracion, @DiasDescanso = @DiasDescanso, @IDUsuario = @IDUsuario
		  EXEC [App].[INotificacionSolicitudIntranet]@IDSolicitud = @IDSolicitud, @TipoCambio ='APROBADA-USUARIO'
		END
		IF(@IDTipoSolicitud = 2 and @IDEstatusSolicitud = 2)
		BEGIN
		 exec	[Asistencia].[spIUIncidenciaEmpleado]
				@IDIncidenciaEmpleado	= 0
				,@IDEmpleado = @IDEmpleado
				,@IDIncidencia	= @IDIncidencia
				,@FechaIni	= @Fecha
				,@FechaFin	= @FechaFin
				,@Dias		= '1,2,3,4,5,6,7'
				,@TiempoSugerido = '00:00:00.000'
				,@TiempoAutorizado =  '00:00:00.000'
				,@Comentario	= 'INTRANET AUTORIZACIÓN'
				,@ComentarioTextoPlano = 'INTRANET AUTORIZACIÓN'
				,@CreadoPorIDUsuario = @IDUsuario
				,@Autorizado	= 1
				,@ConfirmarActualizar = 0

		EXEC [App].[INotificacionSolicitudIntranet]@IDSolicitud = @IDSolicitud, @TipoCambio ='APROBADA-USUARIO'
		END
			UPDATE Intranet.tblSolicitudesEmpleado
				set IDEstatusSolicitud = @IDEstatusSolicitud,
					IDUsuarioAutoriza = @IDUsuario
			where IDSolicitud = @IDSolicitud
		
		IF(@IDEstatusSolicitud = 3)
		BEGIN
			  EXEC [App].[INotificacionSolicitudIntranet]@IDSolicitud = @IDSolicitud, @TipoCambio ='RECHAZADA-USUARIO'
		END
		
	END TRY  
	BEGIN CATCH  
		
	END CATCH  

END
GO

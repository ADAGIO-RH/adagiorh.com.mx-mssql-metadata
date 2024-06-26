USE [p_adagioRHMinutoAntes]
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


             BEGIN TRY
        BEGIN TRAN TransAutorizarDeclinarSolEmp     
            --SELECT 1/0;-- PROVOCAR EXCEPCIÓN  
          Select @IDTipoSolicitud = IDTipoSolicitud 
			,@IDEmpleado = IDEmpleado
			,@Fecha = FechaIni
			,@Duracion = CantidadDias
			,@DiasDescanso = DiasDescanso 
			,@IDIncidencia = IDIncidencia 
			,@FechaFin = dateadd(day,isnull(CantidadDias,0)-1,isnull(FechaIni,getdate()))
            from Intranet.tblSolicitudesEmpleado 
            where IDSolicitud = @IDSolicitud
            
            
            IF(@IDTipoSolicitud = 1 and @IDEstatusSolicitud = 2)
                BEGIN                    
                    exec	[Asistencia].[spIUVacacionesEmpleados] @IDEmpleado = @IDEmpleado, @Fecha = @Fecha, @Duracion= @Duracion, @DiasDescanso = @DiasDescanso, @IDUsuario = @IDUsuario,@Comentario=null   
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
                
        COMMIT TRAN TransAutorizarDeclinarSolEmp
    END TRY
    BEGIN CATCH    
        ROLLBACK TRAN TransAutorizarDeclinarSolEmp
        EXEC [App].[spObtenerError] @IDUsuario = 1, @CodigoError = '1700002'
    END CATCH	    	     
END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Intranet].[spAutorizarDeclinarSolicitudSupervisor]
(
	@IDSolicitud int,
	@IDEstatusSolicitud int,
	@IDUsuario int,
    @ConfirmarActualizar int = 0
)
AS
BEGIN
	DECLARE 
             @ID_TIPO_SOLICITUD_VACACIONES      INT = 1
            ,@ID_TIPO_SOLICITUD_PERMISOS        INT = 2
            ,@ID_ESTATUS_SOLICITUD_AUTORIZADA   INT = 2
            ,@ID_ESTATUS_SOLICITUD_RECHAZADA    INT = 3
            ,@TIPO_RESPUESTA_REGISTRO_CREADO    INT = 0
            ,@IDTipoSolicitud                   INT
			,@IDEmpleado                        INT
			,@Fecha                             DATE
			,@Duracion                          INT
			,@DiasDescanso                      VARCHAR(20)  
			,@IDIncidencia                      VARCHAR(10)
			,@FechaFin                          DATE
            ,@TipoRespuesta                     INT = 0

    
      

    
    BEGIN TRY
        BEGIN TRAN TransAutorizarDeclinarSolEmp     
            
          SELECT 
                 @IDTipoSolicitud  = IDTipoSolicitud 
			    ,@IDEmpleado       = IDEmpleado
			    ,@Fecha            = FechaIni
			    ,@Duracion         = CantidadDias
			    ,@DiasDescanso     = DiasDescanso 
			    ,@IDIncidencia     = IDIncidencia 
			    ,@FechaFin         = DATEADD(DAY,ISNULL(CantidadDias,0)-1,ISNULL(FechaIni,GETDATE()))
            FROM Intranet.tblSolicitudesEmpleado 
            WHERE IDSolicitud = @IDSolicitud
            
            
            IF(@IDTipoSolicitud = @ID_TIPO_SOLICITUD_VACACIONES and @IDEstatusSolicitud = @ID_ESTATUS_SOLICITUD_AUTORIZADA)
            BEGIN    

                EXEC [Asistencia].[spIUVacacionesEmpleados] 
                     @IDEmpleado   = @IDEmpleado 
                    ,@Fecha        = @Fecha
                    ,@Duracion     = @Duracion 
                    ,@DiasDescanso = @DiasDescanso
                    ,@ConfirmarActualizar     = @ConfirmarActualizar
                    ,@IDUsuario    = @IDUsuario                    
                    ,@Comentario   = NULL   
                    ,@TipoRespuesta           = @TipoRespuesta OUTPUT

            END

            IF(@IDTipoSolicitud = @ID_TIPO_SOLICITUD_PERMISOS AND @IDEstatusSolicitud = @ID_ESTATUS_SOLICITUD_AUTORIZADA)
            BEGIN        
                
               
                EXEC [Asistencia].[spIUIncidenciaEmpleado]
                        @IDIncidenciaEmpleado	  = 0
                        ,@IDEmpleado              = @IDEmpleado
                        ,@IDIncidencia	          = @IDIncidencia
                        ,@FechaIni	              = @Fecha
                        ,@FechaFin	              = @FechaFin
                        ,@Dias		              = '1,2,3,4,5,6,7'
                        ,@TiempoSugerido          = '00:00:00.000'
                        ,@TiempoAutorizado        = '00:00:00.000'
                        ,@Comentario	          = 'INTRANET AUTORIZACIÓN'
                        ,@ComentarioTextoPlano    = 'INTRANET AUTORIZACIÓN'
                        ,@CreadoPorIDUsuario      = @IDUsuario
                        ,@Autorizado	          = 1
                        ,@ConfirmarActualizar     = @ConfirmarActualizar
                        ,@TipoRespuesta           = @TipoRespuesta OUTPUT
                        

                        
                    
            END
            
            IF(@IDEstatusSolicitud = @ID_ESTATUS_SOLICITUD_AUTORIZADA AND @TipoRespuesta=@TIPO_RESPUESTA_REGISTRO_CREADO )
            BEGIN
                EXEC [App].[INotificacionSolicitudIntranet] @IDSolicitud = @IDSolicitud, @TipoCambio ='APROBADA-USUARIO'
            END

            IF(@IDEstatusSolicitud = @ID_ESTATUS_SOLICITUD_RECHAZADA)
            BEGIN
                EXEC [App].[INotificacionSolicitudIntranet] @IDSolicitud = @IDSolicitud, @TipoCambio ='RECHAZADA-USUARIO'
            END
                            

            IF (@TipoRespuesta=@TIPO_RESPUESTA_REGISTRO_CREADO)
            BEGIN  

                UPDATE Intranet.tblSolicitudesEmpleado
                SET IDEstatusSolicitud = @IDEstatusSolicitud
                   ,IDUsuarioAutoriza = @IDUsuario
                WHERE IDSolicitud = @IDSolicitud

                SELECT 
                        0                                    AS ID
			           ,0                                    AS TipoEvento
			           ,'Registro actualizado correctamente' AS Mensaje
			           ,0                                    AS TipoRespuesta

            END
            
                                        
        
        COMMIT TRAN TransAutorizarDeclinarSolEmp
    END TRY
    BEGIN CATCH    
        ROLLBACK TRAN TransAutorizarDeclinarSolEmp
        
        DECLARE @Error varchar(max);
        SELECT @Error=ERROR_MESSAGE();

        EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1700002',@CustomMessage=@Error        
    END CATCH	    	     
END
GO

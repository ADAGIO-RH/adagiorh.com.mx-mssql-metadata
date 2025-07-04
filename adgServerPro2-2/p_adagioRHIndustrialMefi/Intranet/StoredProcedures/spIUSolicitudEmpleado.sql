USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Crea y actualiza Solicitudes de intranet
** Autor			: Jose Roman
** Email			: jroman@adagio.com.mx
** FechaCreacion	: 2018-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
------------------- ------------------- ------------------------------------------------------------
2022-04-01			Emmanuel Contreras	Se agregó FechaFin y se hace el calculo para guardar cuando 
										terminará la solicitud 

EXEC [Intranet].[spIUSolicitudEmpleado]1,390,1,2,null,'2022-02-03',7,'1,7,' ,'','',null,1 ,1
------------------- ------------------- ------------------------------------------------------------
2022-04-06			Emmanuel Contreras	Se agrego campo DiasDisponibles a la tabla 
										Intranet.tblSolicitudesEmpleado y se calculan los días que 
										quedan disponibles al momento de solicitar vacaciones/permisos
------------------- ------------------- ------------------------------------------------------------
2022-04-08          Andrea Zainos       Se agrega el campo IDIncidencia en la actualizacion de los datos
------------------- ------------------- ------------------------------------------------------------
2022-05-08          Jose Vargas         Se remplazo el raiseerror por [App].[spObtenerError]
------------------- ------------------- ------------------------------------------------------------
2022-12-05          Jose Roman          Implementación de Procedimiento de Validaciones por tipo de Solicitud.
------------------- ------------------- ------------------------------------------------------------
2024-02-19          Javier Peña         Eliminación de valores magicos y codigo repetido, se modifica parametro de entrada
                                        [Asistencia].[spBuscarSaldosVacacionesPorAnios] para el proporcional ya que siempre lo mandaba como 1
***************************************************************************************************/
CREATE   PROCEDURE [Intranet].[spIUSolicitudEmpleado] (
	@IDSolicitud INT = 0
	,@IDEmpleado INT
	,@IDTipoSolicitud INT
	,@IDEstatusSolicitud INT
	,@IDIncidencia VARCHAR(10) = NULL
	,@FechaIni DATE = NULL
	,@CantidadDias INT = NULL
	,@DiasDescanso VARCHAR(20) = NULL
	,@ComentarioEmpleado VARCHAR(MAX) = ''
	,@ComentarioSupervisor VARCHAR(MAX) = ''
	,@CantidadMonto DECIMAL(18, 2) = NULL
	,@IDUsuarioAutoriza INT = NULL
	,@IDUsuario INT = NULL
)
AS
BEGIN

	DECLARE 
		@FechaFinCalculo DATE = NULL
		,@SPValidaciones Varchar(255) = NULL
		,@ERROR VARCHAR(MAX)
		,@tblTempVacaciones [Asistencia].[dtSaldosDeVacaciones]
        ,@DiasDisponibles INT = 0
        ,@AccionSupervisor VARCHAR(25) = CASE WHEN @IDSolicitud=0 THEN 'CREATE-SUPERVISOR' ELSE 'UPDATE-SUPERVISOR' END
        ,@AccionUsuario    VARCHAR(25) = CASE WHEN @IDSolicitud=0 THEN 'CREATE-USUARIO' ELSE 'UPDATE-USUARIO' END
        ,@ID_TIPO_SOLICITUD_VACACIONES INT = 1
        ,@ID_TIPO_SOLICITUD_PERMISOS   INT = 2
        ,@ID_TIPO_SOLICITUD_ACTUALIZACION_DATOS INT = 3        
	;


    
    BEGIN TRY
        BEGIN TRAN TransIUSolicitudEmpleado                   
             
			SELECT @SPValidaciones = SPValidaciones FROM Intranet.tblCatTipoSolicitud with(nolock) where IDTipoSolicitud = @IDTipoSolicitud

			IF(isnull(@SPValidaciones,'') <> '') 
			BEGIN
				exec sp_executesql N'exec @miSP @IDSolicitud,@IDEmpleado ,@IDTipoSolicitud ,@IDEstatusSolicitud ,@IDIncidencia ,@FechaIni ,@CantidadDias,@DiasDescanso ,@ComentarioEmpleado	,@ComentarioSupervisor ,@CantidadMonto	,@IDUsuarioAutoriza ,@IDUsuario'                   
					,N' @IDSolicitud INT
						,@IDEmpleado INT
						,@IDTipoSolicitud INT
						,@IDEstatusSolicitud INT
						,@IDIncidencia VARCHAR(10) NULL
						,@FechaIni DATE NULL
						,@CantidadDias INT NULL
						,@DiasDescanso VARCHAR(20) NULL
						,@ComentarioEmpleado VARCHAR(MAX) 
						,@ComentarioSupervisor VARCHAR(MAX)
						,@CantidadMonto DECIMAL(18, 2) 
						,@IDUsuarioAutoriza INT
						,@IDUsuario INT
						,@miSP varchar(MAX)',                          
					     @IDSolicitud = @IDSolicitud
						,@IDEmpleado = @IDEmpleado
						,@IDTipoSolicitud = @IDTipoSolicitud
						,@IDEstatusSolicitud = @IDEstatusSolicitud
						,@IDIncidencia = @IDIncidencia
						,@FechaIni = @FechaIni
						,@CantidadDias = @CantidadDias
						,@DiasDescanso = @DiasDescanso
						,@ComentarioEmpleado = @ComentarioEmpleado
						,@ComentarioSupervisor = @ComentarioSupervisor
						,@CantidadMonto = @CantidadMonto
						,@IDUsuarioAutoriza = @IDUsuarioAutoriza
						,@IDUsuario = @IDUsuario     
						,@miSP = @SPValidaciones ; 
			END
		
			IF(@IDTipoSolicitud = @ID_TIPO_SOLICITUD_VACACIONES OR @IDTipoSolicitud = @ID_TIPO_SOLICITUD_PERMISOS)
			BEGIN
				                    
                  EXEC [Asistencia].[spFechaFinVacacionesOutPut] 
                         @IDEmpleado = @IDEmpleado
						,@Fecha = @FechaIni
						,@Duracion = @CantidadDias
						,@DiasDescanso = @DiasDescanso
						,@IDUsuario = @IDUsuario
						,@FechaFinCalculo = @FechaFinCalculo OUT

                    DELETE FROM @tblTempVacaciones
                    
                    IF(@IDTipoSolicitud = @ID_TIPO_SOLICITUD_VACACIONES)
                    BEGIN
                        INSERT INTO @tblTempVacaciones
                        
                        EXEC [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado,NULL,@FechaIni,@IDUsuario

                        SELECT @DiasDisponibles = floor(sum(DiasDisponibles)) FROM @tblTempVacaciones                    										
                    END
                                    
                    
			END
            IF(@IDTipoSolicitud = @ID_TIPO_SOLICITUD_ACTUALIZACION_DATOS)
            BEGIN
                    SET @FechaIni = GETDATE()
                    SET @DiasDisponibles = NULL
            END

            IF(@IDSolicitud = 0)
			BEGIN
				    INSERT INTO Intranet.tblSolicitudesEmpleado (
				    	IDEmpleado
				    	,IDTipoSolicitud
				    	,IDEstatusSolicitud
				    	,IDIncidencia
				    	,FechaIni
				    	,CantidadDias
				    	,FechaCreacion
				    	,ComentarioEmpleado
				    	,DiasDescanso
				    	,FechaFin
				    	,DiasDisponibles
				    )
				    VALUES (
				    	@IDEmpleado
				    	,@IDTipoSolicitud
				    	,@IDEstatusSolicitud
				    	,@IDIncidencia
				    	,@FechaIni
				    	,@CantidadDias
				    	,GETDATE()
				    	,@ComentarioEmpleado
				    	,@DiasDescanso
				    	,@FechaFinCalculo
				    	,@DiasDisponibles
				    )

				    SET @IDSolicitud = @@IDENTITY					
                
			END
			ELSE 
			BEGIN
				    UPDATE Intranet.tblSolicitudesEmpleado
				    SET IDEstatusSolicitud = @IDEstatusSolicitud
				       ,FechaIni = @FechaIni
				       ,CantidadDias = @CantidadDias
				       ,DiasDescanso = @DiasDescanso
				       ,ComentarioEmpleado = @ComentarioEmpleado
				       ,ComentarioSupervisor = @ComentarioSupervisor
				       ,IDIncidencia = @IDIncidencia
				    WHERE IDSolicitud = @IDSolicitud
				    AND IDEmpleado = @IDEmpleado					
			END

	        EXEC [App].[INotificacionSolicitudIntranet] @IDSolicitud = @IDSolicitud, @TipoCambio = @AccionSupervisor
						
			EXEC [App].[INotificacionSolicitudIntranet] @IDSolicitud = @IDSolicitud, @TipoCambio = @AccionUsuario
						
		
		   EXEC Intranet.spBuscarSolicitudesEmpleados 
                     @IDSolicitud = @IDSolicitud
					,@IDEmpleado = @IDEmpleado
					,@IDUsuario = @IDUsuario

        COMMIT TRAN TransIUSolicitudEmpleado
    END TRY
    BEGIN CATCH    
        ROLLBACK TRAN TransIUSolicitudEmpleado
			SET @ERROR = ERROR_MESSAGE ( )  
        EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1700002', @CustomMessage= @ERROR
    END CATCH	 
	
END
GO

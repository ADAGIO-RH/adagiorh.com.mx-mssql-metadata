USE [p_adagioRHMinutoAntes]
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
***************************************************************************************************/
CREATE PROCEDURE [Intranet].[spIUSolicitudEmpleado] (
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
	;


    BEGIN TRY
        BEGIN TRAN TransIUSolicitudEmpleado                   
            --SELECT 1/0;-- PROVOCAR EXCEPCIÓN  
            IF object_id('tempdb..#tblFechaFin') IS NOT NULL
                DROP TABLE #tblFechaFin;

            CREATE TABLE #tblFechaFin (Fecha DATE);

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
		
			IF(@IDTipoSolicitud in (1,2)) -- VACACIONES O PERMISOS
			BEGIN
				  EXEC [Asistencia].[spFechaFinVacacionesOutPut] @IDEmpleado = @IDEmpleado
						,@Fecha = @FechaIni
						,@Duracion = @CantidadDias
						,@DiasDescanso = @DiasDescanso
						,@IDUsuario = @IDUsuario
						,@FechaFinCalculo = @FechaFinCalculo OUT

					 DECLARE @tempResponse AS TABLE (
						ID INT
						,IDIncidenciaSaldo INT
						,IDIncidencia VARCHAR(10)
						,Descripcion VARCHAR(255)
						,FechaInicio DATE
						,FechaFin DATE
						,FechaRegistro DATETIME
						,Cantidad INT
						,IncTomadas INT
						,IncVencidas INT
						,IncDisponibles INT
						,TotalPaginas INT
					);

				
                    DECLARE @DiasDisponibles INT = 0                   

                    DELETE
                    FROM @tblTempVacaciones

                    INSERT INTO @tblTempVacaciones
                    EXEC [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado
                        ,1
                        ,@FechaIni
                        ,@IDUsuario

                    SELECT @DiasDisponibles = floor(sum(DiasDisponibles))
                    FROM @tblTempVacaciones

					--INSERT SOLICITUD VACACIONES PERMISOS
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

						EXEC [App].[INotificacionSolicitudIntranet] @IDSolicitud = @IDSolicitud
						,@TipoCambio = 'CREATE-SUPERVISOR'

						EXEC [App].[INotificacionSolicitudIntranet] @IDSolicitud = @IDSolicitud
						,@TipoCambio = 'CREATE-USUARIO'

					END
					ELSE --UPDATE SOLICITUD VACACIONES PERMISOS
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

						EXEC [App].[INotificacionSolicitudIntranet] @IDSolicitud = @IDSolicitud
							,@TipoCambio = 'UPDATE-SUPERVISOR'

						EXEC [App].[INotificacionSolicitudIntranet] @IDSolicitud = @IDSolicitud
							,@TipoCambio = 'UPDATE-USUARIO'

					END
			END


			IF (@IDTipoSolicitud = 3)
			BEGIN
				IF(@IDSolicitud = 0)
				BEGIN
					  INSERT INTO Intranet.tblSolicitudesEmpleado (
                        IDEmpleado
                        ,IDTipoSolicitud
                        ,IDEstatusSolicitud
                        ,FechaIni
                        ,ComentarioEmpleado
                        ,FechaCreacion
                        )
                    VALUES (
                        @IDEmpleado
                        ,@IDTipoSolicitud
                        ,@IDEstatusSolicitud
                        ,GETDATE()
                        ,@ComentarioEmpleado
                        ,GETDATE()
                    )

					SET @IDSolicitud = @@IDENTITY
					EXEC [App].[INotificacionSolicitudIntranet] @IDSolicitud = @IDSolicitud
						,@TipoCambio = 'CREATE-SUPERVISOR'

					EXEC [App].[INotificacionSolicitudIntranet] @IDSolicitud = @IDSolicitud
					,@TipoCambio = 'CREATE-USUARIO'
				END
				ELSE
				BEGIN
					UPDATE Intranet.tblSolicitudesEmpleado
					SET IDEstatusSolicitud = @IDEstatusSolicitud
						,ComentarioEmpleado = @ComentarioEmpleado
						,ComentarioSupervisor = @ComentarioSupervisor
					WHERE IDSolicitud = @IDSolicitud
						AND IDEmpleado = @IDEmpleado
					
					EXEC [App].[INotificacionSolicitudIntranet] @IDSolicitud = @IDSolicitud
						,@TipoCambio = 'UPDATE-SUPERVISOR'

					EXEC [App].[INotificacionSolicitudIntranet] @IDSolicitud = @IDSolicitud
						,@TipoCambio = 'UPDATE-USUARIO'	
				END
			END

		   EXEC Intranet.spBuscarSolicitudesEmpleados @IDSolicitud = @IDSolicitud
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

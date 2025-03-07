USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Procedimiento para Manejar las Validaciones para Vacaciones y permisos
** Autor			: Jose Roman
** Email			: jroman@adagio.com.mx
** FechaCreacion	: 2022-09-27
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto				¿Qué cambió?
2023-07-06		Víctor Martínez				Se agrega validación para incidencia PTO.
------------------- ------------------- ------------------------------------------------------------
****************************************************************************************************/
CREATE PROCEDURE [Intranet].[spValidacionesSolicitudVacacionesPermisos](
	@IDSolicitud INT = 0
	,@IDEmpleado INT
	,@IDTipoSolicitud INT
	,@IDEstatusSolicitud INT
	,@IDIncidencia VARCHAR(10) NULL
	,@FechaIni DATE NULL
	,@CantidadDias INT NULL
	,@DiasDescanso VARCHAR(20) NULL
	,@ComentarioEmpleado VARCHAR(MAX) = ''
	,@ComentarioSupervisor VARCHAR(MAX) = ''
	,@CantidadMonto DECIMAL(18, 2) = NULL
	,@IDUsuarioAutoriza INT = NULL
	,@IDUsuario INT = NULL
)
AS
BEGIN
	PRINT 'DENTRO DE VALIDACIONES'
	IF (@IDTipoSolicitud = 1)
	BEGIN
		IF (
				(
					SELECT Sum(cast(item AS INT))
					FROM App.split(@DiasDescanso, ',')
					) = 28
				)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario
				,@CodigoError = '0611003'

			RETURN
		END
	END

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

	IF ((SELECT isnull(AdministrarSaldos, 0) FROM Asistencia.tblCatIncidencias WHERE IDIncidencia = @IDIncidencia) = 1)
		BEGIN
			INSERT @tempResponse (
				ID
				,IDIncidenciaSaldo
				,IDIncidencia
				,Descripcion
				,FechaInicio
				,FechaFin
				,FechaRegistro
				,Cantidad
				,IncTomadas
				,IncVencidas
				,IncDisponibles
				,TotalPaginas
				)
			EXEC [Asistencia].[spBuscarIncidenciasSaldos] @IDIncidenciaSaldo = 0
				,@IDEmpleado = @IDEmpleado
				,@IDIncidencia = @IDIncidencia
				,@IDUsuario = @IDUsuario

			-------------------------------------------------------- Validación PTO --------------------------------------------------------
			IF @IDIncidencia = 'PTO'
			BEGIN
				DECLARE @Vacaciones INT = 0
						,@Message varchar(max) = 'No puedes tomar PAID TIME OFF si aún tienes vacaciones disponibles.'
                        ,@tblVacaciones [Asistencia].[dtSaldosDeVacaciones]
					;

				

                    	
				DELETE FROM @tblVacaciones
                
				INSERT INTO @tblVacaciones EXEC [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado = @IDEmpleado, @Proporcional = NULL, @FechaBaja = @FechaIni, @IDUsuario	= @IDUsuario
                
				SELECT @Vacaciones = floor(sum(DiasDisponibles)) FROM @tblVacaciones

				IF(@Vacaciones > 0)
				BEGIN
					set @Message = coalesce(@Message,'');    
						raiserror(@Message,16,1);  
					RETURN;
				END
			END
			--------------------------------------------------------------------------------------------------------------------------------

			IF NOT EXISTS (
					SELECT TOP 1 1
					FROM @tempResponse
					WHERE @FechaIni BETWEEN FechaInicio
							AND FechaFin
						AND IncDisponibles >= @CantidadDias
					)
			BEGIN
				EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario
					,@CodigoError = '0611004'

				RETURN
			END
		END
	
	IF(@IDTipoSolicitud = 1)
	BEGIN
		DECLARE @DiasDisponibles INT = 0
			DECLARE @tblTempVacaciones [Asistencia].[dtSaldosDeVacaciones]

			DELETE
			FROM @tblTempVacaciones

			INSERT INTO @tblTempVacaciones
			EXEC [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado
				,NULL
				,@FechaIni
				,@IDUsuario

			SELECT @DiasDisponibles = floor(sum(DiasDisponibles))
			FROM @tblTempVacaciones

			IF(@DiasDisponibles < @CantidadDias)
			BEGIN
				EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario
					,@CodigoError = '0611004'
				RETURN;
			END
			
	END
END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Resetea evaluaciones contestadas, esto se ejecuta al momento de excluir un colaborador.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-08-27
** Paremetros		: @IDProyecto			Identificador del proyecto
**					: @IDEmpleado			Identificador del empleado a evaluar
**					: @IDEmpleadoProyecto	Identificador del empleado en proyecto
**					: @IDUsuario			Identificador del usuario
** IDAzure			: 

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROCEDURE [Evaluacion360].[spResetEvaluaciones](
	@IDProyecto			INT,
	@IDEmpleado			INT,
	@IDEmpleadoProyecto INT,
	@IDUsuario			INT
) AS
	
	BEGIN
		
		-- VERIFICAMOS SI EL PROYECTO PUEDE SER MODIFICADO
		BEGIN TRY
			EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario
		END TRY
		BEGIN CATCH	
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
			RETURN 0;
		END CATCH


		-- INICIAR LA TRANSACCIÓN
		BEGIN TRANSACTION;

			BEGIN TRY
		
				DECLARE @contador INT = 1
						, @totalRow INT = 0
						, @EVALUADOR_ASIGNADO INT = 11
						, @EN_PROCESO INT = 12
						, @COMPLETA INT = 13
						, @ASIGNADO_PRUEBA_FINAL INT = 4
						, @ESCALA_INDIVIDUAL INT = 3
						;
		
				DECLARE @tblEvaluacionesDetalle TABLE
				(
					IDRow					INT IDENTITY(1,1)
					, IDProyecto			INT
					, TipoFiltro			VARCHAR(255)
					, Cuenta				VARCHAR(50)
					, IDEmpleado			INT
					, ClaveEmpleado			VARCHAR(20)
					, Evaluado				VARCHAR(255)
					, IDGrupo				INT
					, TipoReferenciaGrupo	INT
					, IDReferenciaGrupo		INT
					, IDTipoPreguntaGrupo	INT
					, CuentaEvaluador		VARCHAR(50)
					, IDEvaluador			INT
					, ClaveEvaluador		VARCHAR(20)
					, Evaluador				VARCHAR(255)
					, IDEvaluacionEmpleado	INT
					, IDEmpleadoProyecto	INT
					, IDTipoEvaluacion		INT
					, TipoEvaluacion		VARCHAR(255)
				)

				DECLARE @tblEvaluacionesAgrupadas TABLE
				(
					IDRow					INT IDENTITY(1,1)
					, IDEvaluacionEmpleado	INT
				)

				DECLARE @tblGruposInvolucrados TABLE
				(
					IDGrupo					INT
					, IDTipoPreguntaGrupo	INT
				)



				-- OBTENEMOS EL DETALLE DE LAS EVALUACIONES DEL COLABORADOR A EXCLUIR.
				INSERT INTO @tblEvaluacionesDetalle
				SELECT P.IDProyecto
						, EP.TipoFiltro
						, UE.Cuenta
						, E.IDEmpleado
						, E.ClaveEmpleado
						, E.NOMBRECOMPLETO AS Evaluado
						, G.IDGrupo
						, G.TipoReferencia AS TipoReferenciaGrupo
						, G.IDReferencia AS IDReferenciaGrupo
						, G.IDTipoPreguntaGrupo
						, UV.Cuenta AS CuentaEvaluador
						, EE.IDEvaluador
						, EV.ClaveEmpleado AS ClaveEvaluador
						, EV.NOMBRECOMPLETO AS Evaluador
						, EE.IDEvaluacionEmpleado
						, EE.IDEmpleadoProyecto
						, ISNULL(TE.IDTipoEvaluacion, -1) AS IDTipoEvaluacion
						, ISNULL(JSON_VALUE(TE.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE('esmx', '-', '')) + '', 'Nombre')), 'GENERAL') AS TipoEvaluacion
				FROM Evaluacion360.tblCatProyectos P
					LEFT JOIN Evaluacion360.tblEmpleadosProyectos EP ON P.IDProyecto = EP.IDProyecto
					LEFT JOIN RH.tblEmpleadosMaster E ON EP.IDEmpleado = E.IDEmpleado
					LEFT JOIN Evaluacion360.tblEvaluacionesEmpleados EE ON EP.IDEmpleadoProyecto = EE.IDEmpleadoProyecto
					LEFT JOIN RH.tblEmpleadosMaster EV ON EE.IDEvaluador = EV.IDEmpleado
					LEFT JOIN Evaluacion360.tblCatGrupos G ON EE.IDEvaluacionEmpleado = G.IDReferencia
					LEFT JOIN Seguridad.tblUsuarios UE ON E.IDEmpleado = UE.IDEmpleado
					LEFT JOIN Seguridad.tblUsuarios UV ON EE.IDEvaluador = UV.IDEmpleado
					LEFT JOIN Evaluacion360.tblCatTiposEvaluaciones TE ON TE.IDTipoEvaluacion = EE.IDTipoEvaluacion 
				WHERE P.IDProyecto = @IDProyecto
						AND E.IDEmpleado = @IDEmpleado
						AND EE.IDEmpleadoProyecto = @IDEmpleadoProyecto						
				ORDER BY EE.IDEmpleadoProyecto, EE.IDEvaluacionEmpleado, G.IDGrupo, E.IDEmpleado
				--SELECT * FROM @tblEvaluacionesDetalle



				-- AGRUPAMOS LOS IDENTIFICADORES DE LAS EVALUACIONES (IDEvaluacionEmpleado) DEL COLABORADOR A EXCLUIR.
				INSERT INTO @tblEvaluacionesAgrupadas
				SELECT IDEvaluacionEmpleado
				FROM @tblEvaluacionesDetalle
				WHERE IDGrupo IS NOT NULL
				GROUP BY IDEvaluacionEmpleado
				--SELECT * FROM @tblEvaluacionesAgrupadas



				-- OBTENEMOS EL TOTAL DE EVALUACIONES
				SELECT @totalRow = COUNT(*) FROM @tblEvaluacionesAgrupadas
				
				-- COMENZAMOS CON EL PROCESO DE RESETEO POR CADA EVALUACIÓN
				WHILE @contador <= @totalRow
					BEGIN

						DECLARE @IDEvaluacionEmpleado INT = 0;

						SELECT @IDEvaluacionEmpleado = IDEvaluacionEmpleado FROM @tblEvaluacionesAgrupadas WHERE IDRow = @contador;
						
						-- VERIFICAMOS QUE LA EVALUACION EXISTA
						IF(@IDEvaluacionEmpleado > 0)
							BEGIN								
								
								-- LIMPIAMOS TABLA
								DELETE FROM @tblGruposInvolucrados;

								-- OBTENEMOS LOS GRUPOS INVOLUCRADOS DE LAS EVALUACIONES DEL COLABORADOR A EXCLUIR
								INSERT INTO @tblGruposInvolucrados
								SELECT IDGrupo
										, IDTipoPreguntaGrupo
								FROM @tblEvaluacionesDetalle
								WHERE IDProyecto = @IDProyecto
										AND IDEmpleado = @IDEmpleado
										AND IDEmpleadoProyecto = @IDEmpleadoProyecto
										AND IDEvaluacionEmpleado = @IDEvaluacionEmpleado
										AND TipoReferenciaGrupo = @ASIGNADO_PRUEBA_FINAL
										AND IDReferenciaGrupo = @IDEvaluacionEmpleado
								--SELECT * FROM @tblGruposInvolucrados

								
								/* -----------------------------------------------------------------------------------------------------------------*/


								-- ELIMINAMOS LAS RESPUESTAS DEL CLIMA LABORAL (REPORTE SATISFACCION GENERAL)

								--SELECT CL.*
								--FROM @tblGruposInvolucrados G
								--	JOIN InfoDir.tblRespuestasNormalizadasClimaLaboral CL ON G.IDGrupo = CL.IDGrupo

								DELETE InfoDir.tblRespuestasNormalizadasClimaLaboral
								FROM @tblGruposInvolucrados G
									JOIN InfoDir.tblRespuestasNormalizadasClimaLaboral CL ON G.IDGrupo = CL.IDGrupo


								/* -----------------------------------------------------------------------------------------------------------------*/


								-- ELIMINAMOS LOS COMENTARIOS DE LAS PREGUNTAS

								--SELECT CP.*
								--FROM @tblGruposInvolucrados G
								--	JOIN Evaluacion360.tblCatPreguntas P ON G.IDGrupo = P.IDGrupo
								--	JOIN Evaluacion360.tblComentariosPregunta CP ON P.IDPregunta = CP.IDPregunta	

								DELETE Evaluacion360.tblComentariosPregunta
								FROM @tblGruposInvolucrados G
									JOIN Evaluacion360.tblCatPreguntas P ON G.IDGrupo = P.IDGrupo
									JOIN Evaluacion360.tblComentariosPregunta CP ON P.IDPregunta = CP.IDPregunta
									

								/* -----------------------------------------------------------------------------------------------------------------*/


								-- ELIMINAMOS LAS RESPUESTAS DE LAS PREGUNTAS

								--SELECT RP.*
								--FROM @tblGruposInvolucrados G
								--	JOIN Evaluacion360.tblCatPreguntas P ON G.IDGrupo = P.IDGrupo
								--	JOIN Evaluacion360.tblRespuestasPreguntas RP ON P.IDPregunta = RP.IDPregunta

								DELETE Evaluacion360.tblRespuestasPreguntas
								FROM @tblGruposInvolucrados G
									JOIN Evaluacion360.tblCatPreguntas P ON G.IDGrupo = P.IDGrupo
									JOIN Evaluacion360.tblRespuestasPreguntas RP ON P.IDPregunta = RP.IDPregunta


								/* -----------------------------------------------------------------------------------------------------------------*/

															
								-- ELIMINAMOS LAS PREGUNTAS

								--SELECT P.*
								--FROM @tblGruposInvolucrados G
								--	JOIN Evaluacion360.tblCatPreguntas P ON G.IDGrupo = P.IDGrupo	

								DELETE Evaluacion360.tblCatPreguntas
								FROM @tblGruposInvolucrados G
									JOIN Evaluacion360.tblCatPreguntas P ON G.IDGrupo = P.IDGrupo		
									

								/* -----------------------------------------------------------------------------------------------------------------*/
								
								
								-- ELIMINA LA ESCALA DE VALORACION DE LOS TIPOS DE GRUPO DE ESCALA INDIVIDUAL

								--SELECT E.*
								--FROM @tblGruposInvolucrados G
								--	JOIN Evaluacion360.tblEscalasValoracionesGrupos E ON G.IDGrupo = E.IDGrupo
								--WHERE G.IDTipoPreguntaGrupo = @ESCALA_INDIVIDUAL

								DELETE Evaluacion360.tblEscalasValoracionesGrupos
								FROM @tblGruposInvolucrados G
									JOIN Evaluacion360.tblEscalasValoracionesGrupos E ON G.IDGrupo = E.IDGrupo
								WHERE G.IDTipoPreguntaGrupo = @ESCALA_INDIVIDUAL


								/* -----------------------------------------------------------------------------------------------------------------*/
								
								
								-- ELIMINAMOS LOS GRUPOS

								--SELECT GR.*
								--FROM @tblGruposInvolucrados G
								--	JOIN Evaluacion360.tblCatGrupos GR ON G.IDGrupo = GR.IDGrupo

								DELETE Evaluacion360.tblCatGrupos
								FROM @tblGruposInvolucrados G
									JOIN Evaluacion360.tblCatGrupos GR ON G.IDGrupo = GR.IDGrupo


								/* -----------------------------------------------------------------------------------------------------------------*/
								

								-- ELIMINAMOS LOS ESTATUS DE LA EVALUACION DEL EMPLEADO (EVALUADOR ASIGNADO, EN PROCESO, COMPLETA)
								
								--SELECT * 
								--FROM Evaluacion360.tblEstatusEvaluacionEmpleado
								--WHERE IDEvaluacionEmpleado = @IDEvaluacionEmpleado 
								--		AND IDEstatus IN (@EVALUADOR_ASIGNADO, @EN_PROCESO, @COMPLETA)
								
								DELETE Evaluacion360.tblEstatusEvaluacionEmpleado
								WHERE IDEvaluacionEmpleado = @IDEvaluacionEmpleado 
										AND IDEstatus IN (@EVALUADOR_ASIGNADO, @EN_PROCESO, @COMPLETA)


								/* -----------------------------------------------------------------------------------------------------------------*/
								

								-- RESETEAMOS LA EVALUACION DEL EMPLEADO

								--SELECT * 
								--FROM Evaluacion360.tblEvaluacionesEmpleados
								--WHERE IDEvaluacionEmpleado = @IDEvaluacionEmpleado
								
								UPDATE Evaluacion360.tblEvaluacionesEmpleados
								SET TotalPreguntas = 0
									, TotalPreguntasRespondidas = 0
									, Progreso = 0									
									, Promedio = NULL
									, Porcentaje = NULL
								WHERE IDEvaluacionEmpleado = @IDEvaluacionEmpleado


								/* -----------------------------------------------------------------------------------------------------------------*/
								

							END					
			
						SET @contador = @contador + 1;

					END;
				

				-- SI TODA VA BIEN, SE CONFIRMA LA TRANSACCIÓN
				COMMIT TRANSACTION;

			END TRY
			BEGIN CATCH
				-- SI OCURRE UN ERROR, SE REALIZA EL ROLLBACK
				ROLLBACK TRANSACTION;

				-- MANEJO DE ERRORES: DEVOLVER ERROR
				THROW;

			END CATCH;

	END;
GO

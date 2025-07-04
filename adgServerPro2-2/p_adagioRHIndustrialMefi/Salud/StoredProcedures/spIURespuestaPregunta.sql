USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [Salud].[spIURespuestaPregunta](
	@dtRespuestas [Salud].[dtRespuestaPregunta] READONLY
	,@IDUsuario int )
as
	DECLARE @IDCuestionarioEmpleado int = 0
			,@IDPruebaEmpleado int = 0
			,@IDCuestionario int = 0
	;
	
	select top 1 @IDCuestionarioEmpleado = IDCuestionarioEmpleado from @dtRespuestas
	select top 1 @IDCuestionario = IDCuestionario from Salud.tblCuestionarios where TipoReferencia = 2 and IDReferencia =@IDCuestionarioEmpleado
	IF object_id('tempdb..#tmpPreguntasPruebas') IS NOT NULL DROP TABLE #tmpPreguntasPruebas;
	IF object_id('tempdb..#tmpRespuestasCalificadas') IS NOT NULL DROP TABLE #tmpRespuestasCalificadas;

	select p.*, ValorFinal =  case 
								when isnull(cp.Calificar,0) = 1 then 
										case 
											when cp.IDTipoPregunta = 1 then 
												(select top 1 prp.Valor
													 from App.Split(p.Respuesta,',') as posiblesRespuestas
														join Salud.tblPosiblesRespuestasPreguntas prp on cast(posiblesRespuestas.item as int) = prp.IDPosibleRespuesta 
													 )		-- OPCIÓN MÚLTIPLE
											when cp.IDTipoPregunta = 2 then					-- CASILLAS DE VERIFICACIÓN (Promedio de posibles respuestas)
												(select sum(prp.Valor)
												 from App.Split(p.Respuesta,',') as posiblesRespuestas
													join Salud.tblPosiblesRespuestasPreguntas prp on cast(posiblesRespuestas.item as int) = prp.IDPosibleRespuesta 
												 )
											when cp.IDTipoPregunta in (3,4,6,7) then 0			-- 3 VALORACIÓN CON ESTRELLAS - 4 CUADRO DE TEXTO SIMPLE - 6 - CONTROL DESLIZANTE (No requiere nunca Calificación numérica) - 7 FECHA/HORA
											when cp.IDTipoPregunta = 5 then 					-- MENÚ DESPLEGABLE
												(select top 1 prp.Valor
												 from App.Split(p.Respuesta,',') as posiblesRespuestas
													join Salud.tblPosiblesRespuestasPreguntas prp on cast(posiblesRespuestas.item as int) = prp.IDPosibleRespuesta 
												 )
										else 0 end
							else 0.0 end
	INTO #tmpRespuestasCalificadas
	from @dtRespuestas p
		join Salud.tblPreguntas cp on p.IDPregunta = cp.IDPregunta
	where Respuesta is not null
	
	MERGE [Salud].[tblRespuestasPreguntas] AS TARGET
	USING (select *
			from #tmpRespuestasCalificadas
			where Respuesta is not null
			) as SOURCE
	on TARGET.[IDCuestionarioEmpleado] = SOURCE.[IDCuestionarioEmpleado]
		and TARGET.IDPregunta = SOURCE.IDPregunta 
	WHEN MATCHED THEN
		update 
			set TARGET.Respuesta			= SOURCE.Respuesta
				,TARGET.ValorFinal			= SOURCE.ValorFinal 
				,TARGET.FechaHoraRespuesta	= getdate()
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT([IDCuestionarioEmpleado],IDPregunta,Respuesta,ValorFinal,FechaHoraRespuesta)
		values(SOURCE.[IDCuestionarioEmpleado],SOURCE.IDPregunta,SOURCE.Respuesta,SOURCE.ValorFinal,getdate())
	;

	exec Salud.spBuscarValorTotalPrueba @IDCuestionario=@IDCuestionario
GO

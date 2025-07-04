USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtiene el porcentaje del reporte clima laboral
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-07-13
** Paremetros		: @IDIndicador
**					: @JsonFiltros
**					: @JsonGroup

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2023-11-28			ANEUDY ABREU		fix: excluye las respuestas de escalas con valor -1
2024-08-13			ALEJANDRO PAREDES	fix: en @GroupBy se agrego ", IDSucursal"
***************************************************************************************************/

CREATE PROC [InfoDir].[spIndicadorClimaLaboral]
(
	@IDProyecto			INT
	,@IDSucursal		INT = 0
	,@JsonFiltros		NVARCHAR(MAX)
	,@JsonGroup			NVARCHAR(MAX)
	,@TipoInformacion	INT = 1
	,@IDUsuario			int
)
AS
	BEGIN


		DECLARE 
			@GroupBy	   NVARCHAR(MAX) = ''
			,@IDLabel	   VARCHAR(250) = ''
			,@Label		   VARCHAR(250) = ''
			,@Qry		   NVARCHAR(MAX)
			,@Qry2		   NVARCHAR(MAX)				
			,@INDICADOR				INT = 2
			,@TIPO_INDICADOR		INT = 1
			,@TIPO_MENSAJE			INT = 2
			,@TIPO_CUADRANTE_AUX	INT = 1
			,@TIPO_CUADRANTE		INT = 3
			;		
		

		-- ELIMINAMOS LAS TABLAS TEMPORALES		
		IF OBJECT_ID('tempdb..#TblFiltrosDataSource') IS NOT NULL BEGIN DROP TABLE #TblFiltrosDataSource END		
		IF OBJECT_ID('tempdb..#TblIndicadores') IS NOT NULL BEGIN DROP TABLE #TblIndicadores END
		

		-- CREAMOS TABLAS TEMPORALES
		CREATE TABLE #TblFiltrosDataSource (
			[FechaNormalizacion] DATE
			,[IDProyecto] INT
			,[IDGrupo] INT
			,[IDTipoGrupo] INT
			,[IDTipoPreguntaGrupo] INT
			,[IDEvaluacionEmpleado] INT
			,[IDEmpleado] INT
			,[FechaNacimiento] DATE
			,[TotalPreguntas] INT
			,[MaximaCalificacionPosible] INT
			,[CalificacionObtenida] INT
			,[CalificacionMinimaObtenida] INT
			,[CalificacionMaxinaObtenida] INT
			,[Promedio] DECIMAL(10, 2)
			,[Porcentaje] DECIMAL(10, 2)
			,[IDPregunta] INT
			,[Respuesta] VARCHAR(MAX)
			,[ValorFinal] DECIMAL(18, 2)
			,[IDIndicador] INT
			,[IDGenero] VARCHAR(50)
			,[Genero] VARCHAR(50)
			,[Antiguedad] INT
			,[IDRango] INT
			,[IDGeneracion] INT 
			,[IDCliente] INT
			,[IDRazonSocial] INT
			,[IDRegPatronal] INT
			,[IDCentroCosto] INT
			,[IDDepartamento] INT
			,[IDArea] INT
			,[IDPuesto] INT
			,[IDTipoPrestacion] INT
			,[IDSucursal] INT
			,[IDDivision] INT
			,[IDRegion] INT
			,[IDClasificacionCorporativa] INT
			,[IDNivelEmpresarial] INT
			,[Empleado] VARCHAR(255)
			,[NombreIndicador] VARCHAR(255)
			,[Rango] VARCHAR(255)
			,[Generacion] VARCHAR(255)
			,[NombreComercial] VARCHAR(255)
			,[RazonSocial] VARCHAR(255)
			,[RegistroPatronal] VARCHAR(255)
			,[CentroCosto] VARCHAR(255)
			,[Departamento] VARCHAR(255)
			,[Area] VARCHAR(255)
			,[Puesto] VARCHAR(255)
			,[TipoPrestacion] VARCHAR(255)
			,[Sucursal] VARCHAR(255)
			,[Division] VARCHAR(255)
			,[Region] VARCHAR(255)
			,[ClasificacionCorporativa] VARCHAR(255)
			,[NivelEmpresarial] VARCHAR(255)
		);			
		
		DECLARE @TblGroupBy TABLE(
			[ID] INT IDENTITY(1,1),
			[Catalogo] VARCHAR(50)
		)

		CREATE TABLE #TblIndicadores (
			[IDTitle] VARCHAR(50)
			,[Title] VARCHAR(MAX)
			,[Total] DECIMAL(18,2)
			,[Color] VARCHAR(MAX)			
		);

		
		-- CONVERTIMOS GROUP BY A TABLA
		INSERT @TblGroupBy(Catalogo)
		SELECT *
		FROM OPENJSON(JSON_QUERY(@JsonGroup,  '$.GroupBy'))
		  WITH (
			catalogo NVARCHAR(50) '$.catalogo'
		  );
		
		
		-- OBTENERMOS LOS DATOS FILTRADOS
		IF(@TipoInformacion = @TIPO_CUADRANTE)
		BEGIN				
			INSERT INTO #TblFiltrosDataSource
			EXEC [InfoDir].[spIndicadorClimaLaboralFiltros] @IDProyecto=@IDProyecto, @IDSucursal= @IDSucursal, @JsonFiltros=@JsonFiltros, @TipoInformacion=@TIPO_CUADRANTE_AUX,@IDUsuario=@IDUsuario		
		END
		ELSE
		BEGIN
			INSERT INTO #TblFiltrosDataSource
			EXEC [InfoDir].[spIndicadorClimaLaboralFiltros] @IDProyecto=@IDProyecto, @IDSucursal= @IDSucursal, @JsonFiltros=@JsonFiltros, @TipoInformacion=@TipoInformacion,@IDUsuario=@IDUsuario
		END

		-- OBTENEMOS EL LA PROPIEDAD PRINCIPAL			
		SELECT @Label = Catalogo FROM @TblGroupBy WHERE ID = 1
		IF(@Label = '')
			BEGIN				
				SET @IDLabel = 'IDIndicador'
				SET @Label = 'NombreIndicador';
			END
		IF(@Label = 'IDProyecto')
			BEGIN				
				SET @IDLabel = 'IDProyecto'
				SET @Label = 'IDTipoGrupo';
			END
		ELSE
		BEGIN
			SELECT @IDLabel = (CASE WHEN ISNULL(FI.DisplayValue, '') <> '' THEN FI.DisplayValue ELSE '' END) 
			FROM [InfoDir].[tblCatFiltrosItems] FI
			WHERE FI.DisplayMember = @Label AND FI.IDTipoItem = @INDICADOR;

			IF(@IDLabel = '')	
				BEGIN
					SELECT 'No existe la propiedad ' + @Label;
					RETURN 0;
				END
		END


		-- OBTENEMOS EL GROUP BY PARA APLICARLO A LA CONSULTA DINAMICA		
		SELECT @GroupBy = STUFF((SELECT ',' + CONVERT(NVARCHAR(MAX), catalogo) FROM @TblGroupBy WHERE ID > 1 FOR XML PATH('')), 1, 1, '')
		IF(@GroupBy IS NULL)
		BEGIN				
			SET @GroupBy = 'IDTipoPreguntaGrupo, MaximaCalificacionPosible, IDIndicador, IDSucursal';
		END
		ELSE
		BEGIN 
			SET @GroupBy = @GroupBy + ', IDTipoPreguntaGrupo, MaximaCalificacionPosible, IDIndicador, IDSucursal';
		END
		
		-- DATOS FILTRADOS
		--SELECT * FROM #TblFiltrosDataSource

		DELETE D
		FROM #TblFiltrosDataSource D
			JOIN Evaluacion360.tblCatPreguntas P ON P.IDPregunta = D.IDPregunta
		WHERE D.Respuesta = '-1' AND ISNULL(P.Calificar, 0) = 1

		
		-- RESULTADO FINAL
		SET @Qry2 = 'WITH TblLabel (' + @IDLabel + ',' + @Label + ') AS
					 (
						SELECT ' + @IDLabel + ',
							   ' + @Label + '
						FROM #TblFiltrosDataSource
						GROUP BY ' + @IDLabel + ',' + @Label + '
					 )	
						' + CASE WHEN (@TipoInformacion = @TIPO_INDICADOR OR @TipoInformacion = @TIPO_MENSAJE) THEN 'SELECT (' ELSE 'INSERT INTO #TblIndicadores' END + ' 						
							SELECT T.' + @IDLabel + ' AS IDTitle,
								   T.' + @Label + ' AS Title,
								   ' + CASE 
										WHEN (@TipoInformacion = @TIPO_INDICADOR OR @TipoInformacion = @TIPO_CUADRANTE) 
											THEN '
												Total = (	
															SELECT CAST(AVG(ResultadoGroup) AS DECIMAL(18,2)) AS Resultado
															FROM (
																SELECT								
																ROUND(CAST(SUM(ValorFinal) / (CASE WHEN (COUNT(IDPregunta) * MaximaCalificacionPosible) = 0 THEN 1 ELSE (COUNT(IDPregunta) * MaximaCalificacionPosible) END) AS FLOAT) * 100, 2) AS ResultadoGroup ' +
																(CASE WHEN ISNULL(@GroupBy, '') <> '' THEN ', ' + @GroupBy ELSE '' END) + '
																FROM #TblFiltrosDataSource AS Grupo
																WHERE T.' + @IDLabel + ' = Grupo.' + @IDLabel + ' AND T.' + @Label + ' = Grupo.' + @Label + 
																(CASE WHEN ISNULL(@GroupBy, '') <> '' THEN ' GROUP BY ' + @GroupBy ELSE '' END) + '
															) AS SubQuery
														),
												Color = (
															SELECT ISNULL(ESG.Color, '''') AS Color 
															FROM [Evaluacion360].[tblEscalaSatisfaccionGeneral] ESG
															WHERE ESG.IDProyecto = ' + CAST(@IDProyecto AS VARCHAR(15)) + '
																  AND 
																	(	
																		SELECT CAST(AVG(ResultadoGroup) AS DECIMAL(18,2)) / 100 AS Resultado
																		FROM (
																			SELECT								
																			ROUND(CAST(SUM(ValorFinal) / (CASE WHEN (COUNT(IDPregunta) * MaximaCalificacionPosible) = 0 THEN 1 ELSE (COUNT(IDPregunta) * MaximaCalificacionPosible) END) AS FLOAT) * 100, 2) AS ResultadoGroup ' +
																			(CASE WHEN ISNULL(@GroupBy, '') <> '' THEN ', ' + @GroupBy ELSE '' END) + '
																			FROM #TblFiltrosDataSource AS Grupo
																			WHERE T.' + @IDLabel + ' = Grupo.' + @IDLabel + ' AND T.' + @Label + ' = Grupo.' + @Label + 
																			(CASE WHEN ISNULL(@GroupBy, '') <> '' THEN ' GROUP BY ' + @GroupBy ELSE '' END) + '
																		) AS SubQuery
																	)
																  BETWEEN ESG.[Min] AND ESG.[Max]
														)'
											ELSE 
												'(
													SELECT JSON_QUERY(''['' + STRING_AGG(''"'' +  STRING_ESCAPE(Respuesta, ''json'') + ''"'', '','') + '']'') as a FROM #TblFiltrosDataSource AS Resp WHERE T.' + @IDLabel + ' = Resp.' + @IDLabel + ' AND T.' + @Label + ' = Resp.' + @Label + '
												) AS Comentarios '
										END + '
							FROM TblLabel T
							GROUP BY T.' + @IDLabel + ', T.' + @Label + '	
						' + CASE WHEN (@TipoInformacion = @TIPO_MENSAJE) THEN '' ELSE 'ORDER BY Total DESC,  T.' + @Label + ' ' END + ' 
						' + CASE WHEN (@TipoInformacion = @TIPO_INDICADOR OR @TipoInformacion = @TIPO_MENSAJE) THEN ' FOR JSON AUTO ) AS ResultJson' ELSE '' END + ' 						
				    ';
		--SELECT @Qry2
		EXEC (@Qry2)
		

		-------------------------------------------------------------------------------------------------------------------------------------------------------------------


		IF(@TipoInformacion = @TIPO_CUADRANTE)
			BEGIN			   			
				
				IF OBJECT_ID('tempdb..#tempRespuestasCount') IS NOT NULL DROP TABLE #tempRespuestasCount;
				IF OBJECT_ID('tempdb..#tempRespuestasFinal') IS NOT NULL DROP TABLE #tempRespuestasFinal;

				DECLARE 
					@tmpRespuestasRanking [InfoDir].[dtIndicadorClimaLaboral]					
					,@RespuestaJSON			VARCHAR(MAX)					
					,@RN					INT
					;	
					

				-- TABLAS TEMPORALES
				DECLARE @tmpSatisfaccionGeneral TABLE (
					IDTitle INT
					,Title VARCHAR(MAX)
					,Valor DECIMAL(18,2)
					,Total  DECIMAL(18,2)
					,Color VARCHAR(50)
				);			

				DECLARE @tempRespuestasJSON TABLE(
					IDProyecto INT
					,Respuesta NVARCHAR(MAX)
					,RN INT
				);

				DECLARE @tempRespuestasOrden TABLE(
					IDPosibleRespuesta INT
					,Orden INT
				);

				CREATE TABLE #tempRespuestasFinal (
					OpcionRespuesta VARCHAR(MAX)
					,Orden INT
					,IDIndicador INT
					,Calculo INT
				);


				-- OBTENEMOS LOS INDICADORES Y SU VALOR
				INSERT @tmpSatisfaccionGeneral
				SELECT IDTitle
				       ,Title 
					   ,Total / 100 AS Valor
					   ,Total
					   ,Color
				FROM #TblIndicadores	


				-- OBTENEMOS LAS RESPUESTAS DE LAS PREGUNTAS RANKING
				INSERT INTO @tmpRespuestasRanking
				EXEC [InfoDir].[spIndicadorClimaLaboralFiltros] @IDProyecto=@IDProyecto, @IDSucursal= @IDSucursal, @JsonFiltros=@JsonFiltros, @TipoInformacion=@TipoInformacion,@IDUsuario=@IDUsuario


				-- OBTENEMOS DE LA PREGUNTAS SU RESPUESTA EN FORMATO JSON Y COLOCAMOS UN ROW_NUMBER AL NUMERO DE RESPUESTAS
				;WITH TblResp(IDProyecto, Respuesta, RN)
					AS
					(
						SELECT R.IDProyecto
							  ,R.Respuesta
							  ,ROW_NUMBER() OVER (ORDER BY IDProyecto) AS RN
						FROM @tmpRespuestasRanking R
					)
				INSERT INTO @tempRespuestasJSON
				SELECT * FROM TblResp;
				
				-- OBTENEMOS EL NUMERO DE RESPUESTAS DE LAS PREGUNTAS
				SELECT @RN = MIN(RN) FROM @tempRespuestasJSON


				-- OBTENEMOS LAS RESPUESTAS DEL JSON ORDENADO EN DECENDENTE POR ORDEN
				WHILE EXISTS(SELECT TOP 1 1 FROM @tempRespuestasJSON WHERE RN >= @RN)
					BEGIN						
						SELECT @RespuestaJSON = Respuesta FROM @tempRespuestasJSON WHERE RN = @RN
						IF(ISJSON(@RespuestaJSON) = 1)
							BEGIN
								INSERT INTO @tempRespuestasOrden
								SELECT RE.*
								FROM OPENJSON(@RespuestaJSON)
								WITH (IDPosibleRespuesta INT 'strict $.IDPosibleRespuesta', Orden INT) AS RE;
							END
						SELECT @RN = MIN(RN) FROM @tempRespuestasJSON WHERE RN > @RN
					END
				
				
				-- OBTENEMOS EL ORDEN DE LOS INDICADORES (ORDEN DE COMO CONTESTARON LOS COLABORADORES)
				-- OBTENEMOS UN CONTADOR PARA IDENTIFICAR AQUELLOS INDICADORES QUE QUEDARON EN EL MISMO ORDEN
				SELECT *
					   ,ROW_NUMBER()OVER(PARTITION BY Orden ORDER BY Total DESC) AS RN
				INTO #tempRespuestasCount
				FROM (
						SELECT PR.OpcionRespuesta, R.Orden, PR.JSONData, COUNT(R.Orden) Total
						FROM @tempRespuestasOrden R
							JOIN [Evaluacion360].[tblPosiblesRespuestasPreguntas] PR ON R.IDPosibleRespuesta = PR.IDPosibleRespuesta
						GROUP BY PR.OpcionRespuesta, R.Orden, PR.JSONData
				) AS info
				ORDER BY Orden DESC, Total DESC

								
				-- AGRUPAMOS INDICADORES EN BASE A LA FORMULA ( INDICADOR_AGRUPADO * Total)
				INSERT #tempRespuestasFinal(OpcionRespuesta, Orden, IDIndicador, Calculo)
				SELECT OpcionRespuesta
					   ,ROW_NUMBER()OVER(ORDER BY orden_total) AS Orden
					   ,JSON_VALUE(JSONData, '$.IDIndicador')
					   ,orden_total
				FROM (
						SELECT OpcionRespuesta, JSONData, SUM(ISNULL(Orden, 0) * ISNULL(Total, 0)) AS orden_total, SUM(Total) AS total
						FROM #tempRespuestasCount
						GROUP BY OpcionRespuesta, JSONData
				) AS info
				ORDER BY orden_total DESC

				-- RESULTADO FINAL (OBTENEMOS SATISFACCION, RELEVANCIA E ICONO)
				SELECT (
					SELECT SATISFACCION.Title
						   ,SATISFACCION.Total
						   ,SATISFACCION.Color
						   ,(
								SELECT JSON_QUERY((
									SELECT
										(
											SELECT ESG.IndiceSatisfaccion
											FROM [Evaluacion360].[tblEscalaSatisfaccionGeneral] ESG
											WHERE ESG.IDProyecto = @IDProyecto AND SATISFACCION.Valor BETWEEN ESG.[Min] AND ESG.[Max]
										) AS IndiceSatisfaccion,
										(
											SELECT ERI.IndiceRelevancia
											FROM [Evaluacion360].tblEscalaRelevanciaIndicadores ERI
											WHERE ERI.IDProyecto = @IDProyecto AND FINAL.Orden BETWEEN ERI.[Min] AND eri.[Max]
										) AS IndiceRelevancia,
										ICON.NombreIcono
									FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
								)) D
							) AS JSONData
					FROM #tempRespuestasFinal FINAL
						LEFT JOIN @tmpSatisfaccionGeneral SATISFACCION ON SATISFACCION.IDTitle = FINAL.IDIndicador
						LEFT JOIN [Evaluacion360].[tblCatIndicadores] ICON ON ICON.IDIndicador = FINAL.IDIndicador
					ORDER BY Total DESC, Title
					FOR JSON AUTO
				) AS ResultJson

			END

	END
GO

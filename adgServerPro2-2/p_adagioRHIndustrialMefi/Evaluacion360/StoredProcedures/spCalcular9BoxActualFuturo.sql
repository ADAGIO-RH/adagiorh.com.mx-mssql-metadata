USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtiene el resultado del 9Box (Actual / Futuro).
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-03-12
** Paremetros		: @IDProyecto					Identificador del proyecto.
**					: @JsonFiltros					Contiene la lista de catalogos e identificadores para filtrar la información.
**					: @IsGeneral					Bandera que indica: (true - Un solo resultado por proyecto / false: Resultado por cada colaborador)
**					: @IDUsuario					Identificador del usuario.
** IDAzure			: 830

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [Evaluacion360].[spCalcular9BoxActualFuturo](
	@IDProyecto					INT	
	, @JsonFiltros				NVARCHAR(MAX)
	, @IsGeneral				BIT
	, @IsDetalle				BIT = 0
	, @IDUsuario				INT
)
AS
	BEGIN
	
		-- VARIABLES
		DECLARE	@tempGrupos				[Evaluacion360].[dtGrupos9Box]
				, @JsonFiltrosNew		NVARCHAR(MAX)
				, @ESCALA_NUEVA_MINIMA	DECIMAL(18,2) = 0.01
				, @ESCALA_NUEVA_MAXIMA	DECIMAL(18,2) = 3.00				
				, @SI					BIT = 1
				;


		-- TABLAS TEMPORALES
		IF OBJECT_ID('tempdb..#tempFiltrosAux') IS NOT NULL DROP TABLE #tempFiltrosAux;

		DECLARE @tempCalculo TABLE(
			IDEmpleado INT
			, ClaveEmpleado VARCHAR(20)
			, Empleado VARCHAR(255)
			, Iniciales VARCHAR(2)			
			, IDGrupo INT
			, Grupo VARCHAR(255)			
			, EscalaGrupo VARCHAR(25)
			, Promedio DECIMAL(18,2)
			, TransPromedio DECIMAL(18,2)
			, Eje VARCHAR(25)
		)

		DECLARE @tempResultadoFinal TABLE(
			IDEmpleado INT
			, IDGrupo INT
			, EscalaGrupo VARCHAR(25)
			, Promedio DECIMAL(18,2)
			, TransPromedio DECIMAL(18,2)
			, Eje VARCHAR(25)
		)


		-- CONVERTIMOS FILTROS A TABLA		
		;WITH tblFiltros(catalogo, [value])
		AS
		(
			SELECT *
			FROM OPENJSON(JSON_QUERY(@JsonFiltros,  '$'))
			  WITH (
				catalogo NVARCHAR(50) '$.Catalogo',
				valor NVARCHAR(MAX) '$.Value'
			  )
		)
		SELECT *
		INTO #tempFiltrosAux
		FROM tblFiltros;		
		
		
		-- REFACTORIZA JSON FILTROS
		;WITH tblCTE AS (
			SELECT 'Grupos' AS Catalogo
					, STRING_AGG(CONVERT(NVARCHAR(MAX), [value]), ',') WITHIN GROUP (ORDER BY [value]) AS [Value]
			FROM #tempFiltrosAux
			WHERE catalogo IN ('EjeX', 'EjeY')
			UNION ALL
			SELECT catalogo
					, STRING_AGG(CONVERT(NVARCHAR(MAX), [value]), ',') WITHIN GROUP (ORDER BY [value]) AS [Value]
			FROM #tempFiltrosAux
			WHERE catalogo NOT IN ('EjeX', 'EjeY')	
			GROUP BY catalogo
		)
		SELECT @JsonFiltrosNew = (
			SELECT *
			FROM tblCTE
			FOR JSON PATH
		);	
		--SELECT @JsonFiltrosNew


		-- ELIMINAMOS FILTROS CON VALOR INDIFERENTE A 'EjeX', 'EjeY'
		DELETE #tempFiltrosAux
		WHERE catalogo <> 'EjeX' AND catalogo <> 'EjeY';

				
		
		-- OBTENEMOS GRUPOS
		INSERT INTO @tempGrupos
		EXEC [Evaluacion360].[spDetalleInfo9Box] @IDProyecto=@IDProyecto, @JsonFiltros = @JsonFiltrosNew, @IDUsuario=@IDUsuario;
		--SELECT * FROM @tempGrupos		
		
		
		-- CALCULAMOS EL EJE "X" y "Y" POR CADA GRUPO EXISTENTE
		INSERT INTO @tempCalculo		
		SELECT IDEmpleado
				, ClaveEmpleado
				, Evaluado
				, Iniciales				
				, IDGrupo
				, Grupo				
				, CAST(EscalaViejaMin AS VARCHAR(10)) + ' - ' + CAST(EscalaViejaMax AS VARCHAR(10)) AS EscalaGrupo
				, Promedio				
				, Evaluacion360.fnTransformacionLineal(Promedio, EscalaViejaMin, EscalaViejaMax, @ESCALA_NUEVA_MINIMA, @ESCALA_NUEVA_MAXIMA) AS TransPromedio
				, 'EjeX' AS Eje
		FROM @tempGrupos
		WHERE Grupo IN (SELECT item FROM App.Split((SELECT TOP 1 [value] FROM #tempFiltrosAux WHERE Catalogo = 'EjeX'), ','))
		UNION ALL
		SELECT IDEmpleado
				, ClaveEmpleado
				, Evaluado
				, Iniciales				
				, IDGrupo
				, Grupo				
				, CAST(EscalaViejaMin AS VARCHAR(10)) + ' - ' + CAST(EscalaViejaMax AS VARCHAR(10)) AS EscalaGrupo
				, Promedio				
				, Evaluacion360.fnTransformacionLineal(Promedio, EscalaViejaMin, EscalaViejaMax, @ESCALA_NUEVA_MINIMA, @ESCALA_NUEVA_MAXIMA) AS TransPromedio
				, 'EjeY' AS Eje
		FROM @tempGrupos
		WHERE Grupo IN (SELECT item FROM App.Split((SELECT TOP 1 [value] FROM #tempFiltrosAux WHERE Catalogo = 'EjeY'), ','))
		ORDER BY Eje, Grupo, IDempleado;
		
		
		-- REVICION
		--SELECT * FROM #tempFiltrosAux
		--SELECT * FROM @tempCalculo ORDER BY Eje, IDEmpleado


		IF(@IsDetalle = @SI)
			BEGIN
				-- DETALLE
				SELECT IDEmpleado
						, ClaveEmpleado
						, Empleado
						, Grupo
						, EscalaGrupo
						, CAST(AVG(Promedio) AS DECIMAL(18, 2)) AS Promedio
						, CAST(AVG(TransPromedio) AS DECIMAL(18, 2)) AS TransPromedio
						, Eje
				FROM @tempCalculo 
				GROUP BY IDEmpleado, ClaveEmpleado, Empleado, Grupo, EscalaGrupo, Eje
				ORDER BY Eje, IDEmpleado, Grupo
			END
		ELSE
			BEGIN
				-- RESULTADO FINAL
				IF(@IsGeneral = @SI)
					BEGIN
						IF ((SELECT COUNT(*) FROM @tempGrupos) = 0)
							BEGIN
								SELECT TOP 0 
										IDEmpleado, ClaveEmpleado, Empleado, Iniciales, TransPromedio AS EjeX, TransPromedio AS EjeY
								FROM @tempCalculo
							END
						ELSE
							BEGIN
								SELECT 0 AS IDEmpleado
										, '' AS ClaveEmpleado
										, '' AS Empleado
										, 'GN' AS Iniciales
										, CAST(AVG(CASE WHEN Eje = 'EjeX' THEN TransPromedio END) AS DECIMAL(18, 2)) AS EjeX
										, CAST(AVG(CASE WHEN Eje = 'EjeY' THEN TransPromedio END) AS DECIMAL(18, 2)) AS EjeY
								FROM @tempCalculo;
							END
					END
				ELSE
					BEGIN
						SELECT IDEmpleado
								, ClaveEmpleado
								, Empleado
								, Iniciales
								, CAST(AVG(CASE WHEN Eje = 'EjeX' THEN TransPromedio END) AS DECIMAL(18, 2)) AS EjeX
								, CAST(AVG(CASE WHEN Eje = 'EjeY' THEN TransPromedio END) AS DECIMAL(18, 2)) AS EjeY
						FROM @tempCalculo
						GROUP BY IDEmpleado, ClaveEmpleado, Iniciales, Empleado
						ORDER BY IDEmpleado;
					END
			END
	END
GO

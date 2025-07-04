USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtiene el resultado del 9Box (Performance / Skill).
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-03-07
** Paremetros		: @IDProyecto					Identificador del proyecto.
**					: @IDCicloMedicionObjetivo		Identificador del ciclo de medicion.
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

CREATE   PROC [Evaluacion360].[spCalcular9BoxPerformanceSkill](
	@IDProyecto					INT
	, @IDCicloMedicionObjetivo	INT
	, @JsonFiltros				NVARCHAR(MAX)
	, @IsGeneral				BIT
	, @IsDetalle				BIT = 0
	, @IDUsuario				INT
)
AS
	BEGIN
	
		-- VARIABLES
		DECLARE	@tempGrupos				[Evaluacion360].[dtGrupos9Box]				
				, @ESCALA_VIEJA_MINIMA	INT = 0
				, @ESCALA_VIEJA_MAXIMA	INT = 100
				, @ESCALA_NUEVA_MINIMA	DECIMAL(18,2) = 0.01
				, @ESCALA_NUEVA_MAXIMA	DECIMAL(18,2) = 3.00
				, @SI					BIT = 1
				;


		DECLARE @tempCalculo TABLE(
			IDEmpleado INT
			, ClaveEmpleado VARCHAR(20)
			, Empleado VARCHAR(255)
			, Iniciales VARCHAR(2)						
			, IDGrupo INT			
			, Grupo VARCHAR(254)
			, TipoEvaluacion VARCHAR(150)
			, EscalaGrupo VARCHAR(25)
			, Promedio DECIMAL(18,2)
			, TransPromedio DECIMAL(18,2)
			, EscalaObjetivo VARCHAR(25)
			, Porcentaje DECIMAL(18,2)
			, TransPorcentaje DECIMAL(18,2)
		)



		-- OBTENEMOS GRUPOS
		INSERT INTO @tempGrupos
		EXEC [Evaluacion360].[spDetalleInfo9Box] @IDProyecto, @JsonFiltros, @IDUsuario;
		--SELECT * FROM @tempGrupos		
		

		-- CALCULAMOS EL EJE "X" y "Y" POR CADA GRUPO EXISTENTE
		INSERT INTO @tempCalculo
		SELECT GPO.IDEmpleado
				, GPO.ClaveEmpleado
				, GPO.Evaluado
				, GPO.Iniciales					
				, GPO.IDGrupo				
				, GPO.Grupo
				, GPO.TipoEvaluacion
				, CAST(GPO.EscalaViejaMin AS VARCHAR(10)) + ' - ' + CAST(GPO.EscalaViejaMax AS VARCHAR(10)) AS EscalaGrupo
				, GPO.Promedio
				, Evaluacion360.fnTransformacionLineal(GPO.Promedio, GPO.EscalaViejaMin, GPO.EscalaViejaMax, @ESCALA_NUEVA_MINIMA, @ESCALA_NUEVA_MAXIMA) AS TransPromedio
				, CAST(@ESCALA_VIEJA_MINIMA AS VARCHAR(5)) + ' - ' + CAST(@ESCALA_VIEJA_MAXIMA AS VARCHAR(5)) AS EscalaObjetivo
				, ISNULL(OBJ.Porcentaje, 0) AS Porcentaje
				, Evaluacion360.fnTransformacionLineal(ISNULL(OBJ.Porcentaje, 0), @ESCALA_VIEJA_MINIMA, @ESCALA_VIEJA_MAXIMA, @ESCALA_NUEVA_MINIMA, @ESCALA_NUEVA_MAXIMA) AS TransPorcentaje
		FROM @tempGrupos GPO
			LEFT JOIN [Evaluacion360].[tblProgresoGeneralPorCicloEmpleados] OBJ ON OBJ.IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo AND GPO.IDEmpleado = OBJ.IDEmpleado;
		
		-- REVISION
		--SELECT * FROM @tempCalculo ORDER BY IDEmpleado


		IF(@IsDetalle = @SI)
			BEGIN
				-- DETALLE
				SELECT IDEmpleado
						, ClaveEmpleado
						, Empleado						
						, Grupo
						, TipoEvaluacion
						, EscalaGrupo
						, CAST(AVG(Promedio) AS DECIMAL(18, 2)) AS Promedio
						, CAST(AVG(TransPromedio) AS DECIMAL(18, 2)) AS TransPromedio
						, EscalaObjetivo
						, CAST(AVG(Porcentaje) AS DECIMAL(18, 2)) AS Porcentaje
						-- SI OBJETIVO SOBRE-PASA EL 100% APLICAMOS LA ESCALA NUEVA MAXIMA (valor: 3)
						, CASE
							WHEN CAST(AVG(TransPorcentaje) AS DECIMAL(18, 2)) > @ESCALA_NUEVA_MAXIMA
								THEN @ESCALA_NUEVA_MAXIMA
								ELSE CAST(AVG(TransPorcentaje) AS DECIMAL(18, 2))
							END AS TransPorcentaje
				FROM @tempCalculo 
				GROUP BY IDEmpleado, ClaveEmpleado, Empleado, Grupo, TipoEvaluacion, EscalaGrupo, EscalaObjetivo
				ORDER BY IDEmpleado, TipoEvaluacion, Grupo
			END
		ELSE
			BEGIN
				-- RESULTADO FINAL
				IF(@IsGeneral = @SI)
					BEGIN
						IF ((SELECT COUNT(*) FROM @tempGrupos) = 0)
							BEGIN
								SELECT TOP 0 
										IDEmpleado, ClaveEmpleado, Empleado, Iniciales, TransPromedio AS EjeX, TransPorcentaje AS EjeY
								FROM @tempCalculo
							END
						ELSE
							BEGIN
								SELECT 0 AS IDEmpleado
										, '' AS ClaveEmpleado
										, '' AS Empleado
										, 'GN' AS Iniciales
										, CAST(AVG(TransPromedio) AS DECIMAL(18, 2)) AS EjeX
										-- SI OBJETIVO SOBRE-PASA EL 100% APLICAMOS LA ESCALA NUEVA MAXIMA (valor: 3)
										, CASE
											WHEN CAST(AVG(TransPorcentaje) AS DECIMAL(18, 2)) > @ESCALA_NUEVA_MAXIMA
												THEN @ESCALA_NUEVA_MAXIMA
												ELSE CAST(AVG(TransPorcentaje) AS DECIMAL(18, 2))
											END AS EjeY
								FROM @tempCalculo
							END
					END
				ELSE
					BEGIN
						SELECT IDEmpleado
								, ClaveEmpleado
								, Empleado
								, Iniciales
								, CAST(AVG(TransPromedio) AS DECIMAL(18, 2)) AS EjeX
								-- SI OBJETIVO SOBRE-PASA EL 100% APLICAMOS LA ESCALA NUEVA MAXIMA (valor: 3)
								, CASE
									WHEN CAST(AVG(TransPorcentaje) AS DECIMAL(18, 2)) > @ESCALA_NUEVA_MAXIMA
									 THEN @ESCALA_NUEVA_MAXIMA
									 ELSE CAST(AVG(TransPorcentaje) AS DECIMAL(18, 2))
								   END AS EjeY
						FROM @tempCalculo
						GROUP BY IDEmpleado, ClaveEmpleado, Iniciales, Empleado
						ORDER BY IDEmpleado
					END			
			END
	END
GO

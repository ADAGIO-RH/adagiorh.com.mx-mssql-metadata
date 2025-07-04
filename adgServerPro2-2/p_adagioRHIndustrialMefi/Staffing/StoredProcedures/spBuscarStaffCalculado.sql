USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca y calcula el staff
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-09-07
** Paremetros		: @JsonFiltros				- Filtros solicitados
					  @Fecha					- Fecha solicitada
					  @IDUsuario				- Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROCEDURE [Staffing].[spBuscarStaffCalculado](
	@JsonFiltros	NVARCHAR(MAX)
	,@Fecha			DATE
	,@IDPorcentaje	INT = 0
	,@IDUsuario		INT = 0 
)
AS
BEGIN

	SET FMTONLY OFF;
		
		SET LANGUAGE 'spanish'

		DECLARE 
				@dtEmpleados [RH].[dtEmpleados]
				, @dtFiltros [Nomina].[dtFiltrosRH]
				, @dtFiltrosIncidencias [Nomina].[dtFiltrosRH]
				, @IDIdioma VARCHAR(20)
				, @Selects NVARCHAR(MAX)
				, @Columns NVARCHAR(MAX)
				, @SumaAusentismos NVARCHAR(MAX)
				, @SumaAusentismosConPago NVARCHAR(MAX)
				, @SumaAusentismosSinPago NVARCHAR(MAX)
				, @SumaTotalColumns NVARCHAR(MAX)
				, @Qry NVARCHAR(MAX)				


		-- CREAMOS TABLAS TEMPORALES
		DECLARE @TblSucursalDepartamentosPuestosMapeados TABLE(
			[IDMapeo] INT,
			[IDSucursal] INT,
			[Sucursal] VARCHAR(500),
			[IDDepartamento] INT,
			[Departamento] VARCHAR(500),
			[IDPuesto] INT,
			[Puesto] VARCHAR(500)
		)

		DECLARE @TblSucursalDepartamentosPuestosFiltrado TABLE(
			[IDMapeo] INT,
			[IDSucursal] INT,
			[Sucursal] VARCHAR(500),
			[IDDepartamento] INT,
			[Departamento] VARCHAR(500),
			[IDPuesto] INT,
			[Puesto] VARCHAR(500),
			[CantidadStaff] INT
		)

		DECLARE @TblEmpleadosInvolucrados TABLE(
			[IDEmpleado] INT,
			[IDSucursal] INT,
			[IDDepartamento] INT,
			[IDPuesto] INT
		)

		CREATE TABLE #TblNormalizada(			
			[IDSucursal] INT,
			[Sucursal] VARCHAR(500),
			[IDDepartamento] INT,
			[Departamento] VARCHAR(500),
			[IDPuesto] INT,
			[Puesto] VARCHAR(500),
			[CantidadStaff] INT
		)

		CREATE TABLE #TblEmpleadoIncidencias(
			[IDSucursal] INT,
			[IDDepartamento] INT,
			[IDPuesto] INT,
			[IDEmpleado] INT,
			[IDIncidencia] VARCHAR(10),
			[TieneIncidencia] INT
		)

		DECLARE @TblColumnas TABLE(
			[value] VARCHAR(25),
			[alias] VARCHAR(25),
			[bold] VARCHAR(15),
			[background] VARCHAR(15),
			[textAlign] VARCHAR(15),
			[verticalAlign] VARCHAR(15),
			[color] VARCHAR(15),
			[enable] VARCHAR(15),
			[order] INT,
			[width] INT
		)


		-- CONVERTIMOS JSON A TABLA (MANEJO DE FILTROS)
		INSERT @dtFiltros(Catalogo, Value)
		SELECT *
		FROM OPENJSON(JSON_QUERY(@JsonFiltros,  '$.Filtros'))
		  WITH (
			catalogo NVARCHAR(50) '$.catalogo',
			valor NVARCHAR(50) '$.valor'
		  );

		  
		/** TODO:
			MANEJO DE FILTROS DE INCIDENCIAS 
			SE PRETENDE REALIZAR UN CATALOGO
		**/
		INSERT INTO @TblColumnas
		EXEC [Staffing].[spBuscarColumnasFase] @IDUsuario

		INSERT @dtFiltrosIncidencias(Catalogo, [Value])
		SELECT [value], [alias] FROM @TblColumnas WHERE [order] BETWEEN 1 AND 100;
		/** TERMINA AQUI **/		


		-- OBTENEMOS LOS EMPLEADOS SEGUN LA FECHA SOLICITADA (HISTORIAL)
		INSERT @dtEmpleados
		EXEC [RH].[spBuscarEmpleados]
			@FechaIni	 = @Fecha
			, @Fechafin  = @Fecha
			, @IDUsuario = @IDUsuario
			-- , @dtFiltros
		/*
			PODEMOS USAR LA TABLA [RH].[tblEmpleadosMaster] PARA HACER PRUEBAS, POR VELOCIDAD DE RESPUESTA
			
			INSERT @dtEmpleados
			SELECT * FROM [RH].[tblEmpleadosMaster]
		*/
		
		
		
		-- OBTENEMOS SUCURSALES DEPARTAMENTOS Y PUESTOS
		INSERT INTO @TblSucursalDepartamentosPuestosMapeados
		EXEC [Staffing].[spBuscarSucursalesDepartamentosPuestosMapeados] @IDUsuario

		

		-- FILTRAMOS AQUELLAS SUCURSALES, DEPARTAMENTO, PUESTOS... DONDE EXISTAN COLABORADORES
		INSERT INTO @TblSucursalDepartamentosPuestosFiltrado
		SELECT N.*,
			   ISNULL((SELECT CS.Cantidad
					  FROM [Staffing].[tblCatPorcentajes] P
						JOIN [Staffing].[tblCatStaff] CS ON P.IDPorcentaje = CS.IDPorcentaje
					  WHERE P.IDPorcentaje = @IDPorcentaje
						    AND CS.IDMapeo = N.IDMapeo), 0) AS CantidadStaff
		FROM (SELECT IDSucursal, IDDepartamento, IDPuesto 
			  FROM @dtEmpleados
			  WHERE IDSucursal > 0 AND IDDepartamento > 0 AND IDPuesto > 0
			  GROUP BY IDSucursal, IDDepartamento, IDPuesto
		) SPD
		JOIN @TblSucursalDepartamentosPuestosMapeados N ON SPD.IDSucursal = N.IDSucursal AND SPD.IDDepartamento = N.IDDepartamento AND SPD.IDPuesto = N.IDPuesto

		
		
		-- OBTENERMOS LOS USUARIOS INVOLUCRADOS
		INSERT @TblEmpleadosInvolucrados
		SELECT IDEmpleado
			   , IDSucursal
			   , IDDepartamento
			   , IDPuesto
		FROM @dtEmpleados
		WHERE IDSucursal > 0 AND IDDepartamento > 0 AND IDPuesto > 0
			AND
			(
				IDSucursal IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDSucursal'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDSucursal' AND ISNULL(Value, '') <> '')
					)
			) AND	
			(
				IDDepartamento IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDDepartamento'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDDepartamento' AND ISNULL(Value, '') <> '')
					)
			) AND			 
			(
				IDPuesto IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDPuesto'),',')) 
				OR (
					NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDPuesto' AND ISNULL(Value, '') <> '')
					)
			)
		GROUP BY IDEmpleado, IDSucursal, IDDepartamento, IDPuesto

		

		-- FILTRAMOS POR SUCURSAL, DEPARTAMENTO O PUESTO
		INSERT INTO #TblNormalizada(IDSucursal, Sucursal, IDDepartamento, Departamento, IDPuesto, Puesto, CantidadStaff)
		SELECT IDSucursal, Sucursal, IDDepartamento, Departamento, IDPuesto, Puesto, CantidadStaff
		FROM @TblSucursalDepartamentosPuestosFiltrado
		WHERE (
				 IDSucursal IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDSucursal'),',')) 
				 OR (
					 NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDSucursal' AND ISNULL(Value, '') <> '')
					)
			  ) AND	
			  (
				 IDDepartamento IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDDepartamento'),',')) 
				 OR (
					 NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDDepartamento' AND ISNULL(Value, '') <> '')
					)
			  ) AND			 
			  (
				 IDPuesto IN (SELECT item FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'IDPuesto'),',')) 
				 OR (
					 NOT EXISTS (SELECT 1 FROM @dtFiltros WHERE Catalogo = 'IDPuesto' AND ISNULL(Value, '') <> '')
					)
			  )
			  


		-- OBTENEMOS LAS INCIDENCIAS DE LOS COLABORADORES
		;WITH tblEmpleado(IDEmpleado, IDSucursal, IDDepartamento, IDPuesto, IDIncidencia)
		AS
			(
			SELECT EM.IDEmpleado
				    , IDSucursal
					, IDDepartamento
					, IDPuesto
				    , I.IDIncidencia
			FROM @TblEmpleadosInvolucrados EM			
			CROSS APPLY (
				SELECT IDIncidencia
				FROM [Asistencia].[tblCatIncidencias] CI
					JOIN @dtFiltrosIncidencias FI ON CI.IDIncidencia = FI.Catalogo
				UNION ALL
				SELECT 'ASISTENCIA' AS IDIncidencia
			) AS I
			--ORDER BY EM.IDEmpleado, I.IDIncidencia
			)
		INSERT INTO #TblEmpleadoIncidencias(IDSucursal, IDDepartamento, IDPuesto, IDEmpleado, IDIncidencia, TieneIncidencia)
		SELECT E.IDSucursal
			   , E.IDDepartamento
			   , E.IDPuesto		   
			   , E.IDEmpleado
			   , E.IDIncidencia
			   , CASE WHEN E.IDIncidencia = 'ASISTENCIA'
						THEN
							CASE 
								WHEN ISNULL((SELECT TOP 1 IDChecada 
											  FROM [Asistencia].[tblChecadas] CH 
											  WHERE CH.IDEmpleado = E.IDEmpleado AND CONVERT(DATE, CH.FechaOrigen) = @Fecha AND CH.IDTipoChecada IN ('ET', 'SH', 'ST')), 0) = 0 
									THEN 0 
									ELSE 1 
								END
						ELSE
							CASE 
								WHEN ISNULL((SELECT TOP 1 IE.IDIncidenciaEmpleado
											  FROM [Asistencia].[tblIncidenciaEmpleado] IE 
											  WHERE IE.IDEmpleado = E.IDEmpleado
													AND CONVERT(DATE, IE.Fecha) = @Fecha
													AND IE.Autorizado = 1
													AND IE.IDIncidencia = E.IDIncidencia), 0) = 0 
								THEN 0 
								ELSE 1 
							END
					END AS TieneIncidencia
		FROM tblEmpleado E
		--WHERE E.IDEmpleado IN (1, 2, 3)
		ORDER BY E.IDEmpleado, E.IDIncidencia
		
		
		

		-- OBTENEMOS CAMPOS DINAMICOS
		SET @Selects = (SELECT STRING_AGG('
					(SELECT COUNT(DISTINCT(EI.IDEmpleado)) FROM #TblEmpleadoIncidencias EI WHERE EI.IDSucursal = N.IDSucursal AND EI.IDDepartamento = N.IDDepartamento AND EI.IDPuesto = N.IDPuesto AND EI.TieneIncidencia = 1 AND EI.IDIncidencia = ''' + FI.catalogo + ''') AS [' + FI.[Value] + ']', ', ')
		FROM @dtFiltrosIncidencias FI)

		SET @Columns = (SELECT STRING_AGG('[' + FI.[Value] + ']', ', ') FROM @dtFiltrosIncidencias FI)
		SET @SumaAusentismos = (SELECT STRING_AGG('[' + FI.[Value] + ']', ' + ') FROM @dtFiltrosIncidencias FI JOIN [Asistencia].[tblCatIncidencias] I ON FI.[catalogo] = I.IDIncidencia WHERE I.EsAusentismo = 1)
		SET @SumaAusentismosConPago = (SELECT STRING_AGG('[' + FI.[Value] + ']', ' + ') FROM @dtFiltrosIncidencias FI JOIN [Asistencia].[tblCatIncidencias] I ON FI.[catalogo] = I.IDIncidencia WHERE I.EsAusentismo = 1 AND I.GoceSueldo = 1)
		SET @SumaAusentismosSinPago = (SELECT STRING_AGG('[' + FI.[Value] + ']', ' + ') FROM @dtFiltrosIncidencias FI JOIN [Asistencia].[tblCatIncidencias] I ON FI.[catalogo] = I.IDIncidencia WHERE I.EsAusentismo = 1  AND I.GoceSueldo = 0)
		SET @SumaTotalColumns = (SELECT STRING_AGG('SUM([' + FI.[Value] + '])' + ' AS [' + FI.[Value] + ']', ', ')  FROM @dtFiltrosIncidencias FI)


		--SELECT * FROM @dtFiltrosIncidencias
		--SELECT @Selects AS Selects
		--SELECT @Columns AS Columnss
		--SELECT @SumaAusentismos AS SumaAusentismos
		--SELECT @SumaAusentismosConPago AS SumaAusentismosConPago
		--SELECT @SumaAusentismosSinPago AS SumaAusentismosSinPago
		--SELECT @SumaTotalColumns AS SumaTotal


		-- RESULTADO FINAL 
		SET @Qry = '
		;WITH tblIncidencias(IDSucursal, IDDepartamento, IDPuesto, Sucursal, Departamento, Puesto, CONTRATADO, STAFF_PPTO, ASISTENCIA, ' + @Columns + ')
		AS
			(
			SELECT N.IDSucursal
				   , N.IDDepartamento
				   , N.IDPuesto
				   , N.Sucursal
				   , N.Departamento
				   , N.Puesto				   
				   , (SELECT COUNT(DISTINCT(EI.IDEmpleado)) FROM #TblEmpleadoIncidencias EI WHERE EI.IDSucursal = N.IDSucursal AND EI.IDDepartamento = N.IDDepartamento AND EI.IDPuesto = N.IDPuesto) AS CONTRATADO				   
				   , N.CantidadStaff AS STAFF_PPTO
				   , (SELECT COUNT(DISTINCT(EI.IDEmpleado)) FROM #TblEmpleadoIncidencias EI WHERE EI.IDSucursal = N.IDSucursal AND EI.IDDepartamento = N.IDDepartamento AND EI.IDPuesto = N.IDPuesto AND EI.TieneIncidencia = 1 AND EI.IDIncidencia = ''ASISTENCIA'') AS ASISTENCIA, 
				   ' + @Selects + '				   
			FROM #TblNormalizada N
			)
			SELECT(
				SELECT * FROM  (
					SELECT IDSucursal, IDDepartamento, IDPuesto, Sucursal, Departamento, Puesto, CONTRATADO, STAFF_PPTO, ASISTENCIA
							, ' + @Columns + '
							, ' + @SumaAusentismosConPago + ' AS AUS_C_PAGO
							, ' + @SumaAusentismosSinPago + ' AS AUS_S_PAGO
							, ' + @SumaAusentismos + ' AS AUSENTISMOS
							, CONTRATADO - (' + @SumaAusentismos + ') AS PRODUCTIVO_DIA
							, CONTRATADO - STAFF_PPTO AS CONTRATADO_VS_STAFF
							, (CONTRATADO - (' + @SumaAusentismos + ')) - STAFF_PPTO AS PRODUCTIVO_VS_STAFF
					FROM tblIncidencias					
				
					UNION ALL
				
					SELECT IDSucursal, IDDepartamento, 10000 AS IDPuesto, Sucursal, Departamento, ''TOTAL'' AS Puesto						   
						   , SUM(CONTRATADO)
						   , SUM(STAFF_PPTO)
						   , SUM(ASISTENCIA)
						   , ' + @SumaTotalColumns + '
						   , SUM(' + @SumaAusentismosConPago + ') AS AUS_C_PAGO
						   , SUM(' + @SumaAusentismosSinPago + ') AS AUS_S_PAGO
						   , SUM(' + @SumaAusentismos + ')  AS AUSENTISMOS
						   , SUM(CONTRATADO - (' + @SumaAusentismos + '))  AS PRODUCTIVO_DIA
						   , SUM(CONTRATADO - STAFF_PPTO) AS CONTRATADO_VS_STAFF
						   , SUM((CONTRATADO - (' + @SumaAusentismos + ')) - STAFF_PPTO) AS PRODUCTIVO_VS_STAFF
					FROM tblIncidencias
					GROUP BY IDSucursal, IDDepartamento, Sucursal, Departamento

				) AS ConsultaCombinada
				ORDER BY IDSucursal, IDDepartamento, IDPuesto
				FOR JSON AUTO
			) AS ResultJson
		'
		
		--PRINT @Qry
		EXEC (@Qry)
		

END
GO

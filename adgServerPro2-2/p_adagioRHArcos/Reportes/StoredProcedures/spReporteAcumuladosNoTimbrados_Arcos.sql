USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteAcumuladosNoTimbrados_Arcos](
		
	 @dtFiltros [Nomina].[dtFiltrosRH] READONLY
	,@IDUsuario INT
		
) AS

BEGIN

		DECLARE 
			 @Ejercicio INT
			,@IDTipoNomina INT
			,@IDMesInicio INT
			,@IDMesFin INT
			,@IDRazonSocial INT
			,@QueryOption VARCHAR(10)
		;

		SELECT @Ejercicio = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Ejercicio'),',')),0)
		SELECT @IDTipoNomina = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'TipoNomina'),',')),0)
		SELECT @IDMesInicio = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'IDMes'),',')),0)
		SELECT @IDMesFin = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'IDMesFin'),',')),0)
		SELECT @IDRazonSocial = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'RazonesSociales'),',')),0)
		SELECT @QueryOption = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'ClaveEmpleadoInicial'),',')),0)


		IF (@QueryOption = 0 OR @QueryOption IS NULL)
		BEGIN 

			RAISERROR('SELECCIONE UNA OPCION DE RESULTADOS',16,1)
			RETURN;

		END


		IF (@IDRazonSocial = 0 OR @IDRazonSocial IS NULL)
		BEGIN 

			RAISERROR('SELECCIONE UNA RAZON SOCIAL',16,1)
			RETURN;

		END


		IF OBJECT_ID('TempDB..#TempData')  IS NOT NULL DROP TABLE #TempData
		IF OBJECT_ID('TempDB..#TempData2') IS NOT NULL DROP TABLE #TempData2
		IF OBJECT_ID('TempDB..#TempData3') IS NOT NULL DROP TABLE #TempData3
		IF OBJECT_ID('TempDB..#TempFolios') IS NOT NULL DROP TABLE #TempFolios
		IF OBJECT_ID('TempDB..#TempFolios2') IS NOT NULL DROP TABLE #TempFolios2

		SELECT 
			 HEP.IDHistorialEmpleadoPeriodo AS Folio 
			,P.IDPeriodo AS IDPeriodo
			,P.IDTipoNomina as IDTipoNomina
			,P.ClavePeriodo+' '+P.Descripcion AS Periodo
			,M.IDEmpleado AS IDempleado
			,M.ClaveEmpleado AS ClaveEmpleado
			,M.NOMBRECOMPLETO AS Nombre
			,R.IDRegPatronal AS IDRegPatronal
			,R.RegistroPatronal AS Registro_Patronal
			,R.RazonSocial AS Razon_Social
			,E.IdEmpresa AS IDEmpresa
			,E.NombreComercial AS RazonSocial
		INTO #TempData
		FROM Nomina.tblHistorialesEmpleadosPeriodos HEP
			 INNER JOIN Nomina.tblCatPeriodos P ON P.IDPeriodo = HEP.IDPeriodo
			 INNER JOIN RH.tblEmpleadosMaster M ON M.IDEmpleado = HEP.IDEmpleado
			 INNER JOIN RH.tblCatRegPatronal R ON R.IDRegPatronal = HEP.IDRegPatronal
			 INNER JOIN RH.tblEmpresa E ON E.IdEmpresa = HEP.IDEmpresa
		WHERE P.Ejercicio = @Ejercicio

--select * from #tempdata
--return

		SELECT 
			 IDHistorialEmpleadoPeriodo 
			,IDEstatusTimbrado
			,Actual
		INTO #TempData2
		FROM Facturacion.TblTimbrado
		WHERE IDHistorialEmpleadoPeriodo IN (SELECT Folio FROM #TempData)
		
		SELECT Folio 
		INTO #TempFolios
		FROM #TempData
		WHERE Folio NOT IN (SELECT DISTINCT IDHistorialEmpleadoPeriodo FROM #TempData2)

		SELECT IDHistorialEmpleadoPeriodo
		INTO #TempFolios2
		FROM #TempData2
		WHERE IDEstatusTimbrado <> 2 AND Actual = 1
		UNION ALL
		SELECT Folio
		FROM #TempFolios

--select * from #tempdata2
--select * from #TempFolios
--select * from #TempFolios2
--return

		DECLARE @TempFolios AS TABLE (
			 Folio INT
			,TotalGravado DECIMAL(18,2)
			,TotalPercepciones DECIMAL(18,2)
			,TotalDeducciones DECIMAL(18,2)
			,TotalExcento DECIMAL(18,2)
			,TotalImpuestos DECIMAL(18,2)
		);

		DECLARE 
			 @Counter INT
			,@Folio INT

		SELECT @Counter = MIN(IDHistorialEmpleadoPeriodo) FROM #TempFolios2

		WHILE @Counter <= (SELECT MAX(IDHistorialEmpleadoPeriodo) FROM #TempFolios2)

		BEGIN

			SELECT @Folio = IDHistorialEmpleadoPeriodo FROM #TempFolios2 WHERE IDHistorialEmpleadoPeriodo = @Counter

			INSERT INTO @TempFolios(Folio,TotalGravado,TotalPercepciones,TotalDeducciones,TotalExcento,TotalImpuestos)
			EXEC [Reportes].[spReporteAcumuladoTimbrado] @Folio

			SELECT @Counter = MIN(IDHistorialEmpleadoPeriodo) FROM #TempFolios2 WHERE IDHistorialEmpleadoPeriodo > @Counter

		END

			SELECT 
				 M.IDEmpleado
				,M.ClaveEmpleado
				,M.NOMBRECOMPLETO
				,M.RFC
				,P.IDPeriodo
				,P.IDTipoNomina
				,Mes.IDMes
				,Mes.Descripcion AS [Mes ]
				,P.ClavePeriodo+' '+P.Descripcion AS Periodo
				,E.IDEmpresa
				,E.NombreComercial AS Empresa
				,R.IDRegPatronal
				,R.RegistroPatronal
				,F.* 
				,ROW_NUMBER() OVER (PARTITION BY F.Folio ORDER BY F.Folio ) AS [RN ]
			INTO #TempData3
			FROM @TempFolios F
				 INNER JOIN Nomina.tblHistorialesEmpleadosPeriodos HEP ON HEP.IDHistorialEmpleadoPeriodo = F.Folio
				 INNER JOIN Nomina.tblCatPeriodos P ON P.IDPeriodo = HEP.IDPeriodo 
				 INNER JOIN Nomina.tblCatMeses Mes ON Mes.IDMes = P.IDMes
				 INNER JOIN RH.tblEmpleadosMaster M ON M.IDEmpleado = HEP.IDEmpleado
				 INNER JOIN RH.tblEmpresa E ON E.IDEmpresa = HEP.IDEmpresa
				 INNER JOIN RH.tblCatRegPatronal R ON R.IDRegPatronal = HEP.IDRegPatronal

--select * from #tempdata3
--return

			IF (@QueryOption = 1) 
			BEGIN

			PRINT 'FOLIOS INDIVIDUAL'

				SELECT 
					 ClaveEmpleado AS Clave
					,NOMBRECOMPLETO AS Nombre
					,RFC AS [RFC ]
					,[Mes ]
					,Periodo
					,Empresa AS Razon_Social
					,RegistroPatronal AS Reg_Patronal
					,Folio AS Folio
					,TotalGravado AS Gravado
					,TotalExcento AS Excento
					,TotalPercepciones AS Percepciones
					,TotalDeducciones AS Deducciones
					,TotalImpuestos AS Impuestos
				FROM #TempData3
				WHERE IDTipoNomina = @IDTipoNomina 
					  AND IDEmpresa = @IDRazonSocial
					  AND IDMes >= @IDMesInicio AND IDMes <= @IDMesFin
				ORDER BY 
					   IDMes
					  ,IDPeriodo
					  ,IDEmpresa
					  ,IDRegPatronal
					  ,ClaveEmpleado
					  ,Folio
			
			END;


			IF (@QueryOption = 2) 
			BEGIN

			PRINT 'AGRUPADO EMPLEADOS MENSUAL'

				SELECT
				     ClaveEmpleado AS Clave
					,NOMBRECOMPLETO AS Nombre
					,RFC AS [RFC ]
					,IDMes AS [Mes ]
					,[Mes ] AS Descripcion
					,Empresa AS Razon_Social
					,SUM(TotalGravado) AS Gravado
					,SUM(TotalExcento) AS Excento
					,SUM(TotalPercepciones) AS Percepciones
					,SUM(TotalDeducciones) AS Deducciones
					,SUM(TotalImpuestos) AS Impuestos
				FROM #TempData3
				WHERE IDTipoNomina = @IDTipoNomina 
					  AND IDEmpresa = @IDRazonSocial
					  AND IDMes >= @IDMesInicio AND IDMes <= @IDMesFin
				GROUP BY
					 ClaveEmpleado
					,NOMBRECOMPLETO
					,RFC
					,IDMes
					,[Mes ]
					,Empresa
				ORDER BY 
					 ClaveEmpleado
					,IDMes

			END;


			IF (@QueryOption = 3) 
			BEGIN

			PRINT 'AGRUPADO EMPLEADOS ANUAL'

				SELECT
				     ClaveEmpleado AS Clave
					,NOMBRECOMPLETO AS Nombre
					,RFC AS [RFC ]
					,Empresa AS Razon_Social
					,SUM(TotalGravado) AS Gravado
					,SUM(TotalExcento) AS Excento
					,SUM(TotalPercepciones) AS Percepciones
					,SUM(TotalDeducciones) AS Deducciones
					,SUM(TotalImpuestos) AS Impuestos
				FROM #TempData3
				WHERE IDTipoNomina = @IDTipoNomina 
					  AND IDEmpresa = @IDRazonSocial
					  AND IDMes >= @IDMesInicio AND IDMes <= @IDMesFin
				GROUP BY
					 ClaveEmpleado
					,NOMBRECOMPLETO
					,RFC
					,Empresa
				ORDER BY 
					 ClaveEmpleado

			END;


			IF (@QueryOption = 4) 
			BEGIN

			PRINT 'AGRUPADO EMPRESA MENSUAL'

				SELECT
					 IDMes AS [Mes ]
					,[Mes ] AS Descripcion
					,Empresa AS Razon_Social
					,SUM(TotalGravado) AS Gravado
					,SUM(TotalExcento) AS Excento
					,SUM(TotalPercepciones) AS Percepciones
					,SUM(TotalDeducciones) AS Deducciones
					,SUM(TotalImpuestos) AS Impuestos
				FROM #TempData3
				WHERE IDTipoNomina = @IDTipoNomina 
					  AND IDEmpresa = @IDRazonSocial
					  AND IDMes >= @IDMesInicio AND IDMes <= @IDMesFin
				GROUP BY
					 IDMes
					,[Mes ]
					,Empresa
				ORDER BY 
					 IDMes
					,Empresa

			END;

END
GO

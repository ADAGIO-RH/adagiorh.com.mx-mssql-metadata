USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spReporteAcumulados_Arcos](
		
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
			,@Detalle VARCHAR(10) = 'FALSE'

		SELECT @Ejercicio = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Ejercicio'),',')),0)
		SELECT @IDTipoNomina = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'TipoNomina'),',')),0)
		SELECT @IDMesInicio = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'IDMes'),',')),0)
		SELECT @IDMesFin = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'IDMesFin'),',')),0)
		SELECT @IDRazonSocial = ISNULL((SELECT TOP 1 CAST(Item AS INT) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'RazonesSociales'),',')),0)
		SELECT @Detalle = ISNULL((SELECT TOP 1 CAST(Item AS VARCHAR(10)) FROM App.Split((SELECT TOP 1 Value FROM @dtFiltros WHERE Catalogo = 'Detalle'),',')),0)

		IF OBJECT_ID('TempDB..#TempData')  IS NOT NULL DROP TABLE #TempData
		IF OBJECT_ID('TempDB..#TempData2') IS NOT NULL DROP TABLE #TempData2
		IF OBJECT_ID('TempDB..#TempData3') IS NOT NULL DROP TABLE #TempData3

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

		SELECT * 
		INTO #TempData2
		FROM Facturacion.TblTimbrado
		WHERE IDHistorialEmpleadoPeriodo IN (SELECT Folio FROM #TempData)
			  AND IDEstatusTimbrado = 2

--select * from #tempdata2

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

		SELECT @Counter = MIN(IDHistorialEmpleadoPeriodo) FROM #TempData2

		WHILE @Counter <= (SELECT MAX(IDHistorialEmpleadoPeriodo) FROM #TempData2)

		BEGIN

			SELECT @Folio = IDHistorialEmpleadoPeriodo FROM #TempData2 WHERE IDHistorialEmpleadoPeriodo = @Counter

			INSERT INTO @TempFolios(Folio,TotalGravado,TotalPercepciones,TotalDeducciones,TotalExcento,TotalImpuestos)
			EXEC [Reportes].[spReporteAcumuladoTimbrado] @Folio

			SELECT @Counter = MIN(IDHistorialEmpleadoPeriodo) FROM #TempData2 WHERE IDHistorialEmpleadoPeriodo > @Counter

		END

			SELECT 
				 M.IDEmpleado
				,M.ClaveEmpleado
				,M.NOMBRECOMPLETO
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
				,T.UUID
				,ROW_NUMBER() OVER (PARTITION BY F.Folio ORDER BY F.Folio ) AS [RN ]
			INTO #TempData3
			FROM @TempFolios F
				 INNER JOIN Nomina.tblHistorialesEmpleadosPeriodos HEP ON HEP.IDHistorialEmpleadoPeriodo = F.Folio
				 INNER JOIN Nomina.tblCatPeriodos P ON P.IDPeriodo = HEP.IDPeriodo 
				 INNER JOIN Nomina.tblCatMeses Mes ON Mes.IDMes = P.IDMes
				 INNER JOIN RH.tblEmpleadosMaster M ON M.IDEmpleado = HEP.IDEmpleado
				 INNER JOIN RH.tblEmpresa E ON E.IDEmpresa = HEP.IDEmpresa
				 INNER JOIN RH.tblCatRegPatronal R ON R.IDRegPatronal = HEP.IDRegPatronal
				 INNER JOIN Facturacion.TblTimbrado T ON T.IDHistorialEmpleadoPeriodo = F.Folio AND T.IDEstatusTimbrado = 2

--select * from #tempdata3

			IF (@Detalle = 'FALSE') 
			BEGIN

				SELECT 
					 ClaveEmpleado AS Clave
					,NOMBRECOMPLETO AS Nombre
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
					,UUID AS UUID
					,CASE WHEN [RN ] = 1 THEN '' ELSE 'Duplicado' END AS Duplicado
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
			
			END ELSE
				BEGIN

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

				END

END
GO

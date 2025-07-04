USE [p_adagioRHThangos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************
** Descripción     : 
** Autor           : Javier Peña
** Email           : jpena@adagio.com.mx
** FechaCreacion   : 2024-07-31
** Parámetros      :    
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd) Autor            Comentario
------------------ ---------------- ------------------------------------------------------------

***************************************************************************************************/

CREATE   PROCEDURE [Reportes].[spReporteBasicoVariablesBimestralesExcel](    	             
     @dtFiltros [Nomina].[dtFiltrosRH] READONLY
    ,@IDUsuario                         INT = 0    
)
AS
BEGIN
    DECLARE
         @IDControlCalculoVariables                  INT
        ,@ClasificacionesCorporativas                VARCHAR(MAX) = ''
        ,@Departamentos                              VARCHAR(MAX) = ''
        ,@Divisiones                                 VARCHAR(MAX) = ''
        ,@Puestos                                    VARCHAR(MAX) = ''
        ,@Sucursales                                 VARCHAR(MAX) = ''
        ,@Clientes                                   VARCHAR(MAX) = ''

        ,@IDBimestre                                 INT
        ,@DescripcionBimestre                        VARCHAR(MAX)
        ,@FechaInicioBimestre                        DATE
        ,@FechaFinBimestre                           DATE
        ,@Ejercicio                                  INT
        ,@showDetails                                BIT
        ,@cols                                       AS VARCHAR(MAX)
        ,@colsAlone                                  AS VARCHAR(MAX)
        ,@query1                                     NVARCHAR(MAX)
        ,@query2                                     NVARCHAR(MAX) 
        ,@join                                       NVARCHAR(MAX) = ''
        ,@SQL                                        NVARCHAR(MAX)
        ,@WhereClause                                NVARCHAR(MAX) = ''    
        ,@OrderBy                                    NVARCHAR(MAX) = ' ORDER BY ClaveEmpleado';

    SET @IDControlCalculoVariables = (SELECT TOP 1 CAST(VALUE AS INT) FROM @dtFiltros WHERE CATALOGO = 'IDControlCalculoVariablesVarchar')
    SET @Departamentos = (SELECT TOP 1 VALUE FROM @dtFiltros WHERE CATALOGO = 'Departamentos')
    SET @Sucursales = (SELECT TOP 1 VALUE FROM @dtFiltros WHERE CATALOGO = 'Sucursales')
    SET @Puestos = (SELECT TOP 1 VALUE FROM @dtFiltros WHERE CATALOGO = 'Puestos')
    SET @ClasificacionesCorporativas = (SELECT TOP 1 VALUE FROM @dtFiltros WHERE CATALOGO = 'ClasificacionesCorporativas')
    SET @Divisiones = (SELECT TOP 1 VALUE FROM @dtFiltros WHERE CATALOGO = 'Divisiones')
    SET @Clientes = (SELECT TOP 1 VALUE FROM @dtFiltros WHERE CATALOGO = 'Clientes')
    SET @showDetails = CASE WHEN (SELECT TOP 1 VALUE FROM @dtFiltros WHERE CATALOGO = 'showDetails') = 'true' THEN 1 ELSE 0 END;



    SELECT
        @IDBimestre     = IDBimestre,           
        @Ejercicio      = Ejercicio
    FROM Nomina.tblControlCalculoVariablesBimestrales
    WHERE IDControlCalculoVariables = @IDControlCalculoVariables;

    SELECT @DescripcionBimestre = Descripcion 
    FROM Nomina.tblCatBimestres WITH (NOLOCK) 
    WHERE IDBimestre = @IDBimestre;

    SELECT @FechaInicioBimestre = MIN(DATEADD(MONTH,IDMes-1,DATEADD(YEAR,@Ejercicio-1900,0)))   
    FROM Nomina.tblCatMeses WITH (NOLOCK)  
    WHERE CAST(IDMes AS VARCHAR) IN (
        SELECT item 
        FROM app.Split(
            (SELECT TOP 1 meses 
             FROM Nomina.tblCatBimestres WITH (NOLOCK) 
             WHERE IDBimestre = @IDBimestre), ',')
        );

    SET @FechaFinBimestre = [Asistencia].[fnGetFechaFinBimestre](@FechaInicioBimestre);

    if object_id('tempdb..#tempConceptos') is not null drop table #tempConceptos 
    if object_id('tempdb..#TempData') is not null drop table #TempData 

    IF (@showDetails = 1)
    BEGIN
        SELECT DISTINCT 
		c.IDConcepto,
		replace(replace(replace(replace(replace(c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.',''),'(',''),')','') as Concepto,
		c.IDTipoConcepto as IDTipoConcepto,
		c.TipoConcepto,
		c.Orden as OrdenCalculo,
		CASE WHEN c.IDTipoConcepto in (1,4) THEN 1
			 WHEN c.IDTipoConcepto = 2 THEN 2
			 WHEN c.IDTipoConcepto = 3 THEN 3
			 WHEN c.IDTipoConcepto = 6 THEN 4
			 WHEN c.IDTipoConcepto = 5 THEN 5
			 ELSE 0
			 END AS OrdenColumn,
		1 AS Origen
	    INTO #tempConceptos
	    FROM (SELECT 
		        	ccc.*
		        	,tc.Descripcion as TipoConcepto
		        	,crr.Orden
		        FROM Nomina.tblCatConceptos ccc with (nolock) 
		        	INNER JOIN Nomina.tblCatTipoConcepto tc with (nolock) on tc.IDTipoConcepto = ccc.IDTipoConcepto
		        	INNER JOIN Reportes.tblConfigReporteRayas crr with (nolock)  on crr.IDConcepto = ccc.IDConcepto and crr.Impresion = 1
                    INNER JOIN Nomina.tblConfigReporteVariablesBimestrales confv with (nolock)  on ccc.IDConcepto in (select item from app.Split(isnull(confv.ConceptosValesDespensa,'') +','+isnull(confv.ConceptosPremioPuntualidad,'')+','+isnull(confv.ConceptosPremioAsistencia,'')+','+isnull(confv.ConceptosIntegrablesVariables,'')+','+isnull(confv.ConceptosHorasExtrasDobles,''),','))			
		        ) c 
	
	    INSERT INTO #tempConceptos
		    SELECT DISTINCT 
		    c.IDConcepto,
		    replace(replace(replace(replace(replace('INTEGRABLE'+'_'+c.Descripcion+'_'+c.Codigo,' ','_'),'-',''),'.',''),'(',''),')','') as Concepto,
		    c.IDTipoConcepto as IDTipoConcepto,
		    c.TipoConcepto,
		    c.Orden as OrdenCalculo,
		    CASE WHEN c.IDTipoConcepto in (1,4) THEN 1
		    	 WHEN c.IDTipoConcepto = 2 THEN 2
		    	 WHEN c.IDTipoConcepto = 3 THEN 3
		    	 WHEN c.IDTipoConcepto = 6 THEN 4
		    	 WHEN c.IDTipoConcepto = 5 THEN 5
		    	 ELSE 0
		    	 END AS OrdenColumn,
		    2 AS Origen
            FROM (SELECT 
                    ccc.*
                    ,tc.Descripcion as TipoConcepto
                    ,crr.Orden
                FROM Nomina.tblCatConceptos ccc WITH (NOLOCK) 
                    INNER JOIN Nomina.tblCatTipoConcepto tc WITH (NOLOCK) on tc.IDTipoConcepto = ccc.IDTipoConcepto
                    INNER JOIN Reportes.tblConfigReporteRayas crr WITH (NOLOCK)  on crr.IDConcepto = ccc.IDConcepto AND crr.Impresion = 1
                    INNER JOIN Nomina.tblConfigReporteVariablesBimestrales confv WITH (NOLOCK)  on ccc.IDConcepto in (SELECT item FROM app.Split(isnull(confv.ConceptosValesDespensa,'') +','+isnull(confv.ConceptosPremioPuntualidad,'')+','+isnull(confv.ConceptosPremioAsistencia,'')+','+isnull(confv.ConceptosIntegrablesVariables,'')+','+isnull(confv.ConceptosHorasExtrasDobles,''),','))			
                ) c 

            SET @cols = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(c.Concepto)+',0) AS '+ QUOTENAME(c.Concepto)
	        			FROM #tempConceptos c
	        			GROUP BY c.Concepto,c.OrdenColumn,c.OrdenCalculo,c.Origen
	        			ORDER BY c.OrdenCalculo,c.Origen  desc,c.OrdenColumn
	        			FOR XML PATH(''), TYPE
	        			).value('.', 'VARCHAR(MAX)') 
	        		,1,1,'');
        
	        SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(c.Concepto)
	        			FROM #tempConceptos c
	        			GROUP BY c.Concepto,c.OrdenColumn,c.OrdenCalculo,c.Origen
	        			ORDER BY c.OrdenCalculo,c.Origen  desc,c.OrdenColumn
	        			FOR XML PATH(''), TYPE
	        			).value('.', 'VARCHAR(MAX)') 
	        		,1,1,'');
            
            SELECT     
                BM.IDEmpleado                                                         AS [IDEmpleado],    
                E.ClaveEmpleado                                                       AS [Clave Empleado],
                E.NOMBRECOMPLETO                                                      AS [Nombre Completo],
                E.IMSS                                                                AS [NSS ],
                FORMAT(BM.FechaAntiguedad,'dd/MM/yyyy')                               AS [Fecha de Antiguedad],            
                BM.SalarioDiario                                                      AS [Salario Diario],
                BM.SalarioVariable                                                    AS [Salario Variable],
                BM.SalarioIntegrado                                                   AS [Salario Integrado],
                BM.NuevoFactor                                                        AS [Nuevo Factor],
                BM.Dias                                                               AS [Dias],
                CASE WHEN BM.VariableCambio = 1 THEN 'SI' ELSE 'NO' END               AS [Cambio Variable],
                CASE WHEN BM.FactorCambio = 1 THEN 'SI' ELSE 'NO' END                 AS [Cambio Factor],
                CASE WHEN BM.Afectar = 1 THEN 'SI' ELSE 'NO' END                      AS [Genera M/s],        
                CASE WHEN BM.IDMovAfiliatorio IS NOT NULL THEN 'SI' ELSE 'NO' END     AS [Movimiento Afiliatorio Generado],
                FORMAT(BM.FechaUltimoMovimiento,'dd/MM/yyyy')                         AS [Fecha Ultimo Mov],
                BM.AnteriorSalarioDiario                                              AS [Ultimo S.D],
                BM.AnteriorSalarioVariable                                            AS [Ultimo S.V],
                BM.AnteriorSalarioIntegrado                                           AS [Ultimo S.I],
                BM.FactorAntiguo                                                      AS [Ultimo Factor],        
                @DescripcionBimestre                                                  AS [Bimestre],
                @Ejercicio                                                            AS [Ejercicio],                        
                FORMAT(BM.DiaAplicacion,'dd/MM/yyyy')                                 AS [Fecha Aplicación],
                BM.CriterioDias                                                       AS [Criterio de Dias],
                BM.CriterioUMA                                                        AS [Criterio UMA],
                BM.UMA                                                                AS [UMA ],        
                BM.SalarioMinimo                                                      AS [Salario Minimo],      
                CASE WHEN C.Aplicar = 1 THEN 'SI' ELSE 'NO' END                       AS [Control de Variables Aplicado],
                isnull(D.Importetotal1,0)                                             AS [ImporteTotal1],
                Con.Concepto                                                          AS [Concepto]                
            INTO #TempData
            FROM NOMINA.TblCalculoVariablesBimestralesMaster BM    
            INNER JOIN Nomina.tblControlCalculoVariablesBimestrales C ON C.IDControlCalculoVariables = BM.IDControlCalculoVariables
            INNER JOIN RH.tblEmpleadosMaster E ON E.IDEmpleado = BM.IDEmpleado
            LEFT JOIN Nomina.TblCalculoVariablesBimestralesDetalle D ON D.IDCalculoVariablesBimestralesMaster=BM.IDCalculoVariablesBimestralesMaster
            LEFT JOIN #tempConceptos Con
	        		on Con.IDConcepto = D.IDConcepto
	        		and Con.Origen = 1
            WHERE BM.IDControlCalculoVariables = @IDControlCalculoVariables           
            ORDER BY E.ClaveEmpleado
        
            INSERT INTO #TempData
             SELECT   
                BM.IDEmpleado                                                         AS [IDEmpleado],
                E.ClaveEmpleado                                                       AS [Clave Empleado],
                E.NOMBRECOMPLETO                                                      AS [Nombre Completo],
                E.IMSS                                                                AS [NSS ],
                FORMAT(BM.FechaAntiguedad,'dd/MM/yyyy')                               AS [Fecha de Antiguedad],            
                BM.SalarioDiario                                                      AS [Salario Diario],
                BM.SalarioVariable                                                    AS [Salario Variable],
                BM.SalarioIntegrado                                                   AS [Salario Integrado],
                BM.NuevoFactor                                                        AS [Nuevo Factor],
                BM.Dias                                                               AS [Dias],
                CASE WHEN BM.VariableCambio = 1 THEN 'SI' ELSE 'NO' END               AS [Cambio Variable],
                CASE WHEN BM.FactorCambio = 1 THEN 'SI' ELSE 'NO' END                 AS [Cambio Factor],
                CASE WHEN BM.Afectar = 1 THEN 'SI' ELSE 'NO' END                      AS [Genera M/s],        
                CASE WHEN BM.IDMovAfiliatorio IS NOT NULL THEN 'SI' ELSE 'NO' END     AS [Movimiento Afiliatorio Generado],
                FORMAT(BM.FechaUltimoMovimiento,'dd/MM/yyyy')                         AS [Fecha Ultimo Mov],
                BM.AnteriorSalarioDiario                                              AS [Ultimo S.D],
                BM.AnteriorSalarioVariable                                            AS [Ultimo S.V],
                BM.AnteriorSalarioIntegrado                                           AS [Ultimo S.I],
                BM.FactorAntiguo                                                      AS [Ultimo Factor],        
                @DescripcionBimestre                                                  AS [Bimestre],
                @Ejercicio                                                            AS [Ejercicio],                        
                FORMAT(BM.DiaAplicacion,'dd/MM/yyyy')                                 AS [Fecha Aplicación],
                BM.CriterioDias                                                       AS [Criterio de Dias],
                BM.CriterioUMA                                                        AS [Criterio UMA],
                BM.UMA                                                                AS [UMA ],        
                BM.SalarioMinimo                                                      AS [Salario Minimo],      
                CASE WHEN C.Aplicar = 1 THEN 'SI' ELSE 'NO' END                       AS [Control de Variables Aplicado],
                isnull(Integrable,0)                                                  AS [ImporteTotal1],   
                Con.Concepto                                                          AS [Concepto]                
            FROM NOMINA.TblCalculoVariablesBimestralesMaster BM    
            INNER JOIN Nomina.tblControlCalculoVariablesBimestrales C ON C.IDControlCalculoVariables = BM.IDControlCalculoVariables    
            INNER JOIN RH.tblEmpleadosMaster E ON E.IDEmpleado = BM.IDEmpleado
            LEFT JOIN Nomina.TblCalculoVariablesBimestralesDetalle D ON D.IDCalculoVariablesBimestralesMaster=BM.IDCalculoVariablesBimestralesMaster
            LEFT JOIN #tempConceptos Con
	        		on Con.IDConcepto = D.IDConcepto
	        		and Con.Origen = 2
            WHERE BM.IDControlCalculoVariables = @IDControlCalculoVariables
            ORDER BY E.ClaveEmpleado
            
        
            
        
            IF @ClasificacionesCorporativas <> ''
            BEGIN
                SET @join = @join + N' LEFT JOIN RH.tblClasificacionCorporativaEmpleado CC ON CC.IDEmpleado = BM.IDEmpleado AND CC.FechaIni <= '''+FORMAT(@FechaFinBimestre,'yyyy-MM-dd')+''' AND CC.FechaFin >= '''+FORMAT(@FechaFinBimestre,'yyyy-MM-dd')+'''';
                SET @WhereClause = @WhereClause + N' AND CC.IDClasificacionCorporativa IN (SELECT item FROM app.Split('''+@ClasificacionesCorporativas+''', '',''))';
            END
        
            IF @Departamentos <> ''
            BEGIN
                SET @join = @join + N' LEFT JOIN RH.tblDepartamentoEmpleado DE ON DE.IDEmpleado = BM.IDEmpleado AND DE.FechaIni <= '''+FORMAT(@FechaFinBimestre,'yyyy-MM-dd')+''' AND DE.FechaFin >= '''+FORMAT(@FechaFinBimestre,'yyyy-MM-dd')+'''';
                SET @WhereClause = @WhereClause + N' AND DE.IDDepartamento IN (SELECT item FROM app.Split('''+@Departamentos+''', '',''))';
            END
        
            IF @Divisiones <> ''
            BEGIN
                SET @join = @join + N' LEFT JOIN RH.tblDivisionEmpleado DIE ON DIE.IDEmpleado = BM.IDEmpleado AND DIE.FechaIni <= '''+FORMAT(@FechaFinBimestre,'yyyy-MM-dd')+''' AND DIE.FechaFin >= '''+FORMAT(@FechaFinBimestre,'yyyy-MM-dd')+'''';
                SET @WhereClause = @WhereClause + N' AND DIE.IDDivision IN (SELECT item FROM app.Split('''+@Divisiones+''', '',''))';
            END
        
            IF @Puestos <> ''
            BEGIN
                SET @join = @join + N' LEFT JOIN RH.tblPuestoEmpleado PUE ON PUE.IDEmpleado = BM.IDEmpleado AND PUE.FechaIni <= '''+FORMAT(@FechaFinBimestre,'yyyy-MM-dd')+''' AND PUE.FechaFin >= '''+FORMAT(@FechaFinBimestre,'yyyy-MM-dd')+'''';
                SET @WhereClause = @WhereClause + N' AND PUE.IDPuesto IN (SELECT item FROM app.Split('''+@Puestos+''', '',''))';
            END
        
            IF @Sucursales <> ''
            BEGIN
                SET @join = @join + N' LEFT JOIN RH.tblSucursalEmpleado SUE ON SUE.IDEmpleado = BM.IDEmpleado AND SUE.FechaIni <= '''+FORMAT(@FechaFinBimestre,'yyyy-MM-dd')+''' AND SUE.FechaFin >= '''+FORMAT(@FechaFinBimestre,'yyyy-MM-dd')+'''';
                SET @WhereClause = @WhereClause + N' AND SUE.IDSucursal IN (SELECT item FROM app.Split('''+@Sucursales+''', '',''))';
            END

            IF @Clientes <> ''
            BEGIN
                SET @join = @join + N' LEFT JOIN RH.tblClienteEmpleado CCE ON CCE.IDEmpleado = BM.IDEmpleado AND CCE.FechaIni<= '''+FORMAT(@FechaFinBimestre,'yyyy-MM-dd')+''' AND CCE.FechaFin >= '''+FORMAT(@FechaFinBimestre,'yyyy-MM-dd')+'''';
                SET @WhereClause = @WhereClause + N' AND CCE.IDCliente IN (SELECT item FROM app.Split('''+@Clientes+''', '',''))';
                
            END
            
            SET @query1 = N'SELECT [Clave Empleado],
                                  [Nombre Completo],
                                  [NSS ],
                                  [Fecha de Antiguedad],  
                                  [Salario Diario],
                                  [Salario Variable],
                                  [Salario Integrado],
                                  [Nuevo Factor],
                                  [Dias],
                                  [Cambio Variable],
                                  [Cambio Factor],
                                  [Genera M/s], 
                                  [Movimiento Afiliatorio Generado],
                                  [Fecha Ultimo Mov],
                                  [Ultimo S.D],
                                  [Ultimo S.V],
                                  [Ultimo S.I],
                                  [Ultimo Factor],
                                  [Bimestre],
                                  [Ejercicio],
                                  [Fecha Aplicación],
                                  [Criterio de Dias],
                                  [Criterio UMA],
                                  [UMA ],        
                                  [Salario Minimo],  
                                  [Control de Variables Aplicado],'+ @cols +'FROM ( SELECT BM.* FROM #TempData BM '+@join+' WHERE 1=1 '+@WhereClause+') x'
            SET @query2 = '
	        			pivot 
	        			(
	        				 SUM(ImporteTotal1)
	        				for Concepto in (' + @colsAlone + ')
	        			) p 
        
	        			'
            
            EXEC( @query1 + @query2)

             

    END
    ELSE
    BEGIN
        SET @SQL = N'
            SELECT         
                E.ClaveEmpleado                                                       AS [Clave Empleado],
                E.NOMBRECOMPLETO                                                      AS [Nombre Completo],
                E.IMSS                                                                AS [NSS ],
                FORMAT(BM.FechaAntiguedad,''dd/MM/yyyy'')                             AS [Fecha de Antiguedad],            
                BM.SalarioDiario                                                      AS [Salario Diario],
                BM.SalarioVariable                                                    AS [Salario Variable],
                BM.SalarioIntegrado                                                   AS [Salario Integrado],
                BM.NuevoFactor                                                        AS [Nuevo Factor],
                BM.Dias                                                               AS [Dias],
                CASE WHEN BM.VariableCambio = 1 THEN ''SI'' ELSE ''NO'' END           AS [Cambio Variable],
                CASE WHEN BM.FactorCambio = 1 THEN ''SI'' ELSE ''NO'' END             AS [Cambio Factor],
                CASE WHEN BM.Afectar = 1 THEN ''SI'' ELSE ''NO'' END                  AS [Genera M/s],        
                CASE WHEN BM.IDMovAfiliatorio IS NOT NULL THEN ''SI'' ELSE ''NO'' END AS [Movimiento Afiliatorio Generado],
                FORMAT(BM.FechaUltimoMovimiento,''dd/MM/yyyy'')                       AS [Fecha Ultimo Mov],
                BM.AnteriorSalarioDiario                                              AS [Ultimo S.D],
                BM.AnteriorSalarioVariable                                            AS [Ultimo S.V],
                BM.AnteriorSalarioIntegrado                                           AS [Ultimo S.I],
                BM.FactorAntiguo                                                      AS [Ultimo Factor],        
                @DescripcionBimestre                                                  AS [Bimestre],
                @Ejercicio                                                            AS [Ejercicio],                        
                FORMAT(BM.DiaAplicacion,''dd/MM/yyyy'')                               AS [Fecha Aplicación],
                BM.CriterioDias                                                       AS [Criterio de Dias],
                BM.CriterioUMA                                                        AS [Criterio UMA],
                BM.UMA                                                                AS [UMA ],        
                BM.SalarioMinimo                                                      AS [Salario Minimo],      
                CASE WHEN C.Aplicar = 1 THEN ''SI'' ELSE ''NO'' END                   AS [Control de Variables Aplicado]  
            FROM NOMINA.TblCalculoVariablesBimestralesMaster BM
            INNER JOIN Nomina.tblControlCalculoVariablesBimestrales C ON C.IDControlCalculoVariables = BM.IDControlCalculoVariables
            INNER JOIN RH.tblEmpleadosMaster E ON E.IDEmpleado = BM.IDEmpleado';

            SET @WhereClause = N' WHERE BM.IDControlCalculoVariables = @IDControlCalculoVariables';

            IF @ClasificacionesCorporativas <> ''
            BEGIN
                SET @SQL = @SQL + N' LEFT JOIN RH.tblClasificacionCorporativaEmpleado CC ON CC.IDEmpleado = BM.IDEmpleado AND CC.FechaIni <= @FechaFinBimestre AND CC.FechaFin >= @FechaFinBimestre';
                SET @WhereClause = @WhereClause + N' AND CC.IDClasificacionCorporativa IN (SELECT item FROM app.Split(@ClasificacionesCorporativas, '',''))';
            END

            IF @Departamentos <> ''
            BEGIN
                SET @SQL = @SQL + N' LEFT JOIN RH.tblDepartamentoEmpleado DE ON DE.IDEmpleado = BM.IDEmpleado AND DE.FechaIni <= @FechaFinBimestre AND DE.FechaFin >= @FechaFinBimestre';
                SET @WhereClause = @WhereClause + N' AND DE.IDDepartamento IN (SELECT item FROM app.Split(@Departamentos, '',''))';
            END

            IF @Divisiones <> ''
            BEGIN
                SET @SQL = @SQL + N' LEFT JOIN RH.tblDivisionEmpleado DIE ON DIE.IDEmpleado = BM.IDEmpleado AND DIE.FechaIni <= @FechaFinBimestre AND DIE.FechaFin >= @FechaFinBimestre';
                SET @WhereClause = @WhereClause + N' AND DIE.IDDivision IN (SELECT item FROM app.Split(@Divisiones, '',''))';
            END

            IF @Puestos <> ''
            BEGIN
                SET @SQL = @SQL + N' LEFT JOIN RH.tblPuestoEmpleado PUE ON PUE.IDEmpleado = BM.IDEmpleado AND PUE.FechaIni <= @FechaFinBimestre AND PUE.FechaFin >= @FechaFinBimestre';
                SET @WhereClause = @WhereClause + N' AND PUE.IDPuesto IN (SELECT item FROM app.Split(@Puestos, '',''))';
            END

            IF @Sucursales <> ''
            BEGIN
                SET @SQL = @SQL + N' LEFT JOIN RH.tblSucursalEmpleado SUE ON SUE.IDEmpleado = BM.IDEmpleado AND SUE.FechaIni <= @FechaFinBimestre AND SUE.FechaFin >= @FechaFinBimestre';
                SET @WhereClause = @WhereClause + N' AND SUE.IDSucursal IN (SELECT item FROM app.Split(@Sucursales, '',''))';
            END
            IF @Clientes <> ''
            BEGIN
                SET @SQL = @SQL + N' LEFT JOIN RH.tblClienteEmpleado CCE ON CCE.IDEmpleado = BM.IDEmpleado AND CCE.FechaIni <= @FechaFinBimestre AND CCE.FechaFin >= @FechaFinBimestre';
                SET @WhereClause = @WhereClause + N' AND CCE.IDCliente IN (SELECT item FROM app.Split(@Clientes, '',''))';
            END

            SET @SQL = @SQL + @WhereClause
            SET @SQL = @SQL + @OrderBy;



            EXEC sp_executesql @SQL, 
                N'@IDControlCalculoVariables INT, @DescripcionBimestre VARCHAR(MAX), @Ejercicio INT, @FechaFinBimestre DATE,
                  @ClasificacionesCorporativas VARCHAR(MAX),@Departamentos VARCHAR(MAX), @Divisiones VARCHAR(MAX), @Puestos VARCHAR(MAX), @Sucursales VARCHAR(MAX), @Clientes VARCHAR(MAX)', 
                @IDControlCalculoVariables, @DescripcionBimestre, @Ejercicio, @FechaFinBimestre,
                @ClasificacionesCorporativas,@Departamentos, @Divisiones, @Puestos, @Sucursales, @Clientes;
    END
            
    
END
GO

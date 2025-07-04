USE [p_adagioRHIndustrialMefi]
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

CREATE   PROCEDURE [Reportes].[spReporteBasicoVariablesBimestrales](    	    
     @IDControlCalculoVariablesVarchar   VARCHAR(20) 
    ,@ClasificacionesCorporativas       VARCHAR(MAX) = ''
    ,@Departamentos                     VARCHAR(MAX) = ''
    ,@Divisiones                        VARCHAR(MAX) = ''
    ,@Puestos                           VARCHAR(MAX) = ''
    ,@Sucursales                        VARCHAR(MAX) = ''
    ,@IDUsuario                         INT = 0    
)
AS
BEGIN
    DECLARE
        @IDControlCalculoVariables                  INT,
        @IDBimestre                                 INT,
        @DescripcionBimestre                        VARCHAR(MAX),
        @FechaInicioBimestre                        DATE,
        @FechaFinBimestre                           DATE,
        @Ejercicio                                  INT,
        @SQL                                        NVARCHAR(MAX),
        @WhereClause                                NVARCHAR(MAX),
        @OrderBy                                    NVARCHAR(MAX) = ' ORDER BY ClaveEmpleado';

    SET @IDControlCalculoVariables  = CAST(@IDControlCalculoVariablesVarchar AS INT);

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

    SET @SQL = N'
    SELECT 
        BM.IDCalculoVariablesBimestralesMaster                                AS [IDCalculoVariablesBimestralesMaster],
        E.ClaveEmpleado                                                       AS [ClaveEmpleado],
        E.NOMBRECOMPLETO                                                      AS [NOMBRECOMPLETO],
        E.IMSS                                                                AS [IMSS],
        BM.FechaAntiguedad                                                    AS [FechaAntiguedad],
        BM.SalarioDiario                                                      AS [SalarioDiario],
        BM.SalarioVariable                                                    AS [SalarioVariable],
        BM.SalarioIntegrado                                                   AS [SalarioIntegrado],
        BM.NuevoFactor                                                        AS [NuevoFactor],
        BM.Dias                                                               AS [Dias],
        BM.VariableCambio                                                     AS [VariableCambio],
        BM.FactorCambio                                                       AS [FactorCambio],
        BM.Afectar                                                            AS [AFECTAR],
        BM.FechaUltimoMovimiento                                              AS [FechaUltimoMovimiento],
        BM.AnteriorSalarioDiario                                              AS [AnteriorSalarioDiario],
        BM.AnteriorSalarioVariable                                            AS [AnteriorSalarioVariable],
        BM.AnteriorSalarioIntegrado                                           AS [AnteriorSalarioIntegrado],
        BM.FactorAntiguo                                                      AS [FactorAntiguo],
        @DescripcionBimestre                                                  AS [Bimestre],
        @Ejercicio                                                            AS [Ejercicio],
        BM.SalarioMinimo                                                      AS [SalarioMinimo],
        BM.DiaAplicacion                                                      AS [DiaAplicacion],
        BM.CriterioDias                                                       AS [CriterioDias],
        BM.CriterioUMA                                                        AS [CriterioUMA],
        BM.UMA                                                                AS [UMA],
        BM.ConceptosIntegran                                                  AS [ConceptosIntegran],
        CASE WHEN BM.IDMovAfiliatorio IS NOT NULL THEN 1 ELSE 0 END           AS [MovimientoAplicado],
        C.Aplicar                                                             AS [ControlVariablesAplicado]
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

    SET @SQL = @SQL + @WhereClause
	SET @SQL = @SQL + @OrderBy;

    EXEC sp_executesql @SQL, 
        N'@IDControlCalculoVariables INT, @DescripcionBimestre VARCHAR(MAX), @Ejercicio INT, @FechaFinBimestre DATE,
          @ClasificacionesCorporativas VARCHAR(MAX),@Departamentos VARCHAR(MAX), @Divisiones VARCHAR(MAX), @Puestos VARCHAR(MAX), @Sucursales VARCHAR(MAX)', 
        @IDControlCalculoVariables, @DescripcionBimestre, @Ejercicio, @FechaFinBimestre,
        @ClasificacionesCorporativas,@Departamentos, @Divisiones, @Puestos, @Sucursales;
END
GO

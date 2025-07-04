USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar una lista de fecha de colaborador indicando que día estuvo vigente o no asi como en que 
                      registro patronal estuvo.
** Autor			: JCastillo
** Email			: jcastillo@adagio.com.mx
** FechaCreacion	: 2025-05-15
** Paremetros		:              

** DataTypes Relacionados: 

	Si se modifica el result set de esta sp será necesario modificar los siguientes sp's:
		- [Asistencia].[spBuscarEventosCalendario]
		- Reportes.spAsistenciaDiaria

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-29			Aneudy Abreu	Se cambió el Parámetro @IDEmpleado por @dtEmpleados, con esto
									el sp puede retorna la lista de fechas de múltiples empleados.
2024-03-06          Julio Castillo  Se realizo un cambio para mejorar el rendimiento. Se utilizan CTEs 
                                    para disminuir en un 95% el tiempo de ejecucion del procedimiento. 
***************************************************************************************************/
CREATE proc [RH].[spBuscarListaFechasVigenciaRegPatronalEmpleado](
	 @dtEmpleados RH.dtEmpleados readonly
	,@Fechas [App].[dtFechas] READONLY 
	,@IDUsuario int 
	,@IDRegPatronal int

) as
	declare  
		 @IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null
	;


	if object_id('tempdb..#tempMovAfilNew') is not null drop table #tempMovAfilNew;
    
    -- First create the temp table structure
    CREATE TABLE #tempMovAfilNew (
        IDEmpleado int,
        FechaAlta DATE,
        FechaBaja DATE,
        FechaReingreso DATE,
        FechaReingresoAntiguedad DATE,
        IDMovAfiliatorio int,
        Fecha DATE
    );
    -- Use CTEs to simplify the logic and improve performance
    WITH MovimientosBase AS (
        SELECT DISTINCT 
            tm.IDEmpleado,
            Fechas.Fecha
        FROM [IMSS].[tblMovAfiliatorios] tm WITH(NOLOCK)
        JOIN @dtEmpleados e ON tm.IDEmpleado = e.IDEmpleado
        CROSS JOIN @Fechas Fechas
    ),
    MovimientosDetallados AS (
        -- Alta
        SELECT 
            m.IDEmpleado,
            m.Fecha AS MovimientoFecha,
            'ALTA' as TipoMovimiento
        FROM [IMSS].[tblMovAfiliatorios] m WITH(NOLOCK)
        JOIN [IMSS].[tblCatTipoMovimientos] c WITH(NOLOCK) ON m.IDTipoMovimiento = c.IDTipoMovimiento
        WHERE c.Codigo = 'A'

        UNION ALL
        -- Baja
        SELECT 
            m.IDEmpleado,
            m.Fecha,
            'BAJA'
        FROM [IMSS].[tblMovAfiliatorios] m WITH(NOLOCK)
        JOIN [IMSS].[tblCatTipoMovimientos] c WITH(NOLOCK) ON m.IDTipoMovimiento = c.IDTipoMovimiento
        WHERE c.Codigo = 'B'
        UNION ALL
        -- Reingreso
        SELECT 
            m.IDEmpleado,
            m.Fecha,
            'REINGRESO'
        FROM [IMSS].[tblMovAfiliatorios] m WITH(NOLOCK)
        JOIN [IMSS].[tblCatTipoMovimientos] c WITH(NOLOCK) ON m.IDTipoMovimiento = c.IDTipoMovimiento
        WHERE c.Codigo = 'R'
    ),
    MovimientosSalario AS (
        SELECT 
            m.IDEmpleado,
            m.IDMovAfiliatorio,
            ROW_NUMBER() OVER (PARTITION BY m.IDEmpleado ORDER BY m.Fecha DESC) as RN
        FROM [IMSS].[tblMovAfiliatorios] m WITH(NOLOCK)
        JOIN [IMSS].[tblCatTipoMovimientos] c WITH(NOLOCK) ON m.IDTipoMovimiento = c.IDTipoMovimiento
        WHERE c.Codigo IN ('A','M','R')
    ),
    MovimientosReingresoAntiguedad AS ( 
        SELECT 
            m.IDEmpleado,
            m.Fecha,
            ROW_NUMBER() OVER (PARTITION BY m.IDEmpleado ORDER BY m.Fecha DESC) as RN
        FROM [IMSS].[tblMovAfiliatorios] m WITH(NOLOCK)
        JOIN [IMSS].[tblCatTipoMovimientos] c WITH(NOLOCK) ON m.IDTipoMovimiento = c.IDTipoMovimiento
        WHERE c.Codigo IN ('A','R')
        AND ISNULL(RespetarAntiguedad,0) <> 1
    ),
    FinalResults AS (
        SELECT 
            mb.IDEmpleado,
            alta.MovimientoFecha as FechaAlta,
            baja.MovimientoFecha as FechaBaja,
            CASE 
                WHEN baja.MovimientoFecha IS NOT NULL 
                AND reingreso.MovimientoFecha IS NOT NULL 
                AND reingreso.MovimientoFecha > baja.MovimientoFecha 
                THEN reingreso.MovimientoFecha 
                ELSE NULL 
            END as FechaReingreso,
            reingresoAntiguedad.Fecha as FechaReingresoAntiguedad,
            sal.IDMovAfiliatorio,
            mb.Fecha,
            ROW_NUMBER() OVER (PARTITION BY mb.IDEmpleado, mb.Fecha ORDER BY mb.Fecha, baja.MovimientoFecha DESC) as RN
        FROM MovimientosBase mb
        LEFT JOIN (SELECT * FROM MovimientosDetallados WHERE TipoMovimiento = 'ALTA') alta 
            ON mb.IDEmpleado = alta.IDEmpleado
        LEFT JOIN (SELECT * FROM MovimientosDetallados WHERE TipoMovimiento = 'BAJA') baja 
            ON mb.IDEmpleado = baja.IDEmpleado AND baja.MovimientoFecha <= mb.Fecha
        LEFT JOIN (SELECT * FROM MovimientosDetallados WHERE TipoMovimiento = 'REINGRESO') reingreso 
            ON mb.IDEmpleado = reingreso.IDEmpleado AND reingreso.MovimientoFecha <= mb.Fecha AND reingreso.MovimientoFecha >= baja.MovimientoFecha
        OUTER APPLY (
            SELECT TOP 1 * FROM MovimientosReingresoAntiguedad
            WHERE IDEmpleado = mb.IDEmpleado AND Fecha <= mb.Fecha
            ORDER BY Fecha DESC
            ) reingresoAntiguedad 
        LEFT JOIN (SELECT * FROM MovimientosSalario WHERE RN = 1) sal 
            ON mb.IDEmpleado = sal.IDEmpleado
    )

    INSERT INTO #tempMovAfilNew
    SELECT 
        IDEmpleado,
        FechaAlta,
        FechaBaja,
        FechaReingreso,
        FechaReingresoAntiguedad,
        IDMovAfiliatorio,
        Fecha
    FROM FinalResults
    WHERE RN = 1;  

	select 
     m.*
    ,Vigente = CASE WHEN ( (M.FechaAlta<=m.Fecha AND (M.FechaBaja>=m.Fecha OR M.FechaBaja IS NULL)) OR (M.FechaReingreso<=m.Fecha)) THEN cast(1 AS BIT) ELSE cast(0 AS BIT) END    
    ,Mov.IDRegPatronal                       
	FROM #tempMovAfilNew M
	OUTER APPLY (
        SELECT TOP 1 IDRegPatronal
        FROM [IMSS].[tblMovAfiliatorios] 
        WHERE IDEmpleado = M.IDEmpleado
        AND Fecha <= M.Fecha
        AND IDRegPatronal = @IDRegPatronal
        ORDER BY Fecha DESC
    ) Mov
GO

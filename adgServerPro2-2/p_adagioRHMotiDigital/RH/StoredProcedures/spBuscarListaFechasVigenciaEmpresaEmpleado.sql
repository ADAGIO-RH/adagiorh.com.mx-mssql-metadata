USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar una lista de fecha de colaborador indicando que día estuvo vigente o no
** Autor			: Yesenia Leonel
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-05-15
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
CREATE proc [RH].[spBuscarListaFechasVigenciaEmpresaEmpleado](
	--@IDEmpleado int 
	 @dtEmpleados RH.dtEmpleados readonly
	,@Fechas [App].[dtFechas] READONLY 
	,@IDUsuario int 
	,@IDEmpresa int

) as
	declare  
		-- @Fechas [App].[dtFechas]
		 @IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null
	;

	--select top 1 @IDIdioma = dp.Valor
 --   from Seguridad.tblUsuarios u
	--   Inner join App.tblPreferencias p
	--	  on u.IDPreferencia = p.IDPreferencia
	--   Inner join App.tblDetallePreferencias dp
	--	  on dp.IDPreferencia = p.IDPreferencia
	--   Inner join App.tblCatTiposPreferencias tp
	--	  on tp.IDTipoPreferencia = dp.IDTipoPreferencia
	--   where u.IDUsuario = @IDUsuario
	--	  and tp.TipoPreferencia = 'Idioma'

 --   select @IdiomaSQL = [SQL]
 --   from app.tblIdiomas
 --   where IDIdioma = @IDIdioma

 --   if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
 --   begin
	--   set @IdiomaSQL = 'Spanish' ;
 --   end
  
 --   SET LANGUAGE @IdiomaSQL;

	--insert into @Fechas(Fecha)
	--exec [App].[spListaFechas] @FechaIni = @FechaInicio, @FechaFin = @FechaFin

	if object_id('tempdb..#tempMovAfilNew') is not null drop table #tempMovAfilNew;
    
    -- First create the temp table structure
    CREATE TABLE #tempMovAfilNew (
        IDEmpleado int,
        FechaAlta datetime,
        FechaBaja datetime,
        FechaReingreso datetime,
        IDMovAfiliatorio int,
        Fecha datetime
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
        LEFT JOIN (SELECT * FROM MovimientosSalario WHERE RN = 1) sal 
            ON mb.IDEmpleado = sal.IDEmpleado
    )

    INSERT INTO #tempMovAfilNew
    SELECT 
        IDEmpleado,
        FechaAlta,
        FechaBaja,
        FechaReingreso,
        IDMovAfiliatorio,
        Fecha
    FROM FinalResults
    WHERE RN = 1;  

	select m.IDEmpleado, Fecha,Vigente = case when ( (M.FechaAlta<=Fecha and (M.FechaBaja>=Fecha or M.FechaBaja is null)) or (M.FechaReingreso<=Fecha)) then cast(1 as bit) else cast(0 as bit) end                           
	from #tempMovAfilNew M
	inner join (select ee.IDEmpleado, ee.FechaIni as EmpresaInicio, ee.FechaFin as EmpresaFin 
				from rh.tblEmpresaEmpleado ee 
				where ee.IDEmpresa = @IDEmpresa --and ee.FechaIni <= @FechaFin and ee.FechaFin >= @FechaFin
				) Empresa on Empresa.IDEmpleado = M.IDEmpleado
	where M.Fecha between Empresa.EmpresaInicio and Empresa.EmpresaFin
	--,@Fechas Fechas
GO

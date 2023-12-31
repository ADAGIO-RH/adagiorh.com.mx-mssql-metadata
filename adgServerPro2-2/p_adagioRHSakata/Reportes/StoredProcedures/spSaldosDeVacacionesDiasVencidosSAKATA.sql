USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spSaldosDeVacacionesDiasVencidosSAKATA](
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
) as
	-- Parámetros
	--declare 
	--	@dtFiltros Nomina.dtFiltrosRH		
	--	,@IDUsuario int = 1
	--;

	--insert @dtFiltros
	--values
	--	('ClaveEmpleadoInicial','03001')
	--	,('ClaveEmpleadoFinal','03001')
	--	,('FechaIni','2021-03-19')
	--	,('FechaFin','2021-03-19')

	declare 
		 @empleados RH.dtEmpleados
		,@FechaIni date --= '2010-01-20'
		,@FechaFin date	--= '2021-01-20'
		,@EmpleadoIni Varchar(20)  
		,@EmpleadoFin Varchar(20) 
		,@IDTipoNomina int  
		
		,@IDIdioma Varchar(5)      
		,@IdiomaSQL varchar(100) = null    
	;

	SET DATEFIRST 7;      
      
	select top 1 
		@IDIdioma = dp.Valor      
	from Seguridad.tblUsuarios u with (nolock)     
		Inner join App.tblPreferencias p with (nolock)      
			on u.IDPreferencia = p.IDPreferencia      
		Inner join App.tblDetallePreferencias dp with (nolock)      
			on dp.IDPreferencia = p.IDPreferencia      
		Inner join App.tblCatTiposPreferencias tp with (nolock)      
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia      
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'      
      
	select @IdiomaSQL = [SQL]      
	from app.tblIdiomas with (nolock)      
	where IDIdioma = @IDIdioma      
      
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)      
	begin      
		set @IdiomaSQL = 'Spanish' ;      
	end      
        
	SET LANGUAGE @IdiomaSQL;  

	SET @FechaIni		= cast((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')) as date)    
	SET @FechaFin		= cast((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')) as date)  
	SET @EmpleadoIni	= ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    
	SET @EmpleadoFin	= ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')   
	SET @IDTipoNomina	= ISNULL((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')),0)    

	select 
		@FechaIni = isnull(@FechaIni,'1900-01-01')
		,@FechaFin = isnull(@FechaFin,getdate())

	if object_id('tempdb..#tempVacacionesTomadas') is not null drop table #tempVacacionesTomadas;  
	if object_id('tempdb..#tempCTE') is not null drop table #tempCTE;  

	insert @empleados
	exec RH.spBuscarEmpleados @EmpleadoIni=@EmpleadoIni,@EmpleadoFin=@EmpleadoFin,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario


    if object_id('tempdb..#tempTableCursor') is not null    
		drop table #tempTableCursor
     if object_id('tempdb..#tempTableID') is not null    
		drop table #tempTableID   

    CREATE TABLE #tempTableCursor(
    IDEmpleado int,
    Anio int,
    FechaIni date,
    FechaFin date,
    Dias int,
    DiasTomados int,
    DiasVencidos int,
    DiasDisponibles decimal (18,2)
    )

   

    Declare @IdEmpleadoCiclo int

    --exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado=639,@Proporcional=1,@IDUsuario=1


        DECLARE emcursor CURSOR FOR  

        SELECT IDEmpleado
        FROM @empleados

        OPEN emcursor;  
        FETCH NEXT FROM emcursor INTO @IdEmpleadoCiclo
        WHILE @@FETCH_STATUS = 0  
        BEGIN  
        --SELECT @IdEmpleadoCiclo
        insert into #tempTableCursor
            
            
            exec [Asistencia].[spBuscarSaldosVacacionesPorAniosReporte] @IDEmpleado=@IdEmpleadoCiclo,@Proporcional=1,@IDUsuario=1
        
        --insert into #tempTableID VALUES (@IdEmpleadoCiclo)
        
        FETCH NEXT FROM emcursor INTO @IdEmpleadoCiclo
        
        END;  
        CLOSE emcursor;  
        DEALLOCATE emcursor;  

    SELECT M.ClaveEmpleado,
	M.NOMBRECOMPLETO,
	M.DEPARTAMENTO,
	M.SUCURSAL,
	M.PUESTO,
	M.DIVISION,
	CONVERT(varchar,M.FechaAntiguedad,23) AS [FECHA ANTIGUEDAD],
    D.Anio AS [ANIO_],
    CONVERT(varchar,D.FechaIni,23) AS [FECHA INICIO],
    CONVERT(varchar,D.FechaFin,23) AS [FECHA FIN],
    Dias,
    DiasTomados,
    DiasVencidos AS [DIAS VENCIDOS],
    DiasDisponibles AS [DIAS DISPONIBLES]
    FROM #tempTableCursor D
    INNER JOIN @empleados M ON D.IDEmpleado=M.IDEmpleado

    

GO

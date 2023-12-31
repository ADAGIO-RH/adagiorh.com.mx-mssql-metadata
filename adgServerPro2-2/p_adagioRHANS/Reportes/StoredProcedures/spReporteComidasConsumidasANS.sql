USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spReporteComidasConsumidasANS](    
    @dtFiltros [Nomina].[dtFiltrosRH]  readonly    
    ,@IDUsuario int    
) as    
    
    SET NOCOUNT ON;    
    IF 1=0 BEGIN    
        SET FMTONLY OFF    
    END    
    
    --declare     
    -- @FechaIni date =  '2019-01-01'    
    -- ,@FechaFin date = '2019-01-02'    
    -- ,@IDUsuario int = 1    
    --;    
  
    declare     
        @IDIdioma Varchar(5)      
        ,@IdiomaSQL varchar(100) = null      
        ,@Fechas [App].[dtFechasFull]       
        ,@dtEmpleados RH.dtEmpleados    
        ,@IDCliente int    
        ,@IDTipoNomina int    
        ,@FechaIni Date    
        ,@FechaFin Date    
        ,@HoraIni time    
        ,@EmpleadoIni Varchar(20)  
        ,@EmpleadoFin Varchar(20)  
        ,@IDTurno int    
    ;    
    
     SET @IDTipoNomina = isnull((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')),0)    
     SET @FechaIni = cast((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')) as date)    
     SET @FechaFin = cast((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')) as date)   
     SET @HoraIni = cast((Select top 1 cast(item as time) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'HoraIni'),',')) as time)   
     SET @IDTurno = (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDTurno'),','))    
   
     SET @EmpleadoIni = ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    
     SET @EmpleadoFin = ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')     
  
  
     if object_id('tempdb..#tempHorarios') is not null drop table #tempHorarios;        
     if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias;    
	 if object_id('tempdb..#duplicados') is not null drop table #duplicados;   
	 if object_id('tempdb..#sinDuplicados') is not null drop table #sinDuplicados;   
    
     SET DATEFIRST 7;      
      
    select top 1 @IDIdioma = dp.Valor      
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
    
    insert @Fechas      
    exec app.spListaFechas @FechaIni = @FechaIni, @FechaFin = @FechaFin      
    
    --select *    
    --from @Fechas    
    
    insert @dtEmpleados      
    exec [RH].[spBuscarEmpleados]       
        @FechaIni = @FechaIni               
        ,@FechaFin = @FechaFin        
        ,@IDTipoNomina = @IDTipoNomina             
        ,@IDUsuario = @IDUsuario                    
        ,@dtFiltros = @dtFiltros     
        ,@EmpleadoIni = @EmpleadoIni  
        ,@EmpleadoFin = @EmpleadoFin  
   
    select 
        E.ClaveEmpleado as CLAVE
        ,E.NOMBRECOMPLETO as NOMBRE
        ,E.Departamento as DEPARTAMENTO
        ,FORMAT(CAST(CC.Fecha as DATE),'dd/MM/yyyy') as FECHA
        ,FORMAT(CAST(CC.Fecha as DATETIME),'HH:mm:ss') as HORA
    into #tempComidas
    from Comedor.tblComidasConsumidas CC
        inner join @dtEmpleados E
            on CC.IDEmpleado = E.IDEmpleado
    where CAST(cc.Fecha as date)between @FechaIni and @FechaFin
        --and CAST(cc.Fecha as time) >= @HoraIni
        order by cast(CC.Fecha as date) asc, E.ClaveEmpleado asc



	select 
		M.CLAVE,
		M.NOMBRE,
		M.DEPARTAMENTO,
		M.FECHA,
		M.HORA,
		CONCAT(M.CLAVE, M.FECHA, M.HORA ) as duplicados
	into #duplicados
	from #tempComidas M




	select 
		M.CLAVE,
		M.NOMBRE,
		M.DEPARTAMENTO,
		M.FECHA,
		M.HORA,
		CONCAT(M.CLAVE, M.FECHA, M.HORA ) as duplicados,
		ROW_NUMBER() OVER (PARTITION BY M.duplicados ORDER BY M.FECHA DESC ) AS ORDEN
	into #sinDuplicados
	from #duplicados M


	delete from #sinDuplicados where orden <> 1


    select 
        CLAVE
        ,NOMBRE
        ,DEPARTAMENTO
        ,FECHA
        ,HORA
    from #sinDuplicados
    union all
    Select '','TOTAL DE COMIDAS CONSUMIDAS:', cast(count(*) as varchar(20)),'',''
    FROM #sinDuplicados
Contraer

GO

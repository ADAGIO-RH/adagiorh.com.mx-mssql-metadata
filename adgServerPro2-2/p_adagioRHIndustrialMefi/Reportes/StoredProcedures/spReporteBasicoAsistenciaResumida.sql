USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
DDF = Descanso por día festivo
*/
CREATE proc [Reportes].[spReporteBasicoAsistenciaResumida] (
	@dtFiltros Nomina.dtFiltrosRH readonly
	,@IDUsuario int
)as
	declare 
		 @FechaIni date --= '2019-01-01'
		,@FechaFin date --= '2019-01-10'
		,@EmpleadoIni varchar(20)
		,@EmpleadoFin varchar(20)
		,@IDIdioma Varchar(5)  
		,@IdiomaSQL varchar(100) = null   
		,@DinamicColumns nvarchar(max)
		,@DinamicColumnsTemp nvarchar(max)
		,@query  AS NVARCHAR(MAX)
		,@i int
		,@total int	 
		,@FFTEMP DATE
		,@dtFechas App.dtFechas
		,@dtEmpleados RH.dtEmpleados
		,@IDTipoNomina int
		,@IDTurno int
	;
		
	SET DATEFIRST 7;  
  
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')
  
	select @IdiomaSQL = [SQL]  
	from app.tblIdiomas with (nolock)  
	where IDIdioma = @IDIdioma  
  
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)  
	begin  
		set @IdiomaSQL = 'Spanish' ;  
	end  
    
	SET LANGUAGE @IdiomaSQL; 

	--SET @IDTipoNomina = isnull((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')),0)
	SET @FechaIni = (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),','))
	SET @FechaFin = (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),','))
	SET @IDTurno = (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDTurno'),','))
	SET @EmpleadoIni = ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    
	SET @EmpleadoFin = ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')     
  
	if OBJECT_ID('tempdb..#tempFechas') is not null drop table #tempFechas;
	if OBJECT_ID('tempdb..#tempEmpleados') is not null drop table #tempEmpleados;
	if OBJECT_ID('tempdb..#Columnas') is not null drop table #Columnas;
	if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;    
	if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias;    

	create table #tempFechas (
		IDEmpleado int
		,Fecha date
		,Vigente bit
	);
	CREATE TABLE #Columnas (id int identity(1,1) primary key,Col nvarchar(max))

	insert @dtFechas
	exec [App].[spListaFechas] @FechaIni=@FechaIni, @FechaFin=@FechaFin

	insert @dtEmpleados
	exec RH.spBuscarEmpleados 
		 @FechaIni		= @FechaIni
		,@FechaFin		= @FechaFin
		,@EmpleadoIni	= @EmpleadoIni
		,@EmpleadoFin	= @EmpleadoFin
		,@dtFiltros		= @dtFiltros
		,@IDUsuario		= @IDUsuario
 
	insert #tempFechas
	exec [RH].[spBuscarListaFechasVigenciaEmpleado] @dtEmpleados=@dtEmpleados,@Fechas=@dtFechas,@IDUsuario=@IDUsuario

	select c.IDEmpleado,c.FechaOrigen as Fecha,count(c.IDChecada) as Checadas
	INTO #tempChecadas
	from Asistencia.tblChecadas c with (nolock)
		join #tempFechas tempEmp on c.IDEmpleado = tempEmp.IDEmpleado and c.FechaOrigen = tempEmp.Fecha and tempEmp.Vigente = 1
	group by c.IDEmpleado,c.FechaOrigen

	select ie.IDEmpleado,ie.Fecha,count(ie.IDEmpleado) as TotalIncidenciasAusentismos,max(ie.IDIncidencia) as IncidenciaAusentismo
	into #tempAusentismosIncidencias
	from Asistencia.tblIncidenciaEmpleado ie with (nolock)
		join Asistencia.tblCatIncidencias i on ie.IDIncidencia = i.IDIncidencia and isnull(i.EsAusentismo,0) = 1 or i.IDIncidencia = 'F'
		join #tempFechas tempEmp on ie.IDEmpleado = tempEmp.IDEmpleado and ie.Fecha = tempEmp.Fecha and tempEmp.Vigente = 1
	group by ie.IDEmpleado,ie.Fecha

	--select * from #tempChecadas
	--select * from #tempAusentismosIncidencias order by IDEmpleado, Fecha

	select f.IDEmpleado
		,f.Fecha
		,f.Vigente
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,e.Departamento
		,e.Sucursal
		,e.Puesto
		,e.Division
		--,isnull(tc.Checadas,0) as Checadas
		--,isnull(tai.IncidenciaAusentismo,'') as IncidenciaAusentismo
		--,isnull(tai.TotalIncidenciasAusentismos,0) as TotalIncidenciasAusentismos
	INTO #tempEmpleados
	from @dtEmpleados e
		join #tempFechas f on e.IDEmpleado = f.IDEmpleado
		--left join #tempChecadas tc on e.IDEmpleado = tc.IDEmpleado and f.Fecha = tc.Fecha
		--left join #tempAusentismosIncidencias tai on e.IDEmpleado = tai.IDEmpleado and f.Fecha = tai.Fecha

	--select * 
	--from #tempEmpleados
	--order by ClaveEmpleado

	--select * from @dtFechas
	select @DinamicColumnsTemp = STUFF((SELECT ',' + QUOTENAME(Fecha) 
                    from @dtFechas
                    order by Fecha
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,1,'')

	insert into #Columnas(Col)
	SELECT item + '= case when (select Vigente from #tempFechas where Fecha = SUBSTRING('''+item+''',2,LEN('''+item+''')-2) and IDEmpleado = p.IDEmpleado) = 0 then ''B'' '+
						 'when (select Checadas from #tempChecadas where Fecha = SUBSTRING('''+item+''',2,LEN('''+item+''')-2) and IDEmpleado = p.IDEmpleado) > 1 then ''A'' '+
						 'when (select TotalIncidenciasAusentismos from #tempAusentismosIncidencias where Fecha = SUBSTRING('''+item+''',2,LEN('''+item+''')-2) and IDEmpleado = p.IDEmpleado) > 0 then (select IncidenciaAusentismo from #tempAusentismosIncidencias where Fecha = SUBSTRING('''+item+''',2,LEN('''+item+''')-2) and IDEmpleado = p.IDEmpleado) '+
						 'when (select IDDiaFestivo from  Asistencia.TblCatDiasFestivos where Fecha = SUBSTRING('''+item+''',2,LEN('''+item+''')-2) and Autorizado = 1) > 0 then ''DDF'' '+
					  'ELSE ''NC'' END,' FROM App.Split(@DinamicColumnsTemp,',');

					 -- select * from #Columnas

	set @DinamicColumns = '';
	select @i=1;
	set @total = (select COUNT(*) from #Columnas)
	while @i <= @total
	begin
		select @DinamicColumns=@DinamicColumns+ col from #Columnas where id = @i;
		set @i=@i+1;
	end;

	set @DinamicColumns = (select substring(@DinamicColumns,1,LEN(@DinamicColumns)-1))


	set @query = 'SELECT distinct ClaveEmpleado as [Clave Empleado]
					,NOMBRECOMPLETO as [Nombre Completo]
					,Departamento
					,Sucursal
					,Puesto
					,Division
					,' + @DinamicColumns + ' from 
             (
                select *
                FROM #tempEmpleados  
            ) x
            pivot 
            (
               COUNT(FECHA)
                for FECHA in (' + @DinamicColumnsTemp + ')
            ) p --join #tempEmpleados e on e.IDEmpleado = p.IDEmpleado
            order by p.ClaveEmpleado
            '
	print @query
	execute(@query)
GO

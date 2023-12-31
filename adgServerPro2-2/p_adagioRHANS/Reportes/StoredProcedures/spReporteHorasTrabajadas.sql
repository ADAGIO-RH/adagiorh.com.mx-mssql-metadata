USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


	

		  
CREATE proc [Reportes].[spReporteHorasTrabajadas] (
	@dtFiltros [Nomina].[dtFiltrosRH]  readonly
	,@IDUsuario int
) as

	SET NOCOUNT ON;
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	declare 
		@IDIdioma Varchar(5)  
		,@IdiomaSQL varchar(100) = null  
		,@Fechas [App].[dtFechasFull]   
		,@dtEmpleados RH.dtEmpleados
		,@IDCliente int
		,@IDTipoNomina int
		,@FechaIni Date
		,@FechaFin Date
		,@IDTurno int
		,@EmpleadoIni varchar(20)
		,@EmpleadoFin varchar(20)
        ,@DiasPeriodo int 

    


	SET @IDTipoNomina = isnull((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')),0)
	SET @FechaIni = (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),','))
	SET @FechaFin = (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),','))
	SET @IDTurno = (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDTurno'),','))
	SET @EmpleadoIni = ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    
	SET @EmpleadoFin = ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')     
  
    set @DiasPeriodo= DATEDIFF(day, @FechaIni,@FechaFin) + 1;


    if object_id('tempdb..#tempHorasTrabajadas') is not null drop table #tempHorasTrabajadas;    

	if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;    
	if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias;    

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

	insert @dtEmpleados  
	exec [RH].[spBuscarEmpleados]   
		 @FechaIni		= @FechaIni           
		,@FechaFin		= @FechaFin    
		,@EmpleadoIni	= @EmpleadoIni
		,@EmpleadoFin	= @EmpleadoFin
		,@IDTipoNomina	= @IDTipoNomina         
		,@IDUsuario		= @IDUsuario                
		,@dtFiltros		= @dtFiltros 




	select 
    c.IDEmpleado
    ,FECHA =  App.fnAddString(2,cast(Fecha.Dia as varchar(2)),'0',1)
					+' - '+ UPPER(SUBSTRING(Fecha.NombreMes,1,3))
					+' '+ UPPER(Fecha.NombreDia)
    ,isnull((select top 1 cast(cast(Fecha as time) as varchar(5))
					from Asistencia.tblChecadas
					where IDTipoChecada in ('ET') and FechaOrigen = fecha.Fecha and IDEmpleado = tempEmp.IDEmpleado
					order by Fecha desc),'2020-01-01') as Entrada
    ,isnull((select top 1 cast(cast(Fecha as time) as varchar(5))
					from Asistencia.tblChecadas
					where IDTipoChecada in ('ST') and FechaOrigen = fecha.Fecha and IDEmpleado = tempEmp.IDEmpleado
					order by Fecha desc),'2020-01-01') as Salida
    , ROW_NUMBER() OVER (PARTITION by c.IDEmpleado,CONVERT(date,c.fecha) order by CONVERT(date,c.fecha)) as indice
	INTO #tempChecadas
	from Asistencia.tblChecadas c with (nolock)
		join @Fechas fecha on c.FechaOrigen = fecha.Fecha 
		join @dtEmpleados tempEmp on c.IDEmpleado = tempEmp.IDEmpleado 
	
   delete from #tempChecadas
   where indice <> 1

   delete from #tempChecadas
   where Entrada ='2020-'

   delete from #tempChecadas
   where Salida ='2020-'

   
    
	select ie.*
	into #tempAusentismosIncidencias
	from Asistencia.tblIncidenciaEmpleado ie with (nolock)
		join @Fechas fecha on ie.Fecha = fecha.Fecha 
		join @dtEmpleados tempEmp on ie.IDEmpleado = tempEmp.IDEmpleado 

	--select * from @Fechas
	select
		 empFecha.ClaveEmpleado as [CLAVE EMPLEADO]
		,empFecha.NOMBRECOMPLETO as NOMBRE
		,empFecha.IDEmpleado
        ,empFecha.ClasificacionCorporativa
        ,empFecha.Departamento
        ,empFecha.Puesto as PUESTO        
		--,empFecha.Fecha
		,FECHA = App.fnAddString(2,cast(empFecha.Dia as varchar(2)),'0',1)
					+' - '+ UPPER(SUBSTRING(empFecha.NombreMes,1,3))
					+' '+ UPPER(empFecha.NombreDia)
		,isnull(i.IDIncidencia,'E') ENTRADA
		,isnull(i.IDIncidencia,'S') SALIDA
		--,i.IDIncidencia
		,i.Comentario as COMENTARIO
		--,NombrePuesto = empFecha.NOMBRECOMPLETO +' <br/> '+coalesce(empFecha.Puesto,'')
		--,Titulo = 'LISTA DE ASISTENCIA DEL '
		--			+ App.fnAddString(2,cast(DATEPART(DAY,@FechaIni) as varchar(2)),'0',1)
		--			+'/'+UPPER(DATENAME(month,@FechaIni))
		--			+'/'+CAST(DATEPART(YEAR,@FechaIni) as varchar)
		--			+' AL '
		--			+ App.fnAddString(2,cast(DATEPART(DAY,@FechaFin) as varchar(2)),'0',1)
		--			+'/'+UPPER(DATENAME(month,@FechaFin))
		--			+'/'+CAST(DATEPART(YEAR,@FechaFin) as varchar) --{FECHA INICIAL CON FORMATO DD / Mes con Letra Completo / AÑO (4 dígitos)} AL FECHA FINAL
        ,ROW_NUMBER() OVER (PARTITION by empFecha.IDEmpleado,CONVERT(date,empFecha.fecha) order by CONVERT(date,empFecha.fecha)) as indice 
        into #tempHorasTrabajadas
	from (select *
			from @Fechas
				,@dtEmpleados) as empFecha
		left join #tempAusentismosIncidencias i on i.IDEmpleado = empFecha.IDEmpleado and i.Fecha = empFecha.Fecha
	order by empFecha.IDEmpleado,empFecha.Fecha
    
-- delete from #tempHorasTrabajadas
-- where indice <> 1

select * , a.[Tiempo Extra] + a.[Horas regulares]  as [Total] from 
(
    select  
        t.[CLAVE EMPLEADO]
		,t.NOMBRE		
        ,t.ClasificacionCorporativa
        ,t.Departamento
        ,t.Puesto as PUESTO
        ,@DiasPeriodo as [Dias Periodo]
        ,(select count(*) from #tempHorasTrabajadas c where c.[CLAVE EMPLEADO]=t.[CLAVE EMPLEADO] and c.ENTRADA='D' AND c.SALIDA='D'  ) as Descansos
        ,(select count(*) from #tempHorasTrabajadas c where c.[CLAVE EMPLEADO]=t.[CLAVE EMPLEADO] and c.ENTRADA='DL' AND c.SALIDA='DL'  ) as DescansosLaborados
        ,(select count(*) from #tempHorasTrabajadas c where c.[CLAVE EMPLEADO]=t.[CLAVE EMPLEADO] and c.ENTRADA='DF' AND c.SALIDA='DF'  ) as FestivosLaborados
        ,(select count(*) from #tempHorasTrabajadas c where c.[CLAVE EMPLEADO]=t.[CLAVE EMPLEADO] and c.ENTRADA in ('A','C','P','S','F') AND c.SALIDA in ('A','C','P','S','F') ) as Faltas        
        ,(select count(*) from #tempHorasTrabajadas c where c.[CLAVE EMPLEADO]=t.[CLAVE EMPLEADO] and c.ENTRADA='I' AND c.SALIDA='I' ) as Incapacidades
        ,(select count(Distinct FECHA) from #tempHorasTrabajadas c where c.[CLAVE EMPLEADO]=t.[CLAVE EMPLEADO] and c.ENTRADA  in  ('B','T','CM','EX','R','E','DL','DF') AND c.SALIDA  in ('B','T','CM','EX','R','S','DL','DF') ) as [Dias Laborados]                
        ,(select isnull(sum((DATEDIFF(second, tc.ENTRADA, tc.SALIDA) / 3600.0)),0) from #tempChecadas tc where tc.[IDEmpleado]=t.[IDEmpleado]  ) as [Horas regulares]                
        ,(select isnull(sum(f.TiempoExtraDecimal),0) from Asistencia.tblIncidenciaEmpleado as f where f.IDIncidencia='EX' and  f.Fecha BETWEEN  @FechaIni and @FechaFin and f.Autorizado=1 and f.IDEmpleado=t.IDEmpleado) as [Tiempo Extra]        
        ,0 as [Desc. Tiempo]
        ,(select count(*) from #tempHorasTrabajadas c where c.[CLAVE EMPLEADO]=t.[CLAVE EMPLEADO] and c.ENTRADA='V' AND c.SALIDA='V' ) as Vacaciones


    from #tempHorasTrabajadas t     
     GROUP by t.IDEmpleado,t.[CLAVE EMPLEADO],t.NOMBRE,t.ClasificacionCorporativa,t.Departamento,t.PUESTO
    
) as a
    order by a.[NOMBRE]

    --CM, DL DF EX PD
   
    
GO

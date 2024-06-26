USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 Reportes.spReporteBasicoAsistenciaRangoDeFechaImpreso 
		@FechaIni	= '2019-08-01'
		,@FechaFin	= '2019-08-15'
		,@Clientes	= '1' 
		,@IDUsuario = 1 

*/
		  
CREATE proc [Reportes].[spReporteListasDeAsistenciaImpresoHGPBYDEP] (
	@FechaIni date 	--= '2021-07-08'
	,@FechaFin date	--= '2021-07-20'
	,@Clientes varchar(max)			--= '1'    
	,@IDTipoNomina varchar(max)		= ''    
	,@Divisiones varchar(max) 		= ''
	,@CentrosCostos varchar(max)	= ''
	,@Departamentos varchar(max)	= ''
	,@Areas varchar(max) 			= ''
	,@Sucursales varchar(max)		= ''
	,@Prestaciones varchar(max)		= ''
	,@IDUsuario int --= 1
) as

	SET NOCOUNT ON;
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	--declare 
	--	@FechaIni date =  '2019-08-01'
	--	,@FechaFin date = '2019-08-15'
	--	,@IDUsuario int = 1
	--;

	declare 
		 @IDIdioma Varchar(5)  
		,@IdiomaSQL varchar(100) = null  
		,@Fechas [App].[dtFechas]   
		,@dtEmpleados RH.dtEmpleados
		,@dtFiltros [Nomina].[dtFiltrosRH]  
		,@IDTipoNominaInt int 
		 ,@Titulo Varchar(max)     
	;

	SET @IDTipoNominaInt = isnull((Select top 1 cast(item as int) from App.Split(@IDTipoNomina,',')),0)

	insert @dtFiltros(Catalogo,Value)    
	values
		 ('Clientes',@Clientes)    
		,('Divisiones',@Divisiones)    
		,('CentrosCostos',@CentrosCostos)    
		,('Departamentos',@Departamentos)    
		,('Areas',@Areas)    
		,('Sucursales',@Sucursales)    
		,('Prestaciones',@Prestaciones)    

	if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;   
	if object_id('tempdb..#tempHorarios') is not null drop table #tempHorarios;  
	if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias;    

	SET DATEFIRST 7;  
  
	select top 1 @IDIdioma = dp.Valor  
	from Seguridad.tblUsuarios u  
		Inner join App.tblPreferencias p  
			on u.IDPreferencia = p.IDPreferencia  
		Inner join App.tblDetallePreferencias dp  
			on dp.IDPreferencia = p.IDPreferencia  
		Inner join App.tblCatTiposPreferencias tp  
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia  
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'  
  
	select @IdiomaSQL = [SQL]  
	from app.tblIdiomas  
	where IDIdioma = @IDIdioma  
  
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)  
	begin  
		set @IdiomaSQL = 'Spanish' ;  
	end  
    
	SET LANGUAGE @IdiomaSQL; 

	    
	SET @Titulo =  UPPER( 'LISTA DE ASISTENCIA DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))

	declare @tempOrdenIndencias as table (IDIncidenciaOrden varchar(20), Orden int)

	insert @tempOrdenIndencias
	values ('DL', 0)
		  ,('PD', 1)
		  ,('EX', 2)

	insert @Fechas  
	exec app.spListaFechas @FechaIni = @FechaIni, @FechaFin = @FechaFin  

	--select *
	--from @Fechas

	insert @dtEmpleados  
	exec [RH].[spBuscarEmpleados]   
		@FechaIni = @FechaIni           
		,@FechaFin = @FechaFin    
		,@IDTipoNomina = @IDTipoNominaInt         
		,@IDUsuario = @IDUsuario                
		,@dtFiltros = @dtFiltros 


	if object_id('tempdb..#tempVigenciaEmpleados') is not null drop table #tempVigenciaEmpleados  
	if object_id('tempdb..#tempEmpleadosTrabajables') is not null drop table #tempEmpleadosTrabajables  
  
	create Table #tempVigenciaEmpleados (  
		IDEmpleado int null,  
		Fecha Date null,  
		Vigente bit null  
	)  
  
	insert into #tempVigenciaEmpleados  
	Exec [RH].[spBuscarListaFechasVigenciaEmpleado]  
		@dtEmpleados	= @dtEmpleados  
		,@Fechas		= @Fechas 
		,@IDUsuario		= 1  

	
	select IDEmpleado, count(*) QTY
	into #tempEmpleadosTrabajables
	from #tempVigenciaEmpleados
	where Vigente = 1
	group by IDEmpleado

	delete #tempVigenciaEmpleados
	where IDEmpleado not in  (select IDEmpleado from #tempEmpleadosTrabajables)


	--select c.*
	--INTO #tempChecadas
	--from Asistencia.tblChecadas c with (nolock)
	--	join @Fechas fecha on c.FechaOrigen = fecha.Fecha 
	--	join @dtEmpleados tempEmp on c.IDEmpleado = tempEmp.IDEmpleado 

	select c.*
	INTO #tempChecadas
	from Asistencia.tblChecadas c with (nolock)
		join #tempVigenciaEmpleados fecha on c.FechaOrigen = fecha.Fecha 
		and c.IDEmpleado = fecha.IDEmpleado 
	where fecha.Vigente = 1
	
	--select ie.*
	--into #tempAusentismosIncidencias
	--from Asistencia.tblIncidenciaEmpleado ie with (nolock)
	--	join @Fechas fecha on ie.Fecha = fecha.Fecha 
	--	join @dtEmpleados tempEmp on ie.IDEmpleado = tempEmp.IDEmpleado 

	select ie.*
	into #tempAusentismosIncidencias
	from Asistencia.tblIncidenciaEmpleado ie with (nolock)
		join #tempVigenciaEmpleados fecha on ie.Fecha = fecha.Fecha 
		and ie.IDEmpleado = fecha.IDEmpleado
	where fecha.Vigente = 1

	--select * from @Fechas
	select 
		 empFecha.IDEmpleado
		,emp.ClaveEmpleado
		,emp.NOMBRECOMPLETO as Nombre
		,emp.Puesto
		,emp.Departamento
		,emp.IDDepartamento
		,emp.Sucursal
		,emp.Empresa as RazonSocial
		,empFecha.Fecha
        ,emp.IDSucursal
		,Departam.Codigo
		,FechaStr = App.fnAddString(2,cast(empFecha.Dia as varchar(2)),'0',1) 
					 + ' ' + UPPER(SUBSTRING(empFecha.NombreDia,1,3))
		,case when isnull(empFecha.Vigente,0) = 0 THEN 'N/C'  
			when i.IDIncidencia is null then 'ASIST'
			when i.IDIncidencia = 'D' then 'D'
			else i.IDIncidencia end Info
		,case when isnull(empFecha.Vigente,0) = 0 THEN ''
			when i.IDIncidencia is null  OR I.IDIncidencia IN ('EX','PD','R','DL','GH','DF') then 
				isnull((select top 1 cast(cast(Fecha as time) as varchar(5))
					from #tempChecadas 
					where IDTipoChecada in ('ET') and FechaOrigen = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado
					order by Fecha asc),'F/R')
			else '' end Entrada
			--else i.IDIncidencia end Entrada
		,case when isnull(empFecha.Vigente,0) = 0 THEN ''
			when i.IDIncidencia is null OR I.IDIncidencia IN ('EX','PD','R','DL','GH','DF') then 
				isnull((select top 1 cast(cast(Fecha as time) as varchar(5))
					from #tempChecadas 
					where IDTipoChecada in ('ST') and FechaOrigen = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado
					order by Fecha desc),'F/R') 
			else '' end Salida
			--else i.IDIncidencia end Salida

		,case when isnull(empFecha.Vigente,0) = 0 THEN ''
			when i.IDIncidencia is null  OR I.IDIncidencia IN ('EX','PD','R','DL','GH','DF') then 
				isnull((select top 1 Fecha
					from #tempChecadas 
					where IDTipoChecada in ('ET') and FechaOrigen = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado
					order by Fecha asc),getdate())
			else getdate() end FechaHoraEntrada
			--else i.IDIncidencia end Entrada
		,case when isnull(empFecha.Vigente,0) = 0 THEN ''
			when i.IDIncidencia is null OR I.IDIncidencia IN ('EX','PD','R','DL','GH','DF') then 
				isnull((select top 1 Fecha
					from #tempChecadas 
					where IDTipoChecada in ('ST') and FechaOrigen = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado
					order by Fecha desc),getdate()) 
			else getdate() end FechaHoraSalida

		,i.IDIncidencia
		,i.Comentario
		,coalesce(emp.Puesto,'') as NombrePuesto
		,Titulo = @Titulo
		--,ch.Descripcion as Horario
		,( select top 1 ca.Descripcion
			from Rh.tblEmpleados e
			join [Asistencia].[tblHorariosEmpleados] he on e.IDEmpleado = he.IDEmpleado
			join [Asistencia].[tblCatHorarios] ca on he.IDHorario = ca.IDHorario
			where e.IDEmpleado = empFecha.IDEmpleado
			    AND he.Fecha between @FechaIni and @FechaFin) as Horario

	into #tempHorarios	
	from (select ve.IDEmpleado, ve.Vigente,f.*
			from #tempVigenciaEmpleados ve
				inner join @Fechas f
					on ve.Fecha = f.Fecha) as empFecha
		left join #tempAusentismosIncidencias i on i.IDEmpleado = empFecha.IDEmpleado and i.Fecha = empFecha.Fecha
			Inner join @dtEmpleados emp 
				on emp.IDEmpleado = empFecha.IDEmpleado
			INNER JOIN RH.tblCatDepartamentos Departam on emp.IdDepartamento = Departam.IDDepartamento
	order by emp.ClaveEmpleado,empFecha.Fecha, i.IDIncidencia
		

	select s.Codigo [CodigoSucursal],h.*,o.*,
	case 
		when (IDIncidencia is null 
			and Entrada != 'F/R'
			and Salida  != 'F/R') 
		then 
			REPLACE(FORMAT(DATEDIFF(second, FechaHoraEntrada, FechaHoraSalida) / 3600.0, '#.##'), ',', ':')
		when (IDIncidencia = 'EX'
			and Entrada != 'F/R'
			and Salida  != 'F/R')
		then REPLACE(FORMAT(DATEDIFF(second, FechaHoraEntrada, FechaHoraSalida) / 3600.0, '#.##'), ',', ':')
		when (IDIncidencia = 'PD'
			and Entrada != 'F/R'
			and Salida  != 'F/R')
		then REPLACE(FORMAT(DATEDIFF(second, FechaHoraEntrada, FechaHoraSalida) / 3600.0, '#.##'), ',', ':')
		when (IDIncidencia = 'R'
			and Entrada != 'F/R'
			and Salida  != 'F/R')
		then REPLACE(FORMAT(DATEDIFF(second, FechaHoraEntrada, FechaHoraSalida) / 3600.0, '#.##'), ',', ':')

		when (IDIncidencia = 'DL' OR IDIncidencia = 'GH'
			and Entrada != 'F/R'
			and Salida  != 'F/R')
		then REPLACE(FORMAT(DATEDIFF(second, FechaHoraEntrada, FechaHoraSalida) / 3600.0, '#.##'), ',', ':')
		else 'F/R' end Diff
		--,isnull(H.Descripcion,'') as HorarioEmpleado
		from #tempHorarios h
			left join @tempOrdenIndencias o on o.IDIncidenciaOrden = h.IDIncidencia
            inner join RH.tblCatSucursales s on s.IDSucursal =h.IDSucursal				
	order by IDSucursal,Departamento,ClaveEmpleado, Fecha, isnull(o.Orden,1000)
GO

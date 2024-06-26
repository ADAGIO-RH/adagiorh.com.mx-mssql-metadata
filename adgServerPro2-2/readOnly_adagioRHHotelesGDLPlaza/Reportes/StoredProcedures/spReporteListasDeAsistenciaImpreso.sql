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
		  
CREATE proc [Reportes].[spReporteListasDeAsistenciaImpreso] (
	@FechaIni date 
	,@FechaFin date
	,@Clientes varchar(max)			= ''    
	,@IDTipoNomina varchar(max)		= ''    
	,@Divisiones varchar(max) 		= ''
	,@CentrosCostos varchar(max)	= ''
	,@Departamentos varchar(max)	= ''
	,@Areas varchar(max) 			= ''
	,@Sucursales varchar(max)		= ''
	,@Prestaciones varchar(max)		= ''
	,@IDUsuario int
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

	select c.*
	INTO #tempChecadas
	from Asistencia.tblChecadas c with (nolock)
		join @Fechas fecha on c.FechaOrigen = fecha.Fecha 
		join @dtEmpleados tempEmp on c.IDEmpleado = tempEmp.IDEmpleado 
	
	select ie.*
	into #tempAusentismosIncidencias
	from Asistencia.tblIncidenciaEmpleado ie with (nolock)
		join @Fechas fecha on ie.Fecha = fecha.Fecha 
		join @dtEmpleados tempEmp on ie.IDEmpleado = tempEmp.IDEmpleado 

	--select * from @Fechas
	select 
		empFecha.IDEmpleado
		,empFecha.ClaveEmpleado
		,empFecha.NOMBRECOMPLETO as Nombre
		,empFecha.Puesto
		,empFecha.Departamento
		,empFecha.Sucursal
		,empFecha.Empresa as RazonSocial
		,empFecha.Fecha

		,FechaStr = App.fnAddString(2,cast(empFecha.Dia as varchar(2)),'0',1) 
					 + ' ' + UPPER(SUBSTRING(empFecha.NombreDia,1,3))
		,case 
			when i.IDIncidencia is null then 'ASIST'
			when i.IDIncidencia = 'D' then 'DESCA'
			else i.IDIncidencia end Info
		,case 
			when i.IDIncidencia is null then 
				isnull((select top 1 cast(cast(Fecha as time) as varchar(5))
					from #tempChecadas 
					where IDTipoChecada in ('ET') and FechaOrigen = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado
					order by Fecha asc),'F/R')
			else i.IDIncidencia end Entrada
		,case 
			when i.IDIncidencia is null then 
				isnull((select top 1 cast(cast(Fecha as time) as varchar(5))
					from #tempChecadas 
					where IDTipoChecada in ('ST') and FechaOrigen = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado
					order by Fecha desc),'F/R') 
			else i.IDIncidencia end Salida

		,i.IDIncidencia
		,i.Comentario
		,coalesce(empFecha.Puesto,'') as NombrePuesto
		,Titulo = @Titulo
		--,ch.Descripcion as Horario
		,( select top 1 ca.Descripcion
			from Rh.tblEmpleados e
			join [Asistencia].[tblHorariosEmpleados] he on e.IDEmpleado = he.IDEmpleado
			join [Asistencia].[tblCatHorarios] ca on he.IDHorario = ca.IDHorario
			where e.IDEmpleado = empFecha.IDEmpleado
			    AND he.Fecha between @FechaIni and @FechaFin) as Horario

	into #tempHorarios	
	from (select *
			from @Fechas
				,@dtEmpleados) as empFecha
		left join #tempAusentismosIncidencias i on i.IDEmpleado = empFecha.IDEmpleado and i.Fecha = empFecha.Fecha
	order by empFecha.IDEmpleado,empFecha.Fecha
		

	select *,
	case 
		when (IDIncidencia is null 
			and Entrada != 'F/R'
			and Salida  != 'F/R')
		then 
			REPLACE(FORMAT(DATEDIFF(second, Entrada, Salida) / 3600.0, '#.##'), ',', ':')
		else 'F/R' end Diff
		--,isnull(H.Descripcion,'') as HorarioEmpleado
		from #tempHorarios 
	
GO

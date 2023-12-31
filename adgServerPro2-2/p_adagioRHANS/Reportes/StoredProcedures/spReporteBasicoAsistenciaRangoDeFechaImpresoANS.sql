USE [p_adagioRHANS]
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
/*
exec Reportes.spReporteBasicoAsistenciaRangoDeFechaImpresoANS @FechaIni='2021-02-01',@FechaFin='2021-02-07',@Clientes='1',@IDTipoNomina='5',@Divisiones=NULL,@CentrosCostos=NULL,@Departamentos=NULL,@Areas=NULL,@Sucursales='',@Prestaciones=NULL,@IDUsuario=1
*/
		  
CREATE proc [Reportes].[spReporteBasicoAsistenciaRangoDeFechaImpresoANS] (
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
		,@Fechas [App].[dtFechasFull]   
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
	if object_id('tempdb..#tempFestivos') is not null drop table #tempFestivos;    
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

	--select * from #tempChecadas where IDEmpleado = 29
	
	select ie.*
	into #tempAusentismosIncidencias
	from Asistencia.tblIncidenciaEmpleado ie with (nolock)
		join @Fechas fecha on ie.Fecha = fecha.Fecha 
		join @dtEmpleados tempEmp on ie.IDEmpleado = tempEmp.IDEmpleado 
		join Asistencia.tblCatIncidencias I with(nolock)
			on IE.IDIncidencia = I.IDIncidencia
		and IE.Autorizado = 1
	where I.IDIncidencia in (
	'A'
	,'C'
	,'D'
	,'DE'
	,'DF'
	--,'DL'
	,'F'
	,'G'
	,'I'
	,'M'
	,'N'
	,'P'
	,'S'
	,'V')

	select * 
		into #tempFestivos
	from Asistencia.TblCatDiasFestivos with(nolock)
	where  isnull(Autorizado,0) = 1

	--select * from @Fechas

		--select * from #tempAusentismosIncidencias
		--order by IDEmpleado
	select
		 empFecha.ClaveEmpleado
		,empFecha.NOMBRECOMPLETO as Nombre
		,empFecha.Puesto
		,empFecha.Departamento
		,empFecha.RegPatronal
		
		,empFecha.Fecha
		,FechaStr = App.fnAddString(2,cast(empFecha.Dia as varchar(2)),'0',1)
					+' - '+ UPPER(SUBSTRING(empFecha.NombreMes,1,3))
					+' '+ UPPER(empFecha.NombreDia)
		,case 
			when i.IDIncidencia is null  OR I.IDIncidencia in ('D','DL') then 
				isnull((select top 1 cast(cast(Fecha as time) as varchar(5))
					from #tempChecadas 
					where IDTipoChecada in ('ET','SH') and FechaOrigen = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado
					order by Fecha asc),CASE WHEN fest.IDDiaFestivo is null THEN 'NC' else 'FEST.' end)
			else i.IDIncidencia end Entrada
		
		,case 
			when i.IDIncidencia is null OR I.IDIncidencia in ('D','DL') then 
				isnull((select top 1 cast(cast(Fecha as time) as varchar(5))
					from #tempChecadas 
					where IDTipoChecada in ('ST','SH') and FechaOrigen = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado
					order by Fecha desc),CASE WHEN fest.IDDiaFestivo is null THEN 'NC' else 'FEST.' end) 
			else i.IDIncidencia end Salida
		,i.IDIncidencia
		,i.Comentario
		,NombrePuesto = empFecha.NOMBRECOMPLETO +' <br/> '+coalesce(replace(empFecha.Puesto,'&',''),'')
		,Titulo = @Titulo
					--'LISTA DE ASISTENCIA DEL '
					--+ App.fnAddString(2,cast(DATEPART(DAY,@FechaIni) as varchar(2)),'0',1)
					--+'/'+UPPER(DATENAME(month,@FechaIni))
					--+'/'+CAST(DATEPART(YEAR,@FechaIni) as varchar)
					--+' AL '
					--+ App.fnAddString(2,cast(DATEPART(DAY,@FechaFin) as varchar(2)),'0',1)
					--+'/'+UPPER(DATENAME(month,@FechaFin))
					--+'/'+CAST(DATEPART(YEAR,@FechaFin) as varchar) --{FECHA INICIAL CON FORMATO DD / Mes con Letra Completo / AÑO (4 dígitos)} AL FECHA FINAL 
	from (select *
			from @Fechas
				,@dtEmpleados) as empFecha
		left join #tempAusentismosIncidencias i on i.IDEmpleado = empFecha.IDEmpleado and i.Fecha = empFecha.Fecha
		left join #tempFestivos fest on empFecha.Fecha = fest.Fecha
	order by empFecha.IDEmpleado,empFecha.Fecha
GO

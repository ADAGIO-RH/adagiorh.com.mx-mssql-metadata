USE [p_adagioRHNomade]
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
		  
CREATE proc [Reportes].[spReporteBasicoAsistenciaRangoDeFechaImpresoAsistencia] (
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
		,@Fechas [App].[dtFechasfull]   
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

	    
SET @Titulo =  UPPER( 'LISTA DE ASISTENCIA CON ORIGEN DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))



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

	select c.*,l.Lector
	INTO #tempChecadas
	from Asistencia.tblChecadas c with (nolock)
    Inner join Asistencia.tblLectores l on l.IDLector = C.IDLector
		join @Fechas fecha on c.FechaOrigen = fecha.Fecha 
		join @dtEmpleados tempEmp on c.IDEmpleado = tempEmp.IDEmpleado 
	

	select ie.*
	into #tempAusentismosIncidencias
	from Asistencia.tblIncidenciaEmpleado ie with (nolock)
        join Asistencia.tblCatIncidencias ci on ci.IDIncidencia = ie.IDIncidencia
		join @Fechas fecha on ie.Fecha = fecha.Fecha 
		join @dtEmpleados tempEmp on ie.IDEmpleado = tempEmp.IDEmpleado 
        where ci.EsAusentismo = 1

	--select * from @Fechas

	
	select
		 empFecha.ClaveEmpleado
		,empFecha.NOMBRECOMPLETO as Nombre
		,empFecha.Puesto
		,empFecha.Fecha
        ,empFecha.Area
        ,empFecha.Departamento
        ,empFecha.Cliente
        ,empFecha.Sucursal
		,FechaStr = App.fnAddString(2,cast(empFecha.Dia as varchar(2)),'0',1)
					+' - '+ UPPER(SUBSTRING(empFecha.NombreMes,1,3))
					+' '+ UPPER(empFecha.NombreDia)
		,case 
			when i.IDIncidencia is null then 
				isnull((select top 1 cast(cast(Fecha as time) as varchar(5))
					from #tempChecadas 
					where IDTipoChecada in ('ET') and FechaOrigen = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado
					order by Fecha asc),'NC')
			else i.IDIncidencia end Entrada
        ,case 
			when i.IDIncidencia is null then 
				isnull((select top 1 Lector
					from #tempChecadas 
					where IDTipoChecada in ('ET') and FechaOrigen = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado
					order by Fecha asc),'NC')
			else i.IDIncidencia end EntradaLector
		,case 
			when i.IDIncidencia is null then 
				isnull((select top 1 cast(cast(Fecha as time) as varchar(5))
					from #tempChecadas 
					where IDTipoChecada in ('ST') and FechaOrigen = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado
					order by Fecha desc),'NC') 
			else i.IDIncidencia end Salida
        ,case 
			when i.IDIncidencia is null then 
				isnull((select top 1 Lector
					from #tempChecadas 
					where IDTipoChecada in ('ST') and FechaOrigen = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado
					order by Fecha asc),'NC')
			else i.IDIncidencia end SalidaLector
        
		,i.Comentario
		,NombrePuesto = empFecha.NOMBRECOMPLETO +' <br/> '+coalesce(empFecha.Puesto,'')
		,Titulo = @Titulo
	from (select *
			from @Fechas
				,@dtEmpleados) as empFecha
		left join #tempAusentismosIncidencias i on i.IDEmpleado = empFecha.IDEmpleado and i.Fecha = empFecha.Fecha
	order by empFecha.IDEmpleado,empFecha.Fecha
GO

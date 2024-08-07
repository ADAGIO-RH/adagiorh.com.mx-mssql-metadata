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
exec Reportes.[spReporteBasicoNominaTiempoExtraImpresoANS] @Clientes='1',@IDTipoNomina='4',@IDPeriodoInicial = '5',@Divisiones=NULL,@CentrosCostos=NULL,@Departamentos=NULL,@Areas=NULL,@Sucursales='',@Prestaciones=NULL,@IDUsuario=1
*/
		  
CREATE proc [Reportes].[spReporteBasicoNominaTiempoExtraImpresoANS] (
	 @Clientes varchar(max)			= ''    
	,@IDTipoNomina varchar(max)		= ''    
	,@IDPeriodoInicial Varchar(max) = ''   
	,@Divisiones varchar(max) 		= ''
	,@CentrosCostos varchar(max)	= ''
	,@Departamentos varchar(max)	= ''
	,@Areas varchar(max) 			= ''
	,@Sucursales varchar(max)		= ''
	,@Prestaciones varchar(max)		= ''
	,@Puestos varchar(max)			= ''
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
		,@FechaIni date 
		,@FechaFin date
		,@periodo [Nomina].[dtPeriodos]     
		,@CodigoPeriodo varchar(50)
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
		,('Puestos',@Puestos)   
		
	insert into @periodo  
	select *
	--	IDPeriodo  
	--	,IDTipoNomina  
	--	,Ejercicio  
	--	,ClavePeriodo  
	--	,Descripcion  
	--	,FechaInicioPago  
	--	,FechaFinPago  
	--	,FechaInicioIncidencia  
	--	,FechaFinIncidencia  
	--	,Dias  
	--	,AnioInicio  
	--	,AnioFin  
	--	,MesInicio  
	--	,MesFin  
	--	,IDMes  
	--	,BimestreInicio  
	--	,BimestreFin  
	--	,Cerrado  
	--	,General  
	--	,Finiquito  
	--	,isnull(Especial,0)  
	from Nomina.tblCatPeriodos  
	where IDPeriodo = @IDPeriodoInicial 

	SELECT @FechaIni = FechaInicioPago
		,@FechaFin = FechaFinPago
		,@CodigoPeriodo = ClavePeriodo
	from @periodo



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

	    
SET @Titulo =  UPPER( 'REPORTE DE TIEMPOS EXTRAS EN NOMINA DEL PERIODO '+ @CodigoPeriodo +' '+ REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))



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

	--select * from #tempChecadas where IDEmpleado = 29
	
	select ie.*
	into #tempAusentismosIncidencias
	from Asistencia.tblIncidenciaEmpleado ie with (nolock)
		join @Fechas fecha on ie.Fecha = fecha.Fecha 
		join @dtEmpleados tempEmp on ie.IDEmpleado = tempEmp.IDEmpleado 
		join Asistencia.tblCatIncidencias I with(nolock)
			on IE.IDIncidencia = I.IDIncidencia
	
	where I.IDIncidencia = 'EX'
		and isnull(IE.Autorizado,0) = 1
		and IE.Fecha Between @FechaIni and @FechaFin



	--select * from @Fechas

		--select * from #tempAusentismosIncidencias
		--order by IDEmpleado
	select
		 e.ClaveEmpleado
		,e.NOMBRECOMPLETO as Nombre
		,e.RegPatronal as RegPatronal
		,f.Fecha
		,FechaStr = UPPER(SUBSTRING(f.NombreDia,1,3))
					+'  '+ App.fnAddString(2,cast(f.Dia as varchar(2)),'0',1)
					
		,CASE WHEN SUM(isnull(I.TiempoExtraDecimal,0)) = 0 THEN null ELSE cast( SUM(isnull(I.TiempoExtraDecimal,0)) as decimal(18,2)) END as TiempoExtra
		,Titulo = @Titulo

	from @Fechas f
		cross apply @dtEmpleados e
		left join #tempAusentismosIncidencias i on i.IDEmpleado = e.IDEmpleado and i.Fecha = f.Fecha
	where e.IDEmpleado in (select distinct IDEmpleado from #tempAusentismosIncidencias)
	group by e.ClaveEmpleado,f.Fecha,e.NOMBRECOMPLETO, f.NombreMes, f.NombreDia,f.Dia, e.RegPatronal
	
	order by e.ClaveEmpleado,f.Fecha
GO

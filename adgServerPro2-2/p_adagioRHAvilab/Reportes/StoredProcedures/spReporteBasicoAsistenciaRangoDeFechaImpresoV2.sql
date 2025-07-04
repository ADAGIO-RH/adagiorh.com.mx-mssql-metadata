USE [p_adagioRHAvilab]
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
		  
Create proc [Reportes].[spReporteBasicoAsistenciaRangoDeFechaImpresoV2] --@IDUsuario=1 
(
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
	,@EmpleadoIni varchar(20)		= '0'
	,@EmpleadoFin varchar(20)		= 'ZZZZZZZZZZZZZZZZZZZZ'
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
		,@dtFiltros [Nomina].[dtFiltrosRH]  
		,@IDTipoNominaInt int 
		 ,@Titulo Varchar(max)     
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
  
	SET LANGUAGE @IdiomaSQL

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
		,('ClaveEmpleadoInicial',isnull(@EmpleadoIni,'0'))
		,('ClaveEmpleadoFinal',isnull(@EmpleadoFin,'ZZZZZZZZZZZZZZZZZZZZ'))

	if object_id('tempdb..#tempChecadas') is not null drop table #tempChecadas;    
	if object_id('tempdb..#tempAusentismosIncidencias') is not null drop table #tempAusentismosIncidencias;    
	
	    
	SET @Titulo =  UPPER( 'LISTA DE ASISTENCIA DEL ' + REPLACE(FORMAT(@FechaIni,'dd/MMM/yyyy'),'.','') + ' AL '+  REPLACE(FORMAT(@FechaFin,'dd/MMM/yyyy'),'.',''))

	insert @Fechas  
	exec app.spListaFechas @FechaIni = @FechaIni, @FechaFin = @FechaFin  

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
	

	select * 
		into #tempAusentismosIncidencias
		from (
			select ie.*
			,row_number() over (partition by  ie.IDEmpleado,ie.Fecha order by ie.IDIncidencia desc ) as Row#
			from Asistencia.tblIncidenciaEmpleado ie with (nolock)
				join @Fechas fecha on ie.Fecha = fecha.Fecha 
				join @dtEmpleados tempEmp on ie.IDEmpleado = tempEmp.IDEmpleado 
			where (ie.IDIncidencia in ('F','D','V','G','P','I','S')
				and ie.Autorizado = 1 ) OR IE.IDIncidencia = 'DL'
		) x
	where Row# = 1
	order by IDEmpleado



	--F		FALTA INJUSTIFICADA
	--D		DESCANSO
	--V		VACACIONES
	--G		PERMISO CON GOCE
	--P		PERMISO SIN GOCE
	--I		INCAPACIDAD
	--DL	DESCANSO LABORADO
	--S		SUSPENSIÓN

	--COM	COMEDOR
	--DF	DIAS FESTIVOS TRABAJADO
	--EX	TIEMPO EXTRA
	--G		PERMISO CON GOCE
	--NC	NO CHECO
	--PD	PRIMA DOMINICAL TRABAJADA
	--R		RETARDO
	--SA	SALIDA ANTICIPADA
	


	--select * from #tempAusentismosIncidencias return
	--select * from @Fechas



	if object_id('tempdb..#tempBajas') is not null drop table #tempBajas; 
	select 
		IDEmpleado
		,ClaveEmpleado
		,(select top 1 ma.Fecha from IMSS.tblMovAfiliatorios ma
				inner join IMSS.tblCatTipoMovimientos ctm
					on ctm.IDTipoMovimiento = ma.IDTipoMovimiento
				where ma.IDEmpleado = e.IDEmpleado order by Fecha desc) Fecha
		,(select top 1 ctm.Codigo from IMSS.tblMovAfiliatorios ma
				inner join IMSS.tblCatTipoMovimientos ctm
					on ctm.IDTipoMovimiento = ma.IDTipoMovimiento
				where ma.IDEmpleado = e.IDEmpleado order by Fecha desc) as TipoMovimiento
		into #TempBajas
		from @dtEmpleados e
		
		delete 
			from #TempBajas
			where TipoMovimiento <> 'B'


	--select e.ClaveEmpleado, tb.* from @dtempleados e
	--	left join #TempBajas tb
	--		on tb.IDEmpleado = e.IDEmpleado

	select
		 empFecha.ClaveEmpleado
		,empFecha.NOMBRECOMPLETO as Nombre
		,empFecha.Puesto
		,empFecha.Departamento
		,empFecha.Fecha
		,empFecha.Empresa
		,DAY(empFecha.Fecha) as Dia
		,SUBSTRING(empFecha.NombreDia,1,1) as LetraDia
		,CASE WHEN empFecha.Fecha < empFecha.FechaAntiguedad THEN '-'
			  WHEN empFecha.Fecha > isnull(tb.Fecha,'9999-12-31') THEN 'B'
			  ELSE isnull(i.IDIncidencia,'A') 
		 END  Incidencia
		--,FechaStr = App.fnAddString(2,cast(empFecha.Dia as varchar(2)),'0',1)
		--			+' - '+ UPPER(SUBSTRING(empFecha.NombreMes,1,3))
		--			+' '+ UPPER(empFecha.NombreDia)
		--,case 
		--	when i.IDIncidencia is null then 
		--		isnull((select top 1 cast(cast(Fecha as time) as varchar(5))
		--			from #tempChecadas 
		--			where IDTipoChecada in ('ET') and FechaOrigen = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado
		--			order by Fecha asc),'NC')
		--	else i.IDIncidencia end Entrada
		--,case 
		--	when i.IDIncidencia is null then 
		--		isnull((select top 1 cast(cast(Fecha as time) as varchar(5))
		--			from #tempChecadas 
		--			where IDTipoChecada in ('ST') and FechaOrigen = empFecha.Fecha and IDEmpleado = empFecha.IDEmpleado
		--			order by Fecha desc),'NC') 
		--	else i.IDIncidencia end Salida
		--,i.IDIncidencia
		--,i.Comentario
		--,NombrePuesto = empFecha.NOMBRECOMPLETO +' <br/> '+coalesce(empFecha.Puesto,'')
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
		left join #TempBajas tb on tb.IDEmpleado = empFecha.IDEmpleado
	--where empFecha.ClaveEmpleado = '02186'
	order by empFecha.IDEmpleado,empFecha.Fecha
GO

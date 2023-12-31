USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [p_adagioRHViva]
--GO
--/****** Object:  StoredProcedure [Reportes].[spSaldosDeVacacionesRuggedtech]   Script Date: 3/19/2020 12:57:49 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
CREATE proc [Reportes].[spSaldosDeVacacionesRuggedtech](
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
		,@IDCliente int
		
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
	
	select @IDCliente = IDCliente from rh.tblCatClientes where NombreComercial = 'RUGGED TECH'

	select 
		@FechaIni = isnull(@FechaIni,'1900-01-01')
		,@FechaFin = isnull(@FechaFin,getdate())

	if object_id('tempdb..#tempVacacionesTomadas') is not null drop table #tempVacacionesTomadas;  
	if object_id('tempdb..#tempCTE') is not null drop table #tempCTE;  
	if object_id('tempdb..#PTO') is not null drop table #PTO;

	insert @empleados
	exec RH.spBuscarEmpleados @EmpleadoIni=@EmpleadoIni,@EmpleadoFin=@EmpleadoFin,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario

	;with cteAntiguedad(IDEmpleado,Anio, FechaIni) AS  
    (  
		SELECT IDEmpleado,cast(0.0 as float),FechaAntiguedad
		from @empleados
		UNION ALL  
		SELECT IDEmpleado, Anio + 1,dateadd(year,1,FechaIni)  
		FROM cteAntiguedad 
		WHERE Anio + 1 <= (select (DATEDIFF(day,FechaAntiguedad,@FechaFin) / 365.2425)
						from @empleados 
						where IDEmpleado = cteAntiguedad.IDEmpleado) -- how many times to iterate  
    )
 
	select a.*
		,FechaFin = cast(dateadd(year,1, dateadd(day,-1,a.FechaIni)) as date)
		,Clientes.IDCliente
		,Prestaciones.IDTipoPrestacion
		,cast(isnull(configClientes.Valor,0.00) as Float) VacacionesCaducanEn
		,DiasPorAnio =  detallePrestacion.DiasVacaciones 
		,cast(0 as float) as DiasTomados  
		,cast(0 as float) as DiasVencidos  
		,cast(0 as float) as DiasDisponibles  
		,detallePrestacion.DiasVacaciones as DiasPorAniosPrestacion
	INTO #tempCTE  
	from cteAntiguedad a
		LEFT JOIN [RH].[tblClienteEmpleado] Clientes WITH(NOLOCK) 
			ON Clientes.IDEmpleado = a.IDEmpleado AND Clientes.FechaIni<= dateadd(year,1, dateadd(day,-1,a.FechaIni)) and Clientes.FechaFin >= dateadd(year,1, dateadd(day,-1,a.FechaIni))
		LEFT JOIN [RH].[TblConfiguracionesCliente] configClientes WITH(NOLOCK)  on configClientes.IDCliente = Clientes.IDCliente and IDTipoConfiguracionCliente = 'VacacionesCaducanEn'
		LEFT JOIN [RH].[TblPrestacionesEmpleado] Prestaciones WITH(NOLOCK) 
			ON Prestaciones.IDEmpleado = a.IDEmpleado AND Prestaciones.FechaIni<= DATEADD(year,1,a.FechaIni) and Prestaciones.FechaFin >= DATEADD(year,1,a.FechaIni)
		LEFT JOIN [RH].[tblCatTiposPrestacionesDetalle] detallePrestacion WITH(NOLOCK) on detallePrestacion.IDTipoPrestacion = Prestaciones.IDTipoPrestacion and detallePrestacion.Antiguedad - 1 = a.Anio
	order by a.IDEmpleado,a.Anio
	option (maxrecursion 0)

	update c
		set c.DiasTomados = d.Total
	from #tempCTE c
		join (
			select a.IDEmpleado,a.Anio,count(ie.IDIncidenciaEmpleado) as Total
			from Asistencia.tblIncidenciaEmpleado ie with (nolock)
				join #tempCTE a
					on ie.IDEmpleado = a.IDEmpleado and ie.Fecha between a.FechaIni and a.FechaFin
			where ie.IDIncidencia = 'V'
			group by a.IDEmpleado,a.Anio
		) d on c.IDEmpleado = d.IDEmpleado and c.Anio = d.Anio

	--update #tempCTE  
	--set DiasVencidos = case   
	--						when (DiasTomados > DiasPorAnio) then 0   
	--						when DATEADD(day,VacacionesCaducanEn,FechaFin) < getdate() then  DiasPorAnio - DiasTomados 
	--					else 0 end  
	--	,DiasDisponibles = 999
	
		 select 
			PTOActual.IDEmpleado
			,PTOActual.Cantidad as PTO_Generados
			,COUNT (ie.IDIncidencia) as PTO_Tomados
			,(PTOActual.Cantidad - COUNT (ie.IDIncidencia)) as PTO_Disponibles
			,FechaInicio
			,FechaFin
			into #PTO
			from (
					select
					SaldosPTO.*
					,e.FechaAntiguedad
					from @empleados e
					inner join (
								select *
									,ROW_NUMBER()OVER(partition By IDEmpleado order by FechaInicio desc) as [Row]
									from Asistencia.tblIncidenciasSaldos ins
							) SaldosPTO on SaldosPTO.IDEmpleado = e.IDEmpleado and [Row] = 1
				) PTOActual 
				left join Asistencia.tblIncidenciaEmpleado ie
					on ie.IDEmpleado = PTOActual.IDEmpleado 
						and ie.IDIncidencia = 'PTO'
						and ie.Fecha between PTOActual.FechaInicio and PTOActual.FechaFin
			group by PTOActual.IDEmpleado, PTOActual.Cantidad, PTOActual.FechaInicio, PTOActual.FechaFin

		Select 
			 e.ClaveEmpleado as CLAVE
			,e.NOMBRECOMPLETO as NOMBRE
			,e.DEPARTAMENTO
			,e.SUCURSAL
			,e.PUESTO
			,FORMAT(CAST(e.fechaAntiguedad AS DATE),'dd/MM/yyyy') as FECHA_DE_ANTIGUEDAD
			,cast((ejercicioActual.Anio)+(datediff(day,ejercicioActual.FechaIni,@FechaFin)/365.2425) as decimal(18,2)) ANTIGUEDAD_AÑOS
			,ejercicioActual.DiasPorAnio as VACACIONES_AÑO_ACTUAL
			,Vacaciones.DiasGeneradas	as VACACIONES_GENERADAS
			,Vacaciones.DiasTomados		as DIAS_TOMADOS
			,Vacaciones.DiasDisponibles	as VACACIONES_POR_DISFRUTAR
			,FORMAT(CAST(ISNULL(PTO.FechaInicio,e.FechaAntiguedad) AS DATE),'dd/MM/yyyy') as FECHA_INICIO_PTO
			,FORMAT(CAST(ISNULL(PTO.FechaFin,'31/12/9999') AS DATE),'dd/MM/yyyy') as FECHA_FIN_PTO
			,ISNULL(PTO.PTO_Generados,0) as PTO_GENERADOS
			,ISNULL(PTO.PTO_Tomados,0) as PTO_TOMADOS
			,ISNULL(PTO.PTO_Disponibles,0) as PTO_POR_DISFRUTAR
			from @empleados e
				inner join (
					select 
						IDEmpleado
						,SUM(DiasPorAnio) DiasGeneradas
						,SUM(DiasTomados) DiasTomados
						,SUM(DiasPorAnio) - SUM(DiasTomados) DiasDisponibles
						from #tempCTE
						group by IDEmpleado
					) Vacaciones on Vacaciones.IDEmpleado = e.IDEmpleado
				inner join (
						select 
							anios.IDEmpleado
							,anios.Anio
							,anios.FechaIni
							,anios.FechaFin
							--,FechaFin = case when anios.FechaFin > cast(getdate() as date) then cast(getdate() as date) else anios.FechaFin end
							,anios.DiasPorAnio
							,anios.DiasPorAniosPrestacion
							,anios.DiasTomados as DiasTomadosAnioActual
							,ROW_NUMBER()OVER(partition By IDEmpleado order by Anio desc) as [Row]
					from #tempCTE anios
					) ejercicioActual on e.IDEmpleado = ejercicioActual.IDEmpleado and ejercicioActual.[Row] = 1
				left join #PTO PTO
					on PTO.IDEmpleado = e.IDEmpleado
			where e.IDCliente = @IDCliente
			order by e.ClaveEmpleado
GO

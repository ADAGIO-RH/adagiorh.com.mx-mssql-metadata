USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd)		Autor			Comentario  
------------------- ------------------- ------------------------------------------------------------  
2022-04-22			Yesenia Leonel		Se modificó el LEFT JOIN [RH].[TblPrestacionesEmpleado] cuando inserta los datos en #tempCTEDos
2022-04-28			Yesenia Leonel		Se modificó una linea del select donde llena #tempCTEDos cambiando GetDate() por @FechaFin
***************************************************************************************************/  
CREATE proc [Reportes].[spSaldosDeVacacionesSAKATA](
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
		,@totalVacaciones int = 0
		,@IDIdioma Varchar(5)      
		,@IdiomaSQL varchar(100) = null 
		,@counter int = 1
		,@vencidas int 
		,@idempleado int
		,@Tomados int = 0
		,@Antiguedad int
		,@FechaAntiguedad date
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

	select 
		@FechaIni = isnull(@FechaIni,'1900-01-01')
		,@FechaFin = isnull(@FechaFin,getdate())

	if object_id('tempdb..#tempVacacionesTomadas') is not null drop table #tempVacacionesTomadas;  
	if object_id('tempdb..#tempCTEDos') is not null drop table #tempCTEDos;  

	insert @empleados
	exec RH.spBuscarEmpleados @EmpleadoIni=@EmpleadoIni,@EmpleadoFin=@EmpleadoFin,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario

	;with cteAntiguedad(IDEmpleado,Anio, FechaIni) AS  
    (  
		SELECT IDEmpleado,cast(1.0 as float),FechaAntiguedad
		from @empleados
		UNION ALL  
		SELECT IDEmpleado, Anio + 1.0,dateadd(year,1,FechaIni)  
		FROM cteAntiguedad 
		WHERE Anio <= (select (DATEDIFF(day,FechaAntiguedad,@FechaFin) / 365.2425)
						from @empleados 
						where IDEmpleado = cteAntiguedad.IDEmpleado) -- how many times to iterate  
    )
  
  --select * from cteAntiguedad
  --return
	select a.*
		--,FechaFin = case when cast(dateadd(year,1, dateadd(day,-1,a.FechaIni)) as date) > cast(getdate() as date) then cast(getdate() as date) else cast(dateadd(year,1, dateadd(day,-1,a.FechaIni)) as date) end
		,FechaFin = case when cast(dateadd(year,1, dateadd(day,-1,a.FechaIni)) as date) > cast(getdate() as date) then cast(@FechaFin as date) else cast(dateadd(year,1, dateadd(day,-1,a.FechaIni)) as date) end
		,Clientes.IDCliente
		,Prestaciones.IDTipoPrestacion
		,cast(isnull(configClientes.Valor,365.00) as Float) VacacionesCaducanEn
		,DiasPorAnio = case when cast(dateadd(year,1, dateadd(day,-1,a.FechaIni)) as date) > @FechaFin then cast((datediff(day,a.FechaIni,@FechaFin)/365.2425 * detallePrestacion.DiasVacaciones) as decimal(18,2)) else detallePrestacion.DiasVacaciones end 
		,cast(0 as float) as DiasTomados  
		,cast(0 as float) as DiasVencidos  
		,cast(0 as float) as DiasDisponibles  
		,detallePrestacion.DiasVacaciones as DiasPorAniosPrestacion
	INTO #tempCTEDos  
	from cteAntiguedad a
		LEFT JOIN [RH].[tblClienteEmpleado] Clientes WITH(NOLOCK) 
			ON Clientes.IDEmpleado = a.IDEmpleado AND Clientes.FechaIni<= dateadd(year,1, dateadd(day,-1,a.FechaIni)) and Clientes.FechaFin >= dateadd(year,1, dateadd(day,-1,a.FechaIni))
		LEFT JOIN [RH].[TblConfiguracionesCliente] configClientes WITH(NOLOCK)  on configClientes.IDCliente = Clientes.IDCliente and IDTipoConfiguracionCliente = 'VacacionesCaducanEn'
		LEFT JOIN [RH].[TblPrestacionesEmpleado] Prestaciones WITH(NOLOCK) 
			ON Prestaciones.IDEmpleado = a.IDEmpleado 
			AND dateadd(year,1,a.FechaIni) between Prestaciones.FechaIni and Prestaciones.FechaFin			  
			--AND Prestaciones.FechaIni<= dateadd(year,1, dateadd(day,-1,a.FechaIni)) and Prestaciones.FechaFin >= dateadd(year,1, dateadd(day,-1,a.FechaIni))
		LEFT JOIN [RH].[tblCatTiposPrestacionesDetalle] detallePrestacion WITH(NOLOCK) on detallePrestacion.IDTipoPrestacion = Prestaciones.IDTipoPrestacion and detallePrestacion.Antiguedad = a.Anio
	order by a.IDEmpleado,a.Anio
	option (maxrecursion 0)

	IF object_ID('TEMPDB..#TempTotalVaca') IS NOT NULL DROP TABLE #TempTotalVaca 
	IF object_ID('TEMPDB..#TempEmpleados') IS NOT NULL DROP TABLE #TempEmpleados


	select ie.idempleado, count(ie.IDIncidenciaEmpleado) as total
	into #TempTotalVaca
	from Asistencia.tblIncidenciaEmpleado ie with (nolock)
		join #tempCTEDos a
			on ie.IDEmpleado = a.IDEmpleado --and ie.Fecha between a.FechaIni and a.FechaFin
	where ie.IDIncidencia = 'V'
	group by ie.idempleado


	select row_number() over (partition by null order by Idempleado,Claveempleado) as numero, *
	into #tempEmpleados
	From @empleados e where DATEDIFF(MONTH,e.FechaAntiguedad,@FechaFin) > 8

	select @counter = count (distinct idempleado) from @empleados
	declare @tblTempVacaciones [Asistencia].[dtSaldosDeVacaciones] /*as table(
					Anio int
					,FechaIni date
					,FechaFin date
					,Dias int
					,DiasTomados int
					,DiasVencidos int
					,DiasDisponibles decimal(18,2)
					,prestacion int
	)*/
	

	while (isnull(@counter,0) > 0)
	begin	
	
		set @vencidas = 0
		set @Tomados = 0
		select @idempleado =  idempleado from #tempEmpleados where numero = @counter
		set @FechaAntiguedad = (select FechaAntiguedad  from #tempEmpleados where IDEmpleado = @idempleado)
		set @Antiguedad =  (SELECT DATEDIFF(MONTH,@FechaAntiguedad,@FechaFin))

		if (@Antiguedad>8)
		begin 
		
		--select @idempleado
		delete from @tblTempVacaciones
		
		insert into @tblTempVacaciones
		exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @idempleado = @idempleado, @proporcional = null,@FechaBaja= @fechafin,@IDUsuario= @IDUsuario
		
		SELECT @vencidas = SUM(DiasVencidos)  FROM @tblTempVacaciones 
		Select @Tomados = SUM(DiasTomados) FROM @tblTempVacaciones
					
		
		update cte set DiasVencidos = @vencidas, DiasTomados = @Tomados FROM #tempCTEDos cte
			 where IDEmpleado = @idempleado and Anio = 1
	 END
		set @counter = @counter - 1


	end
	
	--select * from #tempCTEDos return
	


	select 
		 e.ClaveEmpleado as CLAVE
		,e.NOMBRECOMPLETO as NOMBRE
		,e.DEPARTAMENTO
		,e.SUCURSAL
		,e.PUESTO
		,e.DIVISION
		,e.Region 
		,FORMAT(CAST(e.fechaAntiguedad AS DATE),'dd/MM/yyyy') as FECHA_DE_ANTIGUEDAD
		,vacaciones.Anio							AS [AÑOS_ANTIGüEDAD]
		,vacaciones.DiasPorAniosPrestacion			AS [VACACIONES_PERIODO_SIGUIENTE]			--[VACACIONES_AÑO_ACTUAL]
		,vacaciones.VacacionesGeneradasDesdeIngreso AS [TOTAL_DE_VACACIONES_CORRESPONDIENTES]	--[VACACIONES_GENERADAS]
		,vacaciones.DiasPorAnio						AS [VACACIONES_PROPORCIONALES]
		,vacaciones.DiasTomados						AS [DIAS_DISFRUTADOS_Y_AUTORIZADOS]			--[DIAS_TOMADOS]
		,vacaciones.DiasVencidos					AS [DIAS_VENCIDOS]
		,vacaciones.DiasDisponibles					AS [VACACIONES_CON_PROPORCION]				--[VACACIONES_CON_PROPORCION]
		,vacaciones.VacacionesGeneradasDesdeIngreso - vacaciones.DiasTomados - vacaciones.diasVencidos AS [DIAS_VIGENTES]--[VACACIONES_POR_DISFRUTAR]
		--,vacaciones.VacacionesGeneradasDesdeIngreso - vacaciones.DiasTomados AS [VACACIONES_POR_DISFRUTAR]
		--,vacaciones.DiasTomadosAnioActual
	from (
		select t.IDEmpleado
	 
			--,t.IDCliente
			--,t.IDTipoPrestacion
			,Anio = cast((ejercicioActual.Anio - 1)+(datediff(day,ejercicioActual.FechaIni,@FechaFin)/365.2425) as decimal(18,2))
			,ejercicioActual.FechaIni
			,ejercicioActual.FechaFin
			,SUM(t.DiasPorAnio)-ejercicioActual.DiasPorAnio as VacacionesGeneradasDesdeIngreso
			,SUM(DiasTomados) as DiasTomados
			, DiasDisponibles = SUM(t.DiasPorAnio) - SUM(DiasTomados)
			,ProporcionAlDiaDeHoy = cast((datediff(day,ejercicioActual.FechaIni,ejercicioActual.FechaFin)/365.2425 * ejercicioActual.DiasPorAnio) as decimal(18,2))
			,ejercicioActual.DiasPorAnio
			,ejercicioActual.DiasTomadosAnioActual
			,ejercicioActual.DiasPorAniosPrestacion
			,SUM(t.DiasVencidos) as DiasVencidos
		from #tempCTEDos t
			left join (
				select 
					anios.IDEmpleado
					,anios.Anio
					,anios.FechaIni
					,anios.FechaFin
					--,FechaFin = case when anios.FechaFin > cast(getdate() as date) then cast(getdate() as date) else anios.FechaFin end
					,anios.DiasPorAnio
					,anios.DiasPorAniosPrestacion
					,anios.DiasTomados as DiasTomadosAnioActual
					,anios.diasvencidos
					,ROW_NUMBER()OVER(partition By IDEmpleado order by Anio desc) as [Row]
				from #tempCTEDos anios
			) ejercicioActual on t.IDEmpleado = ejercicioActual.IDEmpleado and ejercicioActual.[Row] = 1
		group by t.IDEmpleado,ejercicioActual.Anio,ejercicioActual.FechaIni,ejercicioActual.FechaFin,ejercicioActual.DiasPorAnio,ejercicioActual.DiasTomadosAnioActual, ejercicioActual.DiasPorAniosPrestacion
	) vacaciones
		join @empleados e on vacaciones.IDEmpleado = e.IDEmpleado
	order by e.ClaveEmpleado, vacaciones.Anio asc
GO

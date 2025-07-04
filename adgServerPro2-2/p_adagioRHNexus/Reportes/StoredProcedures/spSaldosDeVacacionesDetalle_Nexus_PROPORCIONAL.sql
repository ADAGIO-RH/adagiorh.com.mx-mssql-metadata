USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--USE [p_adagioRHViva]
--GO
--/****** Object:  StoredProcedure [Reportes].[spSaldosDeVacaciones]    Script Date: 3/19/2020 12:57:49 PM ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO

/*****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd)		Autor			Comentario  
------------------- ------------------- ------------------------------------------------------------  
2022-04-22			Yesenia Leonel		Se modificó el LEFT JOIN [RH].[TblPrestacionesEmpleado] cuando inserta los datos en #tempCTEDos
2022-04-28			Yesenia Leonel		Se modificó una linea del select donde llena #tempCTEDos cambiando GetDate() por @FechaFin
***************************************************************************************************/  
CREATE proc [Reportes].[spSaldosDeVacacionesDetalle_Nexus_PROPORCIONAL](
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
		,@idempleado int
		,@vencidas int 
		,@Tomados int = 0
		,@Disponibles int
		,@DiasPrestacion int
		,@Antiguedad int
		,@FechaAntiguedad date
		,@EsProporcional bit
		,@Cliente int
		,@IDCliente int
		,@Error Varchar(255)
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
	SET @Cliente	= ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Clientes'),',')),'0')    

	--SET @Cliente = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END
	--	from @dtFiltros where Catalogo = 'Clientes'

	select
		 @IDCliente					= ce.IDCliente  
	--	,@spCustomSaldoVacaciones	= isnull(config.Valor,'')
	from [RH].[tblEmpleadosMaster] e with (nolock)  
		LEFT JOIN [RH].tblClienteEmpleado ce with (nolock) ON ce.IDEmpleado = e.IDEmpleado   
			and ce.FechaIni<= @FechaFin and ce.FechaFin >= @FechaFin     
		LEFT JOIN RH.[TblConfiguracionesCliente] config with (nolock) on config.IDCliente = ce.IDCliente
			and config.IDTipoConfiguracionCliente = 'spCustomSaldoVacaciones'
	where e.IDEmpleado = @IDEmpleado 
	select 
		@FechaIni = isnull(@FechaIni,'1900-01-01')
		,@FechaFin = isnull(@FechaFin,getdate())

	if object_id('tempdb..#tempVacacionesTomadas') is not null drop table #tempVacacionesTomadas;  
	if object_id('tempdb..#tempCTEDos') is not null drop table #tempCTEDos;  

	insert @empleados
	exec RH.spBuscarEmpleados @EmpleadoIni=@EmpleadoIni,@EmpleadoFin=@EmpleadoFin,@FechaIni = @FechaIni, @FechaFin = @FechaFin, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario

	
  
  --select * from cteAntiguedad
  --return
	

	IF object_ID('TEMPDB..#TempTotalVaca') IS NOT NULL DROP TABLE #TempTotalVaca 
	IF object_ID('TEMPDB..#TempEmpleados') IS NOT NULL DROP TABLE #TempEmpleados

	select @counter = min( e.idempleado) from @empleados e inner join rh.tblEmpleadosMaster em on em.IDEmpleado = e.IDEmpleado
	
    declare @TempCTE as table(
                     IDEmpleado int
					,Anio int
					,FechaIni date
					,FechaFin date
					,Dias decimal(18,2)
					,DiasGenerados decimal(18,2)
					,DiasTomados int
					,DiasVencidos int
					,DiasDisponibles decimal(18,2)
					,prestacion varchar(max)
					,FechaIniDisponible date
					,FechaFinDisponible date
					,Mensaje Varchar(max)
	)

    declare @tblTempVacaciones as table(
                    
					 Anio int
					,FechaIni date
					,FechaFin date
					,Dias decimal(18,2)
					,DiasGenerados decimal(18,2)
					,DiasTomados int
					,DiasVencidos int
					,DiasDisponibles decimal(18,2)
					,prestacion varchar(max)
					,FechaIniDisponible date
					,FechaFinDisponible date
					

	)

	    declare @TempErrores as table(
                     IDEmpleado int
					,Error varchar(max)
	)

	

	while (@counter <= (select max(e.idempleado) from @empleados e inner join rh.tblEmpleadosMaster em on em.IDEmpleado = e.IDEmpleado))
	begin	
	
		
		select @idempleado =  idempleado , @FechaAntiguedad = FechaAntiguedad from @empleados where IDEmpleado = @counter
	
		delete from @tblTempVacaciones
		
		if(@Cliente <> 1 ) /*Proporcionales para Dominicana y para todos los finiquitos */
		set @EsProporcional = 1
	else
		set @ESProporcional = 1

		begin try
			if(@Cliente <> 1 and @EsProporcional=1)
			Begin
				insert into @tblTempVacaciones
				exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @idempleado = @idempleado, @proporcional = @EsProporcional,@FechaBaja= @fechafin,@IDUsuario= @IDUsuario
		print'1'
		END
			ELSE IF(@Cliente = 1 and @EsProporcional=1)
			BEGIN
				insert into @tblTempVacaciones
				exec [Asistencia].[spBuscarSaldosVacacionesPorAnios_Nexus_Proporcional_MX] @idempleado = @idempleado, @proporcional = 1,@FechaBaja= @fechafin,@IDUsuario= @IDUsuario
				print'2'

		END
			ELSE
			BEGIN
				insert into @tblTempVacaciones
				exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @idempleado = @idempleado, @proporcional = @EsProporcional,@FechaBaja= @fechafin,@IDUsuario= @IDUsuario
		
		END

				Insert into @TempCTE
				select @idempleado,*, '' from @tblTempVacaciones v

		end try
		begin Catch
			Set @Error = ERROR_MESSAGE ()
			Insert into @TempCTE(IDEmpleado, Mensaje)
			VALUES(@idempleado, @Error)
			SET @Error = null
		end catch
		
		--	select @idempleado,@EsProporcional,@fechafin,@IDUsuario
		--return 
		----exec [Asistencia].[spBuscarSaldosVacacionesPorAniosDetalle_Nexus] @idempleado = @idempleado, @proporcional = @EsProporcional,@FechaBaja= @fechafin,@IDUsuario= @IDUsuario
		
	
			
					
		select @counter =  min(e.idempleado) from @empleados e inner join rh.tblEmpleadosMaster em on em.IDEmpleado = e.IDEmpleado where e.IDEmpleado > @counter


	end
				--	select *from @tblTempVacaciones

	
		
	Select 
    [em].[ClaveEmpleado],
    em.NOMBRECOMPLETO,
	em.region,
	em.Sucursal,
	em.CentroCosto,
	em.Departamento,
	em.Puesto,
	FORMAT(em.FechaAntiguedad,'dd/MM/yyyy') as FechaAntiguedad,
    [c].[Anio] as [Periodo],
	FORMAT(c.fechafin,'yyyy') as AÑO,
    FORMAT(c.FechaIni,'dd/MM/yyyy') as FechaInicial,
    FORMAT(c.fechafin,'dd/MM/yyyy') as FechaFinal,
	datepart(MONTH, c.fechafin) [MES INICIO DE VIGENCIA],
    cast([c].[Dias] as decimal(18,2)) as  Dias,
    [c].[DiasTomados],
    [c].[DiasVencidos],
    [c].[DiasDisponibles],
	[c].[prestacion],
    FORMAT(c.FechaIniDisponible,'dd/MM/yyyy') as FechaIniDisponible,
    FORMAT(c.fechafinDisponible,'dd/MM/yyyy') as FechaFinDisponible,
	--FORMAT((dateadd(day,544,c.fechafin)),'dd/MM/yyyy') as [Vencimiento],
	C.Mensaje
    from @TempCTE c 
    inner join rh.tblEmpleadosMaster em 
        on c.idempleado = em.idempleado
	where em.Vigente = 1
	ORDER BY em.ClaveEmpleado asc

GO

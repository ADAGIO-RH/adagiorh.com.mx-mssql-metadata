USE [p_adagioRHHotelColibri]
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
CREATE proc [Reportes].[spSaldosDeVacacionesComoEnAsistencia_Colibri](
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
		,@tblTempVacaciones [Asistencia].[dtSaldosDeVacaciones]
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
					,Dias int
					,DiasGenerados  decimal(18,2)  --agregado por error en ejecución 
					,DiasTomados int
					,DiasVencidos int
					,DiasDisponibles decimal(18,2)
					,prestacion varchar(max)
					,FechaIniDisponible date
					,FechaFinDisponible date
	)

 --   declare @tblTempVacaciones as table(
                    
	--				 Anio int
	--				,FechaIni date
	--				,FechaFin date
	--				,Dias int
	--				,DiasTomados int
	--				,DiasVencidos int
	--				,DiasDisponibles decimal(18,2)
	--				,prestacion varchar(max)
	--)
	

	while (@counter <= (select max(e.idempleado) from @empleados e inner join rh.tblEmpleadosMaster em on em.IDEmpleado = e.IDEmpleado))
	begin	
	
		
		select @idempleado =  idempleado , @FechaAntiguedad = FechaIngreso from @empleados where IDEmpleado = @counter
	
		delete from @tblTempVacaciones
		
		insert into @tblTempVacaciones
		exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @idempleado = @idempleado, @proporcional = null,@FechaBaja= @fechafin,@IDUsuario= @IDUsuario
		

		

		Insert into @TempCTE
        select @idempleado,* from @tblTempVacaciones
					

		select @counter =  min(e.idempleado) from @empleados e inner join rh.tblEmpleadosMaster em on em.IDEmpleado = e.IDEmpleado where e.IDEmpleado > @counter


	end
	
	
	Select 
    [em].[ClaveEmpleado],
    em.NOMBRECOMPLETO,
	em.Departamento,
	em.Puesto,
    [c].[Anio],
    FORMAT(c.FechaIni,'dd/MM/yyyy') as FechaInicial,
    FORMAT(c.fechafin,'dd/MM/yyyy') as FechaFinal,
    [c].[Dias],
    [c].[DiasTomados],
    [c].[DiasVencidos],
    [c].[DiasDisponibles],
    [c].[prestacion]
    from @TempCTE c 
    inner join rh.tblEmpleadosMaster em 
        on c.idempleado = em.idempleado
	where em.Vigente = 1
	ORDER BY em.ClaveEmpleado asc

GO

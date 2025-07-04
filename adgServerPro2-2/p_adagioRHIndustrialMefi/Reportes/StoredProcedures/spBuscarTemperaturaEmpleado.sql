USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Reportes].[spBuscarTemperaturaEmpleado](
	@dtFiltros [Nomina].[dtFiltrosRH]  readonly
	,@IDUsuario int
) as
	SET NOCOUNT ON;
	IF 1=0 BEGIN
		SET FMTONLY OFF
	END

	declare 
		@IDIdioma Varchar(5)  
		,@IdiomaSQL varchar(100) = null  
		,@Fechas [App].[dtFechas]   
		,@dtEmpleados RH.dtEmpleados
		,@IDCliente int
		,@IDTipoNomina int
		,@FechaIni Date
		,@FechaFin Date
		,@IDTurno int
		,@EmpleadoIni varchar(20)
		,@EmpleadoFin varchar(20)


	SET @FechaIni = (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),','))
	SET @FechaFin = (Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),','))
	SET @EmpleadoIni = ISNULL((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    

	insert @dtEmpleados  
	exec [RH].[spBuscarEmpleados]   
		 @FechaIni		= @FechaIni           
		,@FechaFin		= @FechaFin    
		,@EmpleadoIni	= @EmpleadoIni
		,@EmpleadoFin	= @EmpleadoIni
		,@IDUsuario		= @IDUsuario                
		,@dtFiltros		= @dtFiltros 

	select 
		e.ClaveEmpleado
		,e.NOMBRECOMPLETO as Nombre
		,e.Departamento
		,e.Sucursal
		,e.Puesto
		,format(te.FechaHora,'dd/MM/yyyy') as Fecha
		,format(te.FechaHora,'HH:mm:ss') as Hora
		,cast(te.Temperatura as varchar(10))+'°' as Temperatura
	from Salud.tblTemperaturaEmpleado te with (nolock)
		join @dtEmpleados e on e.IDEmpleado = te.IDEmpleado
	where cast(te.FechaHora as date) between @FechaIni and @FechaFin
GO

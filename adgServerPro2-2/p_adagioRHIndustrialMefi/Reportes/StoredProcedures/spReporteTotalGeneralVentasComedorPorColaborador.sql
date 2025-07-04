USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 create   proc [Reportes].[spReporteTotalGeneralVentasComedorPorColaborador](
	@dtFiltros Nomina.dtFiltrosRH readonly     
	,@IDUsuario			int
) as
	SET DATEFIRST 7;
	declare  
		@IDRestaurante	int
		,@FechaIni			date
		,@FechaFin			date
		,@IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null
		,@TotalPaginas int = 0
		,@TotalRegistros decimal(18,2) = 0.00
	;
 
	 SET @IDRestaurante = (Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDRestaurante'),','))
	 SET @FechaIni = (Select top 1 cast(item as datetime) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),','))
	 SET @FechaFin = (Select top 1 cast(item as datetime) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),','))

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

    select @IdiomaSQL = [SQL]
    from app.tblIdiomas with (nolock)
    where IDIdioma = @IDIdioma

    if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
    begin
	   set @IdiomaSQL = 'Spanish' ;
    end
  
    SET LANGUAGE @IdiomaSQL;

	select 
		--Comedor.fnFormatoNumeroPedido([P].[Numero])	as [Numero]
		--,[R].[Nombre]								as [Restaurante]
		[E].[ClaveEmpleado]
		,[E].[NOMBRECOMPLETO]						as [Colaborador]
		,[E].[Departamento]
		,SUM(GrandTotal)									as Total
		
	from [Comedor].[tblPedidos] [P] with(nolock)
		join [Comedor].[tblCatRestaurantes] [R] with(nolock) on [R].[IDRestaurante] = [P].[IDRestaurante]
		join [RH].[tblEmpleadosMaster] [E] with(nolock) on [E].[IDEmpleado] = [P].[IDEmpleado]
		--left join [RH].[tblEmpleadosMaster] [empRecibe] with(nolock) on [empRecibe].[IDEmpleado] = [P].[IDEmpleadoRecibe]
		--left join [RH].[tblEmpleadosMaster] [empAutoriza] with(nolock) on [empAutoriza].[IDEmpleado] = [P].[IDEmpleadoAutorizo]
		--left join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = [p].IDUsuarioAutorizo
		--left join [Nomina].[tblCatPeriodos] [periodo] with (nolock) on [periodo].IDPeriodo = [p].[IDPeriodo]
	where ([P].[IDRestaurante] in (select cast(item as int) from App.Split(@IDRestaurante, ',')) or isnull(@IDRestaurante,'') = '')
		and [P].[FechaCreacion] between @FechaIni and @FechaFin
	   and isnull([p].Autorizado,0) = 1
	   and isnull([p].Cancelada,0) = 0
	   and (p.IDRestaurante = @IDRestaurante or isnull(@IDRestaurante, 0) = 0)
	group by 
		[E].[ClaveEmpleado]
		,[E].[NOMBRECOMPLETO]
		,[E].[Departamento]
GO

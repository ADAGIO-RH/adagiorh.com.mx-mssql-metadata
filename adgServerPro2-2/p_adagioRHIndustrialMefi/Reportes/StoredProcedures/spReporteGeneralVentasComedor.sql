USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spReporteGeneralVentasComedor](
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

	select top 1 @IDIdioma = dp.Valor
    from Seguridad.tblUsuarios u with (nolock)
	   Inner join App.tblPreferencias p with (nolock) on u.IDPreferencia = p.IDPreferencia
	   Inner join App.tblDetallePreferencias dp  with (nolock) on dp.IDPreferencia = p.IDPreferencia
	   Inner join App.tblCatTiposPreferencias tp  with (nolock) on tp.IDTipoPreferencia = dp.IDTipoPreferencia
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'

    select @IdiomaSQL = [SQL]
    from app.tblIdiomas with (nolock)
    where IDIdioma = @IDIdioma

    if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
    begin
	   set @IdiomaSQL = 'Spanish' ;
    end
  
    SET LANGUAGE @IdiomaSQL;

	select 
		Comedor.fnFormatoNumeroPedido([P].[Numero])	as [Numero]
		,[R].[Nombre]								as [Restaurante]
		,[E].[ClaveEmpleado]
		,[E].[NOMBRECOMPLETO]						as [Colaborador]
		,[E].[Departamento]
		,GrandTotal									as Total
		,case when isnull([P].[Autorizado],0) = 1 then 'SI' else 'NO' end	as [Autorizado]
		,[empAutoriza].[NOMBRECOMPLETO]										as [Colaborador que autorizó]
		,coalesce(u.Nombre,'')+' '+coalesce(u.Apellido, '')					as [Usuario que autorizó]
		,case when isnull([P].[DescontadaDeNomina],0) = 1 then 'SI' else 'NO' end as [DescontadaDeNomina]
		,format([P].[FechaHoraDescuento],'dd/MM/yyyy HH:mm')				as [FechaHoraDescuento]
		,isnull([periodo].[ClavePeriodo], '0000')
			+' - '+isnull([periodo].[Descripcion], 'SIN PERIODO')			as [Periodo]
		,case when isnull([P].[Cancelada],0) = 1 then 'SI' else 'NO' end	as [Cancelada]
		,[P].[NotaCancelacion]
		,format([P].[FechaCancelacion],'dd/MM/yyyy HH:mm')					as [FechaCancelacion]
		,format([P].[FechaCreacion],'dd/MM/yyyy')							as [FechaCreacion]
		,format(cast([P].[HoraCreacion] as datetime),'HH:mm')				as [HoraCreacion]
		,format(cast([P].FechaHoraAutorizacion as datetime),'HH:mm')		as [Fecha de autorizacion]
	from [Comedor].[tblPedidos] [P] with(nolock)
		join [Comedor].[tblCatRestaurantes] [R] with(nolock) on [R].[IDRestaurante] = [P].[IDRestaurante]
		join [RH].[tblEmpleadosMaster] [E] with(nolock) on [E].[IDEmpleado] = [P].[IDEmpleado]
		left join [RH].[tblEmpleadosMaster] [empRecibe] with(nolock) on [empRecibe].[IDEmpleado] = [P].[IDEmpleadoRecibe]
		left join [RH].[tblEmpleadosMaster] [empAutoriza] with(nolock) on [empAutoriza].[IDEmpleado] = [P].[IDEmpleadoAutorizo]
		left join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = [p].IDUsuarioAutorizo
		left join [Nomina].[tblCatPeriodos] [periodo] with (nolock) on [periodo].IDPeriodo = [p].[IDPeriodo]
	where ([P].[IDRestaurante] in (select cast(item as int) from App.Split(@IDRestaurante, ',')) or isnull(@IDRestaurante,'') = '')
		and [P].[FechaCreacion] between @FechaIni and @FechaFin
	   and isnull([p].Autorizado,0) = 1
	   and isnull([p].Cancelada,0) = 0
	   and (p.IDRestaurante = @IDRestaurante or isnull(@IDRestaurante, 0) = 0)
	order by r.Nombre, p.FechaCreacion, p.Numero
		--and (P.[ComandaImpresa] = case when @ParamComandaImpresa  = -1 then P.[ComandaImpresa] else @ParamComandaImpresa end)
GO

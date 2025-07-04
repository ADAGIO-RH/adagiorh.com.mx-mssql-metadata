USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Comedor].[spBuscarPedidosAAdministrar](
	@IDsRestaurantes	varchar(255)
	,@IDEmpleado		int  = 0
	,@FechaIni			date
	,@FechaFin			date
	,@ParamAutorizado			int = -1 -- -1: Todas 0: Solo No Autorizadas	1: Solo Autorizadas bit = null
	,@ParamCancelada			int = -1 -- -1: Todas 0: Solo No Canceladas		1: Solo Canceladas	bit = null
	,@ParamComandaImpresa		int = -1 -- -1: Todas 0: Solo No Impresas		1: Solo Impresas	bit = null
	,@ParamDescontadaDeNomina	int = -1 -- -1: Todas 0: Solo No Descontadas	1: Solo Descontadas bit = null
	,@IDUsuario		int
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
) as
	declare  
	   @IDIdioma Varchar(5)
	   ,@IdiomaSQL varchar(100) = null
	   ,@TotalPaginas int = 0
	   ,@TotalRegistros int = 0
	;
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	SET DATEFIRST 7;

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

	if object_id('tempdb..#tempPedidosAAdministrar') is not null drop table #tempPedidosAAdministrar;

	select 
		[P].[IDPedido]
		,[P].[Numero]
		,Comedor.fnFormatoNumeroPedido([P].[Numero])			as [NumeroStr]
		,[P].[IDRestaurante]
		,[R].[Nombre]											as [Restaurante]
		,[P].[IDEmpleado]
		,[E].[ClaveEmpleado]
		,[E].[ClaveEmpleado]+' - '+[E].[NOMBRECOMPLETO]			as [Colaborador]
		,isnull([P].[IDEmpleadoRecibe],0)						as [IDEmpleadoRecibe]
		,[Emprecibe].[ClaveEmpleado]								as [ClaveEmpleadoRecibe]
		,coalesce([Emprecibe].[ClaveEmpleado], '')
			+' - '+coalesce([Emprecibe].[NOMBRECOMPLETO],'')	as [ColaboradorRecibe]
		,[P].[Autorizado]
		,isnull([P].[IDEmpleadoAutorizo],0)						as [IDEmpleadoAutorizo]
		,isnull([P].[IDUsuarioAutorizo],0)						as [IDUsuarioAutorizo]
		,isnull([P].[FechaHoraAutorizacion],'1990-01-01 00:00')	as [FechaHoraAutorizacion]
		,[P].[ComandaImpresa]
		,isnull([P].[FechaHoraImpresion],'1990-01-01')			as [FechaHoraImpresion]
		,[P].[DescontadaDeNomina]
		,isnull([P].[FechaHoraDescuento],'1990-01-01')			as [FechaHoraDescuento]
		,isnull([P].[IDPeriodo],0)								as [IDPeriodo]
		,isnull([periodo].[ClavePeriodo], '0000')
			+' - '+isnull([periodo].[Descripcion], 'SIN PERIODO') as [Periodo]
		,[P].[Cancelada]
		,[P].[NotaCancelacion]
		,isnull([P].[FechaCancelacion],'1990-01-01 00:00')		as [FechaCancelacion]
		,[P].[FechaCreacion]
		,[P].[HoraCreacion]
		,isnull([P].[GrandTotal],0.00) as GrandTotal
	INTO #tempPedidosAAdministrar
	from [Comedor].[tblPedidos] [P] with(nolock)
		join [Comedor].[tblCatRestaurantes] [R] with(nolock) on [R].[IDRestaurante] = [P].[IDRestaurante]
		join [RH].[tblEmpleadosMaster] [E] with(nolock) on [E].[IDEmpleado] = [P].[IDEmpleado]
		left join [RH].[tblEmpleadosMaster] [empRecibe] with(nolock) on [empRecibe].[IDEmpleado] = [P].[IDEmpleadoRecibe]
		left join [Nomina].[tblCatPeriodos] [periodo] with (nolock) on [periodo].IDPeriodo = [p].[IDPeriodo]
	where ([P].[IDRestaurante] in (select cast(item as int) from App.Split(@IDsRestaurantes, ',')) or isnull(@IDsRestaurantes,'') = '')
		and (isnull([P].[IDEmpleado],0) = isnull(@IDEmpleado,0) or isnull(@IDEmpleado,0) = 0)
		and [P].[FechaCreacion] between @FechaIni and @FechaFin
		and (P.[Autorizado] = case when @ParamAutorizado = -1 then P.[Autorizado] else @ParamAutorizado end)
		and (P.[Cancelada]	= case when @ParamCancelada  = -1 then P.[Cancelada]  else @ParamCancelada end)
		--and (P.[ComandaImpresa] = case when @ParamComandaImpresa  = -1 then P.[ComandaImpresa] else @ParamComandaImpresa end)
		and (P.[DescontadaDeNomina] = case when @ParamDescontadaDeNomina  = -1 then P.[DescontadaDeNomina] else @ParamDescontadaDeNomina end)

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempPedidosAAdministrar

	select @TotalRegistros = COUNT(IDPedido) from #tempPedidosAAdministrar	
	
	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,@TotalRegistros as TotalRegistros
	from #tempPedidosAAdministrar
		order by FechaCreacion desc, [Numero] desc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

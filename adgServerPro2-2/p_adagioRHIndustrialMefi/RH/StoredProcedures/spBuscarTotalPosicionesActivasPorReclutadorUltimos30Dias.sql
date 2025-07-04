USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [RH].[spBuscarTotalPosicionesActivasPorReclutadorUltimos30Dias](
	@IDCliente	int = 0	
	,@IDUsuario	int = 0
    ,@Filtro varchar(255) = null
    ,@IDReferencia int   = null
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
) as
	SET FMTONLY OFF;  
	
	declare
		@IDTipoCatalogoEstatusPosiciones int = 5
		,@IDTipoCatalogoEstatusPlazas int = 4
		,@IDIdioma varchar(20)
        ,@IDOrganigrama int
		,@FechaInicio date	= dateadd(day, -30, getdate())
		,@FechaFin date		= getdate()
		,@ID_ESTATUS_POSICION_ACTIVAS int = 2
		,@TotalPaginas int = 0
		,@TotalRegistros int
	;
	
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');

	IF OBJECT_ID('tempdb..#TempPosiciones') IS NOT NULL DROP TABLE #TempPosiciones
	IF OBJECT_ID('tempdb..#tempEstatusPosiciones') IS NOT NULL DROP TABLE #tempEstatusPosiciones
	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

    select @IDOrganigrama = IDOrganigrama 
	from RH.tblCatOrganigramas s
	where s.Filtro=@Filtro AND S.IDReferencia = @IDReferencia;

	declare @tempPosiciones as table (
		IDPosicion int
	)

	create table #tempEstatusPosiciones (
		IDPosicion int,
		IDReclutador int,
		IDEstatus int,
		Estatus varchar(255),
        ConfiguracionStatus nvarchar(max),
		[ROW] int
	)

	insert @tempPosiciones
	select 
		p.IDPosicion
	from [RH].[tblCatPosiciones] p with (nolock)
		join [RH].[tblCatPlazas] plazas with (nolock) on plazas.IDPlaza = p.IDPlaza
	where (p.IDCliente = @IDCliente	or isnull(@IDCliente, 0) = 0)
        and (plazas.IDOrganigrama = @IDOrganigrama OR (ISNULL(@Filtro,'') = '' and isnull(@IDReferencia,0)=0 ))

	insert #tempEstatusPosiciones
	select 
		posiciones.IDPosicion
		,estatusPosiciones.IDReclutador
		,isnull(estatusPosiciones.IDEstatus,0) AS IDEstatus
		,isnull(estatus.Catalogo,'Sin estatus') AS Estatus
        ,isnull(estatus.configuracion,'') as ConfiguracionStatus
		,ROW_NUMBER()over(partition by posiciones.IDPosicion 
							ORDER by posiciones.IDPosicion, estatusPosiciones.FechaReg  desc) as [ROW]
	from @tempPosiciones posiciones
		left join RH.tblEstatusPosiciones estatusPosiciones on estatusPosiciones.IDPosicion = posiciones.IDPosicion 
		left join [App].[tblCatalogosGenerales] estatus with (nolock) on estatus.IDCatalogoGeneral = estatusPosiciones.IDEstatus 
			and estatus.IDTipoCatalogo = @IDTipoCatalogoEstatusPosiciones
	where estatusPosiciones.IDEstatus = @ID_ESTATUS_POSICION_ACTIVAS 
		and cast(estatusPosiciones.FechaReg as date) between @FechaInicio and @fechaFin

	/* 
		Solución temporal: El IDReclutador no tiene constraint con la tabla de empleados y puede tener registros en NULL o 0, 
		lo que provoca que se duplique el registro de SIN RECLUTADOR
	*/
	update #tempEstatusPosiciones
		set
			IDReclutador = null
	where isnull(IDReclutador, 0) = 0

	select
		isnull(estatus.IDReclutador, 0) as IDReclutador
		,e.ClaveEmpleado as ClaveReclutador
		,isnull(e.NombreCompleto, 'SIN RECLUTADOR') as Reclutador
		,case when fr.IDEmpleado is null then cast(0 as bit) else cast(1 as bit) end as ExisteFotoColaborador  
		,SUBSTRING (e.Nombre, 1, 1) + SUBSTRING (e.Paterno, 1, 1) as Iniciales        
		--,estatus.IDEstatus
		--,estatus.Estatus
		,Count(*) as Total
	into #TempResponse
	from @tempPosiciones p
		join #tempEstatusPosiciones estatus on estatus.IDPosicion = p.IDPosicion 
		left join RH.tblEmpleadosMaster e on e.IDEmpleado = estatus.IDReclutador
		left join [RH].[tblFotosEmpleados] fr with (nolock) on fr.IDEmpleado = e.IDEmpleado   
	group by 
		fr.IDEmpleado
		,e.ClaveEmpleado
		,e.NombreCompleto
		,e.Nombre
		,e.Paterno
		,estatus.IDReclutador
		--,estatus.IDEstatus
		--,estatus.Estatus

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDReclutador) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by Total desc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

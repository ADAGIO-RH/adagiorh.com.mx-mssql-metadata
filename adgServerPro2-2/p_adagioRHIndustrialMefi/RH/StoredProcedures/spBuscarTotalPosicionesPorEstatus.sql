USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [RH].[spBuscarTotalPosicionesPorEstatus](
	@IDCliente	int = 0	
	,@IDUsuario	int = 0
    ,@Filtro varchar(255) = null
    ,@IDReferencia int   = null
) as
	SET FMTONLY OFF;  
	
	declare
		@IDTipoCatalogoEstatusPosiciones int = 5
		,@TotalPaginas int = 0
		,@TotalRegistros decimal(18,2) = 0.00
		,@IDTipoCatalogoEstatusPlazas int = 4
		,@IDIdioma varchar(20)
        ,@IDOrganigrama int
	;

	
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');

	IF OBJECT_ID('tempdb..#TempPosiciones') IS NOT NULL DROP TABLE #TempPosiciones
	IF OBJECT_ID('tempdb..#tempEstatusPosiciones') IS NOT NULL DROP TABLE #tempEstatusPosiciones

    select @IDOrganigrama = IDOrganigrama 
	from RH.tblCatOrganigramas s
	where s.Filtro=@Filtro AND S.IDReferencia = @IDReferencia;

	declare @tempPosiciones as table (
		IDPosicion int
	)

	create table #tempEstatusPosiciones (
		IDPosicion int,
		IDEstatus int,
		Estatus varchar(255),
        ConfiguracionStatus nvarchar(max),
		[ROW] int
	)
	
	--CREATE NONCLUSTERED INDEX ix_tempNCIndex
	--	ON  #tempEstatusPosiciones ([IDPosicion],[ROW])
	--	INCLUDE ([IDEstatus],[Estatus],[ConfiguracionStatus])

	--CREATE NONCLUSTERED INDEX ix_tempNCIndexRow
	--	ON #tempEstatusPosiciones ([ROW])
	--	INCLUDE ([IDPosicion],[IDEstatus],[Estatus],[ConfiguracionStatus])

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
		,isnull(estatusPosiciones.IDEstatus,0) AS IDEstatus
		,isnull(estatus.Catalogo,'Sin estatus') AS Estatus
        ,isnull(estatus.configuracion,'') as ConfiguracionStatus
		,ROW_NUMBER()over(partition by posiciones.IDPosicion 
							ORDER by posiciones.IDPosicion, estatusPosiciones.FechaReg  desc) as [ROW]
	from @tempPosiciones posiciones
		left join RH.tblEstatusPosiciones estatusPosiciones on estatusPosiciones.IDPosicion = posiciones.IDPosicion 
		left join [App].[tblCatalogosGenerales] estatus with (nolock) on estatus.IDCatalogoGeneral = estatusPosiciones.IDEstatus and estatus.IDTipoCatalogo = @IDTipoCatalogoEstatusPosiciones

	select 
		estatus.IDEstatus
		,estatus.Estatus
        ,estatus.ConfiguracionStatus
		,Count(*) as Total
	from @tempPosiciones p
		left join #tempEstatusPosiciones estatus on estatus.IDPosicion = p.IDPosicion and estatus.[ROW] = 1        
	group by 
		estatus.IDEstatus
		,estatus.Estatus
        ,estatus.ConfiguracionStatus
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spBuscarTotalContradosDelMesActual](
	@IDCliente	int = 0	
	,@IDUsuario	int = 0
    ,@Filtro varchar(255) = null
    ,@IDReferencia int   = null
) as
	SET FMTONLY OFF;  
	
	declare
		@IDTipoCatalogoEstatusPosiciones int = 5
		,@IDTipoCatalogoEstatusPlazas int = 4
		,@IDIdioma varchar(20)
        ,@IDOrganigrama int
		,@FechaInicioMes date
		,@FechaFinMes date
		,@ID_ESTATUS_POSICION_OCUPADA int = 3
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');

	IF OBJECT_ID('tempdb..#TempPosiciones') IS NOT NULL DROP TABLE #TempPosiciones
	IF OBJECT_ID('tempdb..#tempEstatusPosiciones') IS NOT NULL DROP TABLE #tempEstatusPosiciones

	
	SELECT 
		@FechaInicioMes = DATEADD(month, DATEDIFF(month, 0, getdate()), 0),
		@FechaFinMes = DATEADD(day, -1, DATEADD(month, 1, DATEADD(month, DATEDIFF(month, 0, getdate()), 0) ) ) 

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
	where estatusPosiciones.IDEstatus = @ID_ESTATUS_POSICION_OCUPADA
		and cast(estatusPosiciones.FechaReg as date) between @FechaInicioMes and  @FechaFinMes
		and isnull(estatusPosiciones.ContratoDesdeReclutamiento, 0) = 1

	if exists(select top 1 1 from #tempEstatusPosiciones)
	begin
		select 
			estatus.IDEstatus
			,estatus.Estatus
			,estatus.ConfiguracionStatus
			,Count(*) as Total
		from @tempPosiciones p
			join #tempEstatusPosiciones estatus on estatus.IDPosicion = p.IDPosicion-- and estatus.[ROW] = 1        
		group by 
			estatus.IDEstatus
			,estatus.Estatus
			,estatus.ConfiguracionStatus

	end else
	begin
		select 
			0 IDEstatus
			,'' Estatus
			,'' ConfiguracionStatus
			,0 Total
	end
GO

USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [RH].[spActualizarTotalesPosiciones](
	@IDPlaza int,
	@IDUsuario int
) as
    SET ANSI_WARNINGS ON;
	declare
		@IDTipoCatalogoEstatusPosiciones int = 5
	;

	if OBJECT_ID('tempdb..#tempPosicionesStats') is not null drop table #tempPosicionesStats;

	declare @tempPosiciones as table (
		IDPosicion int,
		IDPlaza int
	)

	declare @tempEstatusPosiciones as table (
		IDEstatusPosicion int,
		IDPosicion int,
		IDEstatus int,
		[ROW] int
	)

	insert @tempPosiciones
	select 
		p.IDPosicion
		,p.IDPlaza
	from [RH].[tblCatPosiciones] p with (nolock)
		join [RH].[tblCatPlazas] plazas with (nolock) on plazas.IDPlaza = p.IDPlaza
		join [RH].[tblCatClientes] c with (nolock) on c.IDCliente = p.IDCliente
	where (p.IDPlaza = @IDPlaza or isnull(@IDPlaza, 0) = 0)

	insert @tempEstatusPosiciones
	select 
		isnull(estatusPosiciones.IDEstatusPosicion,0) AS IDEstatusPosicion
		,posiciones.IDPosicion
		,isnull(estatusPosiciones.IDEstatus,0) AS IDEstatus
		,ROW_NUMBER()over(partition by posiciones.IDPosicion 
							ORDER by posiciones.IDPosicion, estatusPosiciones.FechaReg  desc) as [ROW]
	from @tempPosiciones posiciones
		left join RH.tblEstatusPosiciones estatusPosiciones on estatusPosiciones.IDPosicion = posiciones.IDPosicion 
		left join [App].[tblCatalogosGenerales] estatus with (nolock) 
			on estatus.IDCatalogoGeneral = estatusPosiciones.IDEstatus and estatus.IDTipoCatalogo = @IDTipoCatalogoEstatusPosiciones

	select 
		p.IDPosicion
		,p.IDPlaza
		,estatus.IDEstatusPosicion 
		,estatus.IDEstatus
	INTO #tempPosicionesStats
	from @tempPosiciones p
		left join @tempEstatusPosiciones estatus on estatus.IDPosicion = p.IDPosicion and estatus.[ROW] = 1

	update plaza
		set 
			plaza.TotalPosiciones = tblTotales.Total,
			plaza.PosicionesDisponibles = tblTotales.Disponibles,
			plaza.PosicionesOcupadas = tblTotales.TotalOcupadas,
            plaza.PosicionesCanceladas=tblTotales.Canceladas
	from RH.tblCatPlazas as plaza with(nolock)
		join (
			select 
				IDPlaza,
				count(*) as Total,
				SUM(case when IDEstatus = 3 then 1 else 0 end) as TotalOcupadas,
				SUM(case when IDEstatus = 2 then 1 else 0 end) as Disponibles,
                SUM(case when IDEstatus = 4 then 1 else 0 end) as Canceladas
			from #tempPosicionesStats
			where IDEstatus in (2,3,4)
			group by IDPlaza
		) as tblTotales on tblTotales.IDPlaza = plaza.IDPlaza
GO

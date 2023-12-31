USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [RH].[spActualizarTotalesPosiciones](
	@IDPlaza int,
	@IDUsuario int
) as
	declare
		@IDTipoCatalogoEstatusPosiciones int = 5
	;

	if OBJECT_ID('tempdb..#tempPosicionesStats') is not null drop table #tempPosicionesStats;

	declare @tempPosiciones as table (
		IDPosicion int,
		IDPlaza int
		--CodigoPlaza App.SMName,
		--Plaza App.MDName,
		--IDCliente int,
		--Cliente App.XLName,
		--Codigo App.SMName,
		--IDEmpleado		int,
		--ParentId		int
	)

	declare @tempEstatusPosiciones as table (
		IDEstatusPosicion int,
		IDPosicion int,
		IDEstatus int,
		--Estatus varchar(255),
		--DisponibleDesde date,
		--DisponibleHasta date,
		--IDUsuarioReclutador int,
		--IDUsuario int,
		--FechaReg datetime,
		[ROW] int
	)

	insert @tempPosiciones
	select 
		p.IDPosicion
		,p.IDPlaza
		--,plazas.Codigo as CodigoPlaza
		--,plazas.Nombre as Plaza
		--,p.IDCliente
		--,c.NombreComercial as Cliente
		--,p.Codigo
		--,p.IDEmpleado
		--,p.ParentId
	from [RH].[tblCatPosiciones] p with (nolock)
		join [RH].[tblCatPlazas] plazas with (nolock) on plazas.IDPlaza = p.IDPlaza
		join [RH].[tblCatClientes] c with (nolock) on c.IDCliente = p.IDCliente
	where (p.IDPlaza		= @IDPlaza		or isnull(@IDPlaza, 0)		= 0)

	insert @tempEstatusPosiciones
	select 
		isnull(estatusPosiciones.IDEstatusPosicion,0) AS IDEstatusPosicion
		,posiciones.IDPosicion
		,isnull(estatusPosiciones.IDEstatus,0) AS IDEstatus
		--,isnull(estatus.Catalogo,'Sin estatus') AS Estatus
		--,isnull(estatusPosiciones.DisponibleDesde, '1990-01-01') as DisponibleDesde
		--,isnull(estatusPosiciones.DisponibleHasta, '1990-01-01') as DisponibleHasta
		--,isnull(estatusPosiciones.IDUsuarioReclutador,0) as IDUsuarioReclutador
		--,isnull(estatusPosiciones.IDUsuario,0) as IDUsuario
		--,isnull(estatusPosiciones.FechaReg,'1990-01-01') FechaReg
		,ROW_NUMBER()over(partition by posiciones.IDPosicion 
							ORDER by posiciones.IDPosicion, estatusPosiciones.FechaReg  desc) as [ROW]
	from @tempPosiciones posiciones
		left join RH.tblEstatusPosiciones estatusPosiciones on estatusPosiciones.IDPosicion = posiciones.IDPosicion 
		left join [App].[tblCatalogosGenerales] estatus with (nolock) 
			on estatus.IDCatalogoGeneral = estatusPosiciones.IDEstatus and estatus.IDTipoCatalogo = @IDTipoCatalogoEstatusPosiciones

	
	select 
		p.IDPosicion
		,p.IDPlaza
		--,p.CodigoPlaza
		--,p.Plaza
		--,p.IDCliente
		--,p.Cliente
		--,p.Codigo
		--,p.ParentId
		,estatus.IDEstatusPosicion 
		,estatus.IDEstatus
		--,estatus.Estatus
		--,estatus.IDUsuario 
		--,estatus.FechaReg as FechaRegEstatus
	INTO #tempPosicionesStats
	from @tempPosiciones p
		left join @tempEstatusPosiciones estatus on estatus.IDPosicion = p.IDPosicion and estatus.[ROW] = 1


	update plaza
		set 
			plaza.TotalPosiciones = tblTotales.Total,
			plaza.PosicionesDisponibles = tblTotales.Disponibles,
			plaza.PosicionesOcupadas = tblTotales.TotalOcupadas
	from RH.tblCatPlazas as plaza with(nolock)
		join (
			select 
				IDPlaza,
				count(*) as Total,
				SUM(case when IDEstatus = 3 then 1 else 0 end) as TotalOcupadas,
				SUM(case when IDEstatus = 2 then 1 else 0 end) as Disponibles
			from #tempPosicionesStats
			group by IDPlaza
		) as tblTotales on tblTotales.IDPlaza = plaza.IDPlaza
GO

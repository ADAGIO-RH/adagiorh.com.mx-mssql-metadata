USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spBuscarConfiguracionesPlaza] (
	@IDConfiguracionPlaza int = 0,
	@IDPlaza int = 0,
	@IDUsuario int
) as
	select 
		isnull(plaza.IDConfiguracionPlaza,0) as IDConfiguracionPlaza
		,ctcp.IDTipoConfiguracionPlaza
		,ctcp.Nombre as TipoConfiguracionPlaza
		,@IDPlaza as IDPlaza
		,plaza.Valor
		,ctcp.Configuracion
		,isnull(ctcp.Orden, 0) Orden
        ,ctcp.Filtro
	from [RH].[tblCatTiposConfiguracionesPlazas] ctcp with (nolock)		
		left join (
			select 
				p.IDPlaza,
				cp.IDConfiguracionPlaza,
				cp.IDTipoConfiguracionPlaza,
				cp.Valor
			from [RH].[tblCatPlazas] p with (nolock)
				left join [RH].[tblConfiguracionesPlazas] cp with (nolock) on cp.IDPlaza = p.IDPlaza
			where  (p.IDPlaza = @IDPlaza)
				and (cp.IDConfiguracionPlaza = @IDConfiguracionPlaza or ISNULL(@IDConfiguracionPlaza, 0) = 0)
		) as plaza on plaza.IDTipoConfiguracionPlaza = ctcp.IDTipoConfiguracionPlaza

	where ISNULL(ctcp.Disponible, 0) = 1
		--and (cp.IDPlaza = @IDPlaza or ISNULL(@IDPlaza, 0) = 0)
	order by isnull(ctcp.Orden, 0)
GO

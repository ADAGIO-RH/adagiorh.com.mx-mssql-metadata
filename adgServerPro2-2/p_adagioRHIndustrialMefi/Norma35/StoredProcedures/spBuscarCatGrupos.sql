USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Norma35].[spBuscarCatGrupos](
	@IDCatGrupo int = 0 
	,@IDCatTipoGrupo int = 0  
	,@TipoReferencia int = 0  
	,@IDReferencia int = 0  
	,@IDUsuario int  
) as
	select 
		 cg.IDCatGrupo
		,cg.Nombre
		,cg.IDCatTipoGrupo
		,cg.TipoReferencia
		,cg.IDReferencia
		,isnull(cg.RespuestaGrupo,0) as RespuestaGrupo
		,isnull(cg.Orden,0) as Orden
		,cg.uuid
		,cg.uuidDependencia
		,cg.Nota
	from [Norma35].[tblCatGrupos] cg with (nolock)
		join [Norma35].[tblCatTiposGrupos] ctg with (nolock) on ctg.IDCatTipoGrupo = cg.IDCatTipoGrupo
	 where (cg.IDCatGrupo = @IDCatGrupo) or (   
		(cg.TipoReferencia = @TipoReferencia /* or @TipoReferencia = 0 */) and   
		(cg.IDReferencia = @IDReferencia /* or @IDReferencia = 0 */) )  
	order by cg.Orden asc
GO

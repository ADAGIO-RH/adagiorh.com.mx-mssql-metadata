USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBuscarEncargadosProyectos](
	@IDEncargadoProyecto int = 0
	,@IDProyecto int = 0
	)
as
	select 
		 ep.IDEncargadoProyecto
		,ep.IDProyecto
		,ep.IDCatalogoGeneral
		,cg.Catalogo
		,ep.Nombre
		,ep.Email 
	from [Evaluacion360].[tblEncargadosProyectos] ep
		join [App].[tblCatalogosGenerales] cg on ep.IDCatalogoGeneral = cg.IDCatalogoGeneral and IDTipoCatalogo = 1
	where (ep.IDEncargadoProyecto = @IDEncargadoProyecto or @IDEncargadoProyecto = 0)
		and (ep.IDProyecto = @IDProyecto or @IDProyecto = 0)
GO

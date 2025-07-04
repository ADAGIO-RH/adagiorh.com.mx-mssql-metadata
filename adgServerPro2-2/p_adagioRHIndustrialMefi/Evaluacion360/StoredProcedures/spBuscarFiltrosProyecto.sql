USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Evaluacion360].[spBuscarFiltrosProyecto](
	@IDFiltroProyecto int = 0
	,@IDProyecto int = 0 
) as
	select 
		IDFiltroProyecto
		,IDProyecto
		,TipoFiltro
		,ID
		,Descripcion
	from [Evaluacion360].[tblFiltrosProyectos]
	where (IDFiltroProyecto = @IDFiltroProyecto or @IDFiltroProyecto = 0) and (IDProyecto = @IDProyecto or @IDProyecto = 0)
GO

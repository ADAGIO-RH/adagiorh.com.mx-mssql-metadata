USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBuscarEscalasValoracionesProyecto](
	@IDEscalaValoracionProyecto int = 0
	,@IDProyecto int = 0
	,@IDUsuario int
) as

	declare @orderAsc bit = 0;

	select 
		evp.IDEscalaValoracionProyecto
		,evp.IDProyecto
		,evp.Nombre
		,evp.Descripcion
		,isnull(evp.Valor,0) as Valor
	from [Evaluacion360].[tblEscalasValoracionesProyectos] evp
	where (evp.IDEscalaValoracionProyecto = @IDEscalaValoracionProyecto or @IDEscalaValoracionProyecto = 0)
		and (evp.IDProyecto = @IDProyecto or @IDProyecto = 0)
	ORDER BY
	  CASE @orderAsc WHEN 1 THEN isnull(evp.Valor,0) ELSE '' END ASC,
	  CASE @orderAsc WHEN 0 THEN isnull(evp.Valor,0) ELSE '' END DESC
GO

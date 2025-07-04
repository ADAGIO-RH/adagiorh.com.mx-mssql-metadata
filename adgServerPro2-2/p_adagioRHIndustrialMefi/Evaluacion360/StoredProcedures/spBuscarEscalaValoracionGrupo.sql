USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBuscarEscalaValoracionGrupo](
	@IDEscalaValoracionGrupo	int = 0
	,@IDGrupo int = 0
) as
	declare @orderAsc bit = 0;

	select 
	IDEscalaValoracionGrupo
	,IDGrupo
	,Nombre
	,Descripcion
	,isnull(Valor,0) Valor
	from [Evaluacion360].[tblEscalasValoracionesGrupos]
	where (IDEscalaValoracionGrupo = @IDEscalaValoracionGrupo or @IDEscalaValoracionGrupo = 0) and 
		(IDGrupo = @IDGrupo or @IDGrupo = 0)
ORDER BY
	  CASE @orderAsc WHEN 1 THEN isnull(Valor,0) ELSE '' END ASC,
	  CASE @orderAsc WHEN 0 THEN isnull(Valor,0) ELSE '' END DESC
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Reclutamiento].[spBuscarCatTipoPreguntasFiltro](
	@IDTipoPreguntaFiltro int = null
)
AS
BEGIN
	select 
		IDTipoPreguntaFiltro
		,Descripcion
		,Component
		,InputType
	from Reclutamiento.tblCatTipoPreguntaFiltro with(nolock)
	where IDTipoPreguntaFiltro = @IDTipoPreguntaFiltro or isnull(@IDTipoPreguntaFiltro,0) = 0
	order by Descripcion asc
END
GO

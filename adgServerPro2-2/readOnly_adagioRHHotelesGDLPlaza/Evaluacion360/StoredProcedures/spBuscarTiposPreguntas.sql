USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca Tipos de Preguntas
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-09-25
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Evaluacion360].[spBuscarTiposPreguntas](
	@IDTipoPregunta int  = 0
) as
	select tp.IDTipoPregunta
		,tp.TipoPregunta
		,tp.Descripcion
		,isnull(tp.TiempoEstimadoRespuesta,0) as TiempoEstimadoRespuesta
		,isnull(tp.IDUnidadDeTiempo,0) as IDUnidadDeTiempo
		,u.Nombre as UnidadTiempo
		,tp.IDTemplate
		,tp.IDTemplateEdicion
		,tp.CssClass
	from [Evaluacion360].[tblCatTiposDePreguntas] tp
		left join App.[tblCatUnidadesDeTiempo] u on tp.IDUnidadDeTiempo = u.IDUnidadDeTiempo
	where tp.IDTipoPregunta = @IDTipoPregunta or (@IDTipoPregunta=0)
	order by tp.TipoPregunta asc
GO

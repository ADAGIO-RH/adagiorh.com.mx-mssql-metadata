USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Busca Tipos de Preguntas  
** Autor   : Aneudy Abreu  
** Email   : aneudy.abreu@adagio.com.mx  
** FechaCreacion : 2020-06-01
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
***************************************************************************************************/  
CREATE proc [Salud].[spBuscarTiposPreguntas](  
	@IDTipoPregunta int  = 0  
) as  
	select tp.IDTipoPregunta  
		,tp.TipoPregunta  
		,tp.Descripcion  
		,isnull(tp.TiempoEstimadoRespuesta,0) as TiempoEstimadoRespuesta  
		,isnull(tp.IDUnidadDeTiempo,0) as IDUnidadDeTiempo  
		,u.Nombre as UnidadTiempo  
		,tp.IDTemplateEdicion  
		,tp.CssClass  
	from [Salud].[tblTiposDePreguntas] tp  
		left join App.[tblCatUnidadesDeTiempo] u on tp.IDUnidadDeTiempo = u.IDUnidadDeTiempo  
	where tp.IDTipoPregunta = @IDTipoPregunta or (@IDTipoPregunta=0)  
	and IDTipoPregunta in (1,2)
	order by tp.TipoPregunta asc
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar Preguntas
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-09-26
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
create proc [Salud].[spBuscarPreguntas](
	@IDPregunta int = 0
	,@IDSeccion int = 0
) as
	
	select p.IDPregunta
		,p.IDTipoPregunta
		,tp.TipoPregunta
		,p.IDSeccion
		,s.Nombre as Seccion
		,p.Descripcion
		,p.Calificar
		,rp.Respuesta
	from [Salud].[tblPreguntas] p with (nolock)
		join [Salud].[tblTiposDePreguntas] tp with (nolock) on p.IDTipoPregunta = tp.IDTipoPregunta
		join [Salud].[tblSecciones] s with (nolock) on p.IDSeccion = s.IDSeccion
		left join [Salud].[tblRespuestasPreguntas] rp with (nolock) on  rp.IDPregunta = p.IDPregunta
	where (p.IDPregunta = @IDPregunta or @IDPregunta = 0) and (p.IDSeccion = @IDSeccion or @IDSeccion = 0) 
	order by p.Descripcion asc

	exec [Salud].[spBuscarPosiblesRespuestasPreguntas] @IDPregunta = @IDPregunta
GO

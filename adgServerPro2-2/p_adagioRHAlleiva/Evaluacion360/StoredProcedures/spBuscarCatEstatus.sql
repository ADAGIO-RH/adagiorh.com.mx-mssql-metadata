USE [p_adagioRHAlleiva]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar Estatus
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
CREATE proc [Evaluacion360].[spBuscarCatEstatus](
	@IDEstatus int = 0
	,@IDTipoEstatus int = 0
	,@IDUsuario int
) as

	select 
		 e.IDEstatus
		,e.IDTipoEstatus
		,te.TipoEstatus
		,e.Estatus
		,e.Color
		,e.Icono
		,isnull(e.TotalEvaluaciones, 0) as TotalEvaluaciones
	from [Evaluacion360].[tblCatEstatus] e
		join [Evaluacion360].[tblCatTiposEstatus] te on e.IDTipoEstatus = te.IDTipoEstatus
	where (IDEstatus = @IDEstatus or isnull(@IDEstatus, 0) = 0)
		and (te.IDTipoEstatus = @IDTipoEstatus or isnull(@IDTipoEstatus, 0) = 0)
GO

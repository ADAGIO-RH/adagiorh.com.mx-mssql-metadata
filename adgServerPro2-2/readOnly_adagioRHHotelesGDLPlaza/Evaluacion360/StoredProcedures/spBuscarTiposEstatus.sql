USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca Tipos de estatus
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
CREATE proc [Evaluacion360].[spBuscarTiposEstatus](
	@IDTipoEstatus int = 0
) as
	select 
	IDTipoEstatus
	,TipoEstatus
	from [Evaluacion360].[tblCatTiposEstatus]
	where IDTipoEstatus = @IDTipoEstatus or (@IDTipoEstatus = 0)
GO

USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca Tipos de relaciones
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
CREATE proc [Evaluacion360].[spBuscarTiposRelaciones](
	@IDTipoRelacion int = 0
 ) as
 begin
	select 
	IDTipoRelacion
	,Codigo
	,Relacion
	from [Evaluacion360].[tblCatTiposRelaciones]
	where (IDTipoRelacion = @IDTipoRelacion or @IDTipoRelacion = 0)

 end;
GO

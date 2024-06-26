USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 /**************************************************************************************************** 
** Descripción		: Buscar catálogo de Parentescos o un registro específico
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-06-08
** Paremetros		: @IDParentesco int = 0              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [RH].[spBuscarCatParentesco](
    @IDParentesco int = 0
)
as
    select 
	   IDParentesco
	   ,Descripcion
    from  [RH].[TblCatParentescos]
    where (IDParentesco = @IDParentesco or @IDParentesco = 0)
GO

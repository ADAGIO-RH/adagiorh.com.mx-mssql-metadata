USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Procedure para Buscar el Catálogo de Afores>
** Autor			: <Jose Rafael Roman Gil>
** Email			: <jose.roman@adagio.com.mx>
** FechaCreacion	: <11/06/2018>
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
0000-00-00		    NombreCompleto		    ¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE [RH].[spBuscarCatAfores]
(
	@IDAfore int = 0
)
AS
BEGIN
	SELECT IDAfore,
		   Descripcion,
		   ROW_NUMBER()over(ORDER BY IDAfore)as ROWNUMBER
	FROM RH.tblCatAfores
	Where (IDAfore = @IDAfore OR isnull(@IDAfore,0) = 0)
END
GO

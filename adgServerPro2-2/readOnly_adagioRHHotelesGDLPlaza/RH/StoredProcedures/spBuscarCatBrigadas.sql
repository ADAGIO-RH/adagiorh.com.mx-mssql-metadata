USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Procedure para Buscar el Catálogo de Brigadas>
** Autor			: <Jose Rafael Roman Gil>
** Email			: <jose.roman@adagio.com.mx>
** FechaCreacion	: <08/06/2018>
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
0000-00-00		    NombreCompleto		    ¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE [RH].[spBuscarCatBrigadas]
(
	@IDBrigada int = 0
)
AS
BEGIN
	SELECT IDBrigada,
		   Descripcion,
		   ROW_NUMBER()over(ORDER BY IDBrigada)as ROWNUMBER
	FROM RH.tblCatBrigadas
	Where (IDBrigada = @IDBrigada OR isnull(@IDBrigada,0) = 0)
END
GO

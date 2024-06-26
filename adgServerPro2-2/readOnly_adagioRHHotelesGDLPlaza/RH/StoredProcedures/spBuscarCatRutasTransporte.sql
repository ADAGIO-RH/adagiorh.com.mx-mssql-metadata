USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Procedure para Buscar el Catálogo de Rutas de Transporte>
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
CREATE PROCEDURE RH.spBuscarCatRutasTransporte
(
	@IDRuta int = 0
)
AS
BEGIN
	SELECT IDRuta,
		   Descripcion,
		   ROW_NUMBER()over(ORDER BY IDRuta)as ROWNUMBER
	FROM RH.tblCatRutasTransporte
	Where (IDRuta = @IDRuta OR isnull(@IDRuta,0) = 0)
END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Procedimiento para buscar los tipos de movimiento de los creditos Infonavit
** Autor			: Jose Roman
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-09-06
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE RH.spBuscarInfonavitTipoMovimiento
(
	@IDTipoMovimiento int = 0
)
AS
BEGIN
	
		SELECT
			IDTipoMovimiento
			,Codigo
			,Descripcion 
		FROM RH.tblCatInfonavitTipoMovimiento
		WHERE (IDTipoMovimiento = @IDTipoMovimiento) OR (@IDTipoMovimiento = 0)

END
GO

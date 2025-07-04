USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Procedimiento para buscar los tipos de Descuento de los creditos Infonavit
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
CREATE PROCEDURE RH.spBuscarInfonavitTipoDescuento
(
	@IDTipoDescuento int = 0
)
AS
BEGIN
	
		SELECT
			IDTipoDescuento
			,Codigo
			,Descripcion
		FROM RH.tblCatInfonavitTipoDescuento
		WHERE (IDTipoDescuento = @IDTipoDescuento) OR (@IDTipoDescuento = 0)

END
GO

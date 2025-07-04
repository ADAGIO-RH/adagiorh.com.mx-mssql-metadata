USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Procedimiento para Buscar los Estatus para los finiquitos
** Autor			: Jose Roman
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 14-08-2018
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE Nomina.spBuscarEstatusFiniquitos
AS
BEGIN
	SELECT 
		IDEStatusFiniquito
		,Descripcion
	FROM Nomina.tblcatEstatusFiniquito
END
GO

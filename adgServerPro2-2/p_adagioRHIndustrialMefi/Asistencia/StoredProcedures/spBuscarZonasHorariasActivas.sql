USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA OBTENER LAS ZONAS HORARIAS ACTIVAS
** Autor			: JOSE ROMAN
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-09-19
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE Asistencia.spBuscarZonasHorariasActivas
AS
BEGIN
	SELECT 
		 ID as IDZonaHoraria
		,Name as ZonaHoraria 
		,ISNULL(Active,0) as Active 
		,ROW_NUMBER()OVER(ORDER BY ID asc) ROWNUMBER 
	from Tzdb.Zones
	WHERE ISNULL(Active,0) = 1
END
GO

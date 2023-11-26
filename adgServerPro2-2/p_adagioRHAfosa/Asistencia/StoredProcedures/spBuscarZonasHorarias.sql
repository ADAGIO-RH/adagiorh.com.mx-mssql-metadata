USE [p_adagioRHAfosa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA OBTENER LAS ZONAS HORARIAS
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

CREATE PROCEDURE Asistencia.spBuscarZonasHorarias
(
	@IDZonaHoraria int = 0
)
AS
BEGIN
	SELECT 
		 ID as IDZonaHoraria
		,Name as ZonaHoraria 
		,ISNULL(Active,0) as Active
		,ROW_NUMBER()OVER(ORDER BY ID ASC) as ROWNUMBER 
	from Tzdb.Zones
	WHERE ((ID = @IDZonaHoraria) OR (ISNULL(@IDZonaHoraria,0) = 0))
END
GO

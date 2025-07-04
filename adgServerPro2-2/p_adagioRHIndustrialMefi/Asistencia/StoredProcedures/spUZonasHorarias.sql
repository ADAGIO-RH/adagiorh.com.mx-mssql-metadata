USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA ACTIVAR/ DESACTIVAR LAS ZONAS HORARIAS
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

CREATE PROCEDURE Asistencia.spUZonasHorarias 
(
	@IDZonaHoraria int,
	@Activo bit,
	@IDUsuario int 
)
AS
BEGIN

	UPDATE Tzdb.Zones
		set Active = @Activo
	WHERE ID = @IDZonaHoraria


EXEC Asistencia.spBuscarZonasHorarias @IDZonaHoraria
END
GO

USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA OBTENER LOS TIPOS DE CHECADAS
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

CREATE PROCEDURE Asistencia.spBuscarTiposChecadas
(
	@IDTipoChecada Varchar(10) = NULL
)
AS
BEGIN
	SELECT 
		IDTipoChecada
		,TipoChecada 
		,isnull(Activo,0) as Activo 
		,ROW_NUMBER()OVER(ORDER BY IDTipoChecada ASC) as ROWNUMBER
	from Asistencia.tblCatTiposChecadas
	WHERE ((IDTipoChecada = @IDTipoChecada) OR (@IDTipoChecada IS NULL))
END
GO

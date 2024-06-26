USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA OBTENER LOS TIPOS DE LECTORES
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

CREATE PROCEDURE Asistencia.spBuscarTiposLectores 
(
	@IDTipoLector Nvarchar(100) = NULL
)
AS
BEGIN
	SELECT 
		IDTipoLector
		,TipoLector
		,ROW_NUMBER()OVER(ORDER BY IDTipoLector asc) ROWNUMBER 
	from Asistencia.tblCatTiposLectores
	WHERE ((IDTipoLector = @IDTipoLector) OR (@IDTipoLector IS NULL))
END
GO

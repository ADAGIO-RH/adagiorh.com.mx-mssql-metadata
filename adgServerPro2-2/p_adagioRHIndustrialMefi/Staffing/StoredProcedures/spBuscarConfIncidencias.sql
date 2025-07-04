USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca configuración de incidencias
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-10-12
** Paremetros		: @IDUsuario			- Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROCEDURE [Staffing].[spBuscarConfIncidencias](
	@IDUsuario	  INT = 0)
AS
BEGIN
	
	SELECT C.IDConf 
		   , I.IDIncidencia
		   , I.Descripcion
		   , ISNULL(C.AliasColumna, '') AS AliasColumna
		   , ISNULL(C.Orden, 0) AS Orden
		   , ISNULL(Activo, 0) AS Activo
		   , ISNULL(I.EsAusentismo, 0) AS EsAusentismo
		   , ISNULL(I.GoceSueldo, 0) AS GoceSueldo
	FROM [Asistencia].[tblCatIncidencias] I
		JOIN [Staffing].[tblConfIncidencias] C ON I.IDIncidencia = C.IDIncidencia	
	ORDER BY C.Orden, I.IDIncidencia	

END
GO

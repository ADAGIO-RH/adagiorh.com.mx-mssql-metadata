USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtiene las aplicaciones que tienen metricas o indicadores anclados
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-05-18
** Paremetros		: 
** Issues			: 297

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [App].[spBuscarAplicacionesAncladasDashboard]
AS
	BEGIN
		
		SELECT IDAplicacion
		FROM (
			SELECT A.IDAplicacion
			FROM [App].[tblCatAplicaciones] A
				INNER JOIN [InfoDir].[tblCatMetricas] M ON A.IDAplicacion = M.IDAplicacion
			UNION
			SELECT A.IDAplicacion
			FROM [App].[tblCatAplicaciones] A
				INNER JOIN [InfoDir].[tblCatIndicadores] I ON A.IDAplicacion = I.IDAplicacion
		) AS tblAplicaciones
		GROUP BY IDAplicacion;

	END
GO

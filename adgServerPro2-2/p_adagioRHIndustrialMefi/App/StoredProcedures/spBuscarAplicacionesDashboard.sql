USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtiene las aplicaciones que tienen metricas, indicadores o kpi configurados
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-04-28
** Paremetros		: 
** IDAzure			: 821

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [App].[spBuscarAplicacionesDashboard]
AS
	BEGIN
		
		SELECT A.IDAplicacion
		FROM [App].[tblCatAplicaciones] A
			INNER JOIN [InfoDir].[tblCatItems] I ON A.IDAplicacion = I.IDAplicacion
		GROUP BY A.IDAplicacion

	END
GO

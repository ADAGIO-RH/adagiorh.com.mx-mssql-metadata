USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Regresa las metricas ancladas
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-04-07
** Parametros		: 
** IDAzure			: 821

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [InfoDir].[spRMetricas]
(
	@IDAplicacion VARCHAR(400) = ''
)
AS
	BEGIN		
		
		DECLARE @Activo BIT = 1;
		DECLARE @Personalizado INT = 1;

		SELECT M.IDMetrica,
			   M.IDAplicacion,
			   M.Nombre,
			   M.Descripcion,
			   M.ConfiguracionFiltros,
			   M.NombreProcedure,
			   M.Background,
			   M.Color,
			   M.IsKpi,
			   M.Objetivo,
			   P.Descripcion AS Periodo,
			   CASE
					WHEN M.IDPeriodo = @Personalizado
						THEN '(' + CAST(M.FechaDe AS VARCHAR(10)) + ' - ' + CAST(M.FechaHasta AS VARCHAR(10)) + ')'
						ELSE ''
					END
			    AS FechasPersonalizadas			  
		FROM [InfoDir].[tblCatMetricas] M
			INNER JOIN [InfoDir].[tblCatPeriodos] P ON M.IDPeriodo = P.IDPeriodo
		WHERE M.IDAplicacion = @IDAplicacion

	END
GO

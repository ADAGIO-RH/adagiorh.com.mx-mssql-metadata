USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Regresa los indicadores anclados
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-05-09
** Parametros		: 
** IDAzure			: 821

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [InfoDir].[spRIndicadores]
(
	@IDAplicacion VARCHAR(400) = ''
)
AS
	BEGIN		
		
		DECLARE @Activo BIT = 1;
		DECLARE @Personalizado INT = 1;

		SELECT I.IDIndicador,
			   I.IDAplicacion,
			   I.Nombre,
			   I.Descripcion,
			   I.ConfiguracionFiltros,
			   I.ConfiguracionGroupBy,
			   I.NombreProcedure,
			   I.IDPeriodo,
			   I.IDGrafica,
			   G.TipoGrafica,
			   P.Descripcion AS Periodo,
			   CASE
					WHEN I.IDPeriodo = @Personalizado
						THEN '(' + CAST(I.FechaDe AS VARCHAR(10)) + ' - ' + CAST(I.FechaHasta AS VARCHAR(10)) + ')'
						ELSE ''
					END
			    AS FechasPersonalizadas
		FROM [InfoDir].[tblCatIndicadores] I
			JOIN [InfoDir].[tblCatPeriodos] P ON I.IDPeriodo = P.IDPeriodo
			JOIN [InfoDir].[tblCatGraficas] G ON I.IDGrafica = G.IDGrafica
		WHERE I.IDAplicacion = @IDAplicacion

	END
GO

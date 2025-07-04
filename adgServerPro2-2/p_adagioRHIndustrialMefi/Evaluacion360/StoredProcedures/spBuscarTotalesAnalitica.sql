USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar totales en evaluación
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-10-30
** Paremetros		: @IDProyecto			- Identificador del proyecto.
					  @IDUsuario			- Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROCEDURE [Evaluacion360].[spBuscarTotalesAnalitica](
	@IDProyecto		INT = 0
	, @IDUsuario	INT = 0
)
AS
	BEGIN	
		
		SELECT ISNULL(TotalPruebasARealizar, 0) AS TotalPruebasARealizar
				, ISNULL(TotalPruebasRealizadas, 0) AS TotalPruebasRealizadas
				, ISNULL(Progreso, 0) AS Progreso
		FROM [Evaluacion360].[tblCatProyectos]
		WHERE IDProyecto = @IDProyecto	

	END
GO

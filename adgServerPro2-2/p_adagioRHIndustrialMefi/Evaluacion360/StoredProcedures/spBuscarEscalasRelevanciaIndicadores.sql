USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca la escala de relevancia indicadores en clima laboral
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-08-09
** Paremetros		: @IDProyecto		- Identificador del proyecto.
**					  @IDUsuario			- Identificador del usuario.	
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROCEDURE [Evaluacion360].[spBuscarEscalasRelevanciaIndicadores](
	@IDProyecto	INT = NULL
	, @IDUsuario	  INT
)
AS
BEGIN
	
	SELECT ERI.IDEscalaRelevancia
		   , ERI.Descripcion
		   , ERI.[Min]
		   , ERI.[Max]
		   , ERI.IndiceRelevancia
		   , ERI.IDProyecto
	FROM [Evaluacion360].[tblEscalaRelevanciaIndicadores] ERI
	WHERE IDProyecto = @IDProyecto

END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca la escala de satisfaccion general en clima laboral
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-08-09
** Paremetros		: @IDProyecto		- Identificador del proyecto.
**					: @IDUsuario		- Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE   PROCEDURE [Evaluacion360].[spBuscarEscalasDeSatisfaccionGeneral](
	@IDProyecto	INT = NULL
	, @IDUsuario	  INT
)
AS
BEGIN
	
	SELECT ESG.IDEscalaSatisfaccion
		   , ESG.Nombre
		   , ESG.Descripcion
		   , ESG.[Min] * 100 AS [Min]
		   , ESG.[Max] * 100 AS [Max]
		   , ESG.Color
		   , ESG.IndiceSatisfaccion
		   , ESG.IDProyecto
	FROM [Evaluacion360].[tblEscalaSatisfaccionGeneral] ESG
	WHERE IDProyecto = @IDProyecto
	ORDER BY ESG.IndiceSatisfaccion

END
GO

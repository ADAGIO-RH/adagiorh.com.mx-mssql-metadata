USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtiene las configuraciones del item solicitado
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-04-19
** Paremetros		: @IDTipoItem
** IDAzure			: 814

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [InfoDir].[spBuscarConfiguracionesItem](
	@IDConfItem INT = NULL
)
AS
	BEGIN		
		
		SELECT
			C.ConfFiltrosItem
		FROM [InfoDir].[tblCatItems] C WITH (NOLOCK)
		WHERE C.IDConfItem = @IDConfItem

	END
GO

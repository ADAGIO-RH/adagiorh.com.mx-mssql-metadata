USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Regresa un tipo de item especifico
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-07-20
** Parametros		: @IDAplicacion
** IDAzure			:

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [InfoDir].[spRItemConfiguradoByID]
(
	@IDConfItem INT = 0
)
AS
	BEGIN		

		SELECT I.IDConfItem,
			   I.IDTipoItem,
			   I.IDAplicacion,
			   I.Nombre,
			   I.Descripcion,
			   D.NombreProcedure
		FROM [InfoDir].[tblCatItems] I
			INNER JOIN [InfoDir].[tblCatDataSource] D ON  I.IDDataSource = D.IDDataSource
		WHERE I.IDConfItem = @IDConfItem

	END
GO

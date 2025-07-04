USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Regresa el tipo de item configurado de la aplicación
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-04-22
** Parametros		: @IDAplicacion
** IDAzure			: 823

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [InfoDir].[spRItemsConfigurados]
(
	@IDTipoItem INT = 0,
	@IDAplicacion VARCHAR(100) = ''
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
		WHERE I.IDTipoItem = @IDTipoItem AND
			  I.IDAplicacion = @IDAplicacion

	END
GO

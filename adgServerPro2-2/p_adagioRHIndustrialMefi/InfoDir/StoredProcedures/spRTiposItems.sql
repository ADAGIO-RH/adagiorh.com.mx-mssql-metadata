USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Regresa los tipos de items activos
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-04-12
** Parametros		: 
** IDAzure			: 814

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [InfoDir].[spRTiposItems]
AS
	BEGIN		
		
		DECLARE @Activo BIT = 1;

		SELECT TI.IDTipoItem,
			   TI.Descripcion
		FROM [InfoDir].[tblCatTipoItems] TI
		WHERE TI.IsActive = @Activo

	END
GO

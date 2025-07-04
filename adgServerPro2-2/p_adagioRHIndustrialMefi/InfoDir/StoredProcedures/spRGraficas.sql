USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Regresa las graficas activas
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-05-06
** Parametros		: 
** IDAzure			: 821

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [InfoDir].[spRGraficas]
AS
	BEGIN		
		
		DECLARE @Activo BIT = 1;

		SELECT G.IDGrafica,
			   G.Descripcion,
			   G.TipoGrafica,
			   G.Icon
		FROM [InfoDir].[tblCatGraficas] G
		WHERE G.IsActive = @Activo

	END
GO

USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Regresa las medidas que pueden tener las graficas
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

CREATE PROC [InfoDir].[spRMedidasGraficas]
AS
	BEGIN		
		
		DECLARE @Activo BIT = 1;

		SELECT MG.IDMedida,
			   MG.Descripcion,
			   MG.Medida
		FROM [InfoDir].[tblCatMedidasGraficas] MG
		WHERE MG.IsActive = @Activo

	END
GO

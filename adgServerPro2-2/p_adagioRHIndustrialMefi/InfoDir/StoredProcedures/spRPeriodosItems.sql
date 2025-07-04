USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Regresa los periodos 
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-04-26
** Parametros		: 
** IDAzure			: 821

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [InfoDir].[spRPeriodosItems]
AS
	BEGIN		
		
		DECLARE @Activo BIT = 1;

		SELECT P.IDPeriodo,
			   P.Descripcion
		FROM [InfoDir].[tblCatPeriodos] P
		WHERE P.Activo = @Activo
		ORDER BY OrdenPeriodo ASC

	END
GO

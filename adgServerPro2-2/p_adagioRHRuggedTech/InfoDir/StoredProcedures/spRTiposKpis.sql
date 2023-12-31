USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Regresa los tipos de kpis activos
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-05-02
** Parametros		: 
** IDAzure			: 814

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [InfoDir].[spRTiposKpis]
AS
	BEGIN		
		
		DECLARE @Activo BIT = 1;

		SELECT TK.IDTipoKpi,
			   TK.Tipo
		FROM [InfoDir].[tblCatTiposKpi] TK
		WHERE TK.IsActive = @Activo

	END
GO

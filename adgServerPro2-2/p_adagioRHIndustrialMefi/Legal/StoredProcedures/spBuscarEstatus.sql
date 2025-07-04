USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar estatus del esquema legal
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-01-05
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE PROC [Legal].[spBuscarEstatus]
AS	
	BEGIN		

		SELECT E.IDEstatus,
			   E.Descripcion
		FROM [Legal].[tblCatEstatus] E

	END
GO

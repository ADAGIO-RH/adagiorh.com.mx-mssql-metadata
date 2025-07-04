USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA BUSCAR LOS TIPOS DE PROCESOS
** Autor			: JOSE ROMAN
** Email			: JROMAN@ADAGIO.COM.MX
** FechaCreacion	: 2022-01-12
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE Enrutamiento.spBuscarCatTiposProcesos
AS
BEGIN
	SELECT 
		[IDCatTipoProceso]
		,[Codigo]
	FROM [Enrutamiento].[tblCatTiposProcesos] WITH(NOLOCK)
END
GO

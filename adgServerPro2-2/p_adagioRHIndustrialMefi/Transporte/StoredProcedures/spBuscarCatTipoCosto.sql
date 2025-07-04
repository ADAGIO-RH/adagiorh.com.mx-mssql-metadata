USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx  
** FechaCreacion : 2022-02-15
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
CREATE PROCEDURE [Transporte].[spBuscarCatTipoCosto]
(
	@IDTipoCosto int = null
)
AS
BEGIN
	SELECT  *
	FROM [Transporte].[tblCatTipoCosto] TJ
		
	WHERE (tj.IDTipoCosto = @IDTipoCosto)  or (@IDTipoCosto is null or @IDTipoCosto =0)		
END
GO

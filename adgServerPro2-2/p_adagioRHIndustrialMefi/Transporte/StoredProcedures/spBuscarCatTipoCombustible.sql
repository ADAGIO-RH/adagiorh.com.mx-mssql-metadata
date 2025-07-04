USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx  
** FechaCreacion : 2022-02-14
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/  
CREATE PROCEDURE [Transporte].[spBuscarCatTipoCombustible]
(
	@IDTipoCombustible int = null
)
AS
BEGIN
	SELECT  *
	FROM [Transporte].[tblCatTipoCombustible] TJ
		
	WHERE (tj.IDTipoCombustible = @IDTipoCombustible)  or (@IDTipoCombustible is null or @IDTipoCombustible=0)		
END
GO

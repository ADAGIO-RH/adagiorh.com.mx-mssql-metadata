USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarCatTiposCalculoISR]
(
	@IDCalculo int = null	
)
AS
BEGIN
    select IDCalculo
		,Codigo   
	     ,Descripcion
    from Nomina.tblCatTipoCalculoISR
    where (IDCalculo=@IDCalculo or @IDCalculo is null)
END;
GO

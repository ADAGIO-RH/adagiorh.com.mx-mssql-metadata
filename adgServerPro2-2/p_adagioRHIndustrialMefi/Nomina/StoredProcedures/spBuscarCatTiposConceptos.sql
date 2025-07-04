USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Nomina].[spBuscarCatTiposConceptos]
(
	@IDTipoConcepto int = null	
)
AS
BEGIN
    select IDTipoConcepto   
	     ,Descripcion
    from Nomina.tblCatTipoConcepto
    where (IDTipoConcepto=@IDTipoConcepto or @IDTipoConcepto is null)
    order by IDTipoConcepto asc
END;
GO

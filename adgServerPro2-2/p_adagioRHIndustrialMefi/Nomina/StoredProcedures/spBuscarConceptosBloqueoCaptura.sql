USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE Nomina.spBuscarConceptosBloqueoCaptura
AS
BEGIN
	select distinct c.Codigo, c.Descripcion 
	from Nomina.tblCatConceptos c
		left join Nomina.tblCatTiposPrestamo tp
			on tp.IDConcepto = c.IDConcepto
	where c.Codigo = '144'

	union all
	select distinct c.Codigo, c.Descripcion 
	from Nomina.tblCatConceptos c
		left join Nomina.tblCatTiposPrestamo tp
			on tp.IDConcepto = c.IDConcepto
	where tp.IDConcepto is not null  	
END
GO

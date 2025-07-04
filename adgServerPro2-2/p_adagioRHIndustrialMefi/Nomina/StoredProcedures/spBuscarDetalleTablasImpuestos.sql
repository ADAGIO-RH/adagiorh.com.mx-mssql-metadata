USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROC [Nomina].[spBuscarDetalleTablasImpuestos]
(
    @IDTablaImpuesto int
)

as

select IDDetalleTablaImpuesto
,IDTablaImpuesto
,LimiteInferior
,LimiteSuperior
,CoutaFija
,Porcentaje
from Nomina.tblDetalleTablasImpuestos
where IDTablaImpuesto = @IDTablaImpuesto
order by LimiteInferior asc
GO

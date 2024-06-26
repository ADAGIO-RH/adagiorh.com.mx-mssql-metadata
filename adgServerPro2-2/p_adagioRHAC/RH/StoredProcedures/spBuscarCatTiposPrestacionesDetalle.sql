USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatTiposPrestacionesDetalle]
(
	@IDTipoPrestacion int
)
AS
BEGIN
	SELECT 
	IDTipoPrestacionDetalle
	,IDTipoPrestacion
	,isnull(Antiguedad,0) as Antiguedad
	,isnull(DiasAguinaldo,0) as DiasAguinaldo
	,isnull(DiasVacaciones,0)as DiasVacaciones
	,isnull(PrimaVacacional,0.0)as PrimaVacacional
	,isnull(PorcentajeExtra,0.0)as PorcentajeExtra
	,isnull(DiasExtras,0)as DiasExtras
	,isnull(Factor,0.00000)as Factor
	
	FROM [RH].[tblCatTiposPrestacionesDetalle]
	WHERE (IDTipoPrestacion = @IDTipoPrestacion) 
		
END
GO

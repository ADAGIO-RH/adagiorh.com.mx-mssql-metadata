USE [p_adagioRHRioSecreto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarTabuladorNivelSalarialAumentosDesempenoDetalle]
(
    @IDTabuladorNivelSalarialAumentosDesempeno INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM [Nomina].[tblTabuladorNivelSalarialAumentosDesempenoDetalle]
    WHERE [IDTabuladorNivelSalarialAumentosDesempeno] = @IDTabuladorNivelSalarialAumentosDesempeno
    ORDER BY Nivel
END;
GO

USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [Nomina].[fnObtenerSueldoMaximoPorNivelSalarialAumentosDesempeno]
(    
    @IDControlAumentosDesempenoDetalle INT
)
RETURNS DECIMAL(18,4)
AS
BEGIN
    DECLARE @SueldoMaximo DECIMAL(18,4) = 0,

            @Nivel INT = 0,
            @IDControlAumentosDesempeno INT=0



    SELECT @Nivel = CASE WHEN ISNULL(NivelSalarialCalibrado,0) <> 0 THEN NivelSalarialCalibrado ELSE NivelSalarial END, @IDControlAumentosDesempeno = IDControlAumentosDesempeno
    FROM Nomina.TblControlAumentosDesempenoDetalle CADD
    WHERE IDControlAumentosDesempenoDetalle = @IDControlAumentosDesempenoDetalle



    
    SELECT TOP 1 @SueldoMaximo =  TNSD.Maximo
    FROM Nomina.TblControlAumentosDesempeno CAD
        INNER JOIN Nomina.tblTabuladorNivelSalarialAumentosDesempeno TNS        
            ON CAD.IDTabuladorNivelSalarialAumentosDesempeno=TNS.IDTabuladorNivelSalarialAumentosDesempeno
        INNER JOIN Nomina.tblTabuladorNivelSalarialAumentosDesempenoDetalle TNSD
            ON TNS.IDTabuladorNivelSalarialAumentosDesempeno = TNSD.IDTabuladorNivelSalarialAumentosDesempeno
    WHERE CAD.IDControlAumentosDesempeno=@IDControlAumentosDesempeno AND TNSD.Nivel = @Nivel
    
    
    RETURN ISNULL(@SueldoMaximo, 0);
    
END
GO

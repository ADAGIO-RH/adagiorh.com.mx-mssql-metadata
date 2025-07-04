USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarTabuladorRelacionEvaluacionesObjetivosDetalle]
(
    @IDTabuladorRelacionEvaluacionesObjetivos INT
    ,@IDUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM [Nomina].[tblTabuladorRelacionEvaluacionesObjetivosDetalle]
    WHERE [IDTabuladorRelacionEvaluacionesObjetivos] = @IDTabuladorRelacionEvaluacionesObjetivos
    ORDER BY Nivel;
END;
GO

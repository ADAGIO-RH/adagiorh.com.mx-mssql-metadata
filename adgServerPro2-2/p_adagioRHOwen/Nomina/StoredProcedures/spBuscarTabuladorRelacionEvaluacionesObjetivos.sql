USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarTabuladorRelacionEvaluacionesObjetivos]
(
    @IDTabuladorRelacionEvaluacionesObjetivos INT,
    @IDUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM [Nomina].[tblTabuladorRelacionEvaluacionesObjetivos]
    WHERE [IDTabuladorRelacionEvaluacionesObjetivos] = @IDTabuladorRelacionEvaluacionesObjetivos;
END;
GO

USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarTabuladorNivelSalarialAumentosDesempeno]
(
    @IDTabuladorNivelSalarialAumentosDesempeno INT
   ,@IDUsuario INT 
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM [Nomina].[tblTabuladorNivelSalarialAumentosDesempeno]
    WHERE [IDTabuladorNivelSalarialAumentosDesempeno] = @IDTabuladorNivelSalarialAumentosDesempeno;
END;
GO

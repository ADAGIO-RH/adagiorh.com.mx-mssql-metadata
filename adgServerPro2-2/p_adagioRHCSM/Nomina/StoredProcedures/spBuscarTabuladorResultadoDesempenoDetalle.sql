USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarTabuladorResultadoDesempenoDetalle]
(
    @IDTabuladorResultadoDesempeno INT,
    @IDUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM [Nomina].[tblTabuladorResultadoDesempenoDetalle]
    WHERE [IDTabuladorResultadoDesempeno] = @IDTabuladorResultadoDesempeno
    ORDER BY Nivel;
END;
GO

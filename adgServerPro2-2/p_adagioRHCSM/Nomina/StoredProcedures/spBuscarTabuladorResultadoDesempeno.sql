USE [p_adagioRHCSM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarTabuladorResultadoDesempeno]
(
    @IDTabuladorResultadoDesempeno INT,
    @IDUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM [Nomina].[tblTabuladorResultadoDesempeno]
    WHERE [IDTabuladorResultadoDesempeno] = @IDTabuladorResultadoDesempeno;
END;
GO

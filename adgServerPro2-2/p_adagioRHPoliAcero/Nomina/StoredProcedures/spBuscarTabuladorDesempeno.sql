USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarTabuladorDesempeno]
(
    @IDTabuladorDesempeno INT
   ,@IDUsuario INT 
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM [Nomina].[tblTabuladorDesempeno]
    WHERE [IDTabuladorDesempeno] = @IDTabuladorDesempeno;
END;
GO

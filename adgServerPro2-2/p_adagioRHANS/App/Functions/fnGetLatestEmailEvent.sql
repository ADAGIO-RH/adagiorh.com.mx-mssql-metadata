USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--set a default new query template with the command QE Boost: Set New Query Template


CREATE FUNCTION App.fnGetLatestEmailEvent 
(
    @IDReferencia INT,
    @TipoReferencia VARCHAR(255)
)
RETURNS VARCHAR(255)
AS
BEGIN
    DECLARE @LatestEvent VARCHAR(255)

    SELECT TOP 1 
        @LatestEvent = [Event]
    FROM 
        app.tblEmailEvents
    WHERE 
        IDReferencia = @IDReferencia
        AND TipoReferencia = @TipoReferencia
    ORDER BY 
        [CreatedAt] DESC 

    RETURN  isnull(@LatestEvent,'- SIN ESTATUS -')
END
GO

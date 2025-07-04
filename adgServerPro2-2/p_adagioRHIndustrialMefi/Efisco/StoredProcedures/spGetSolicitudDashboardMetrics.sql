USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Efisco].[spGetSolicitudDashboardMetrics] 
    @IDSolicitud INT
AS
BEGIN
    SET NOCOUNT ON;

    -- SELECT 
    --     d.IDSolicitud,
    --     s.FechaInicial,
    --     s.FechaFinal,
    --     -- Financial Metrics
    --     COUNT(DISTINCT d.UUID) as TotalFacturas,
    --     SUM(d.Total) as TotalImporte,
    --     SUM(d.Subtotal) as SubtotalImporte,
    --     SUM(d.Descuento) as TotalDescuentos,
    --     SUM(d.TotalPagados) as TotalPagados,
    --     SUM(d.TotalDeRecepciones) as TotalRecepciones,
    --     SUM(d.TotalDeducciones) as TotalDeducciones,
    --     SUM(d.TotalOtros) as TotalOtros,
    --     -- Most Common Values
    --     MAX(d.Moneda) as MonedaPredominante,
    --     MAX(d.MetodoPago) as MetodoPagoPredominante,
    --     -- Time Metrics
    --     MIN(d.Fecha) as PrimeraFactura,
    --     MAX(d.Fecha) as UltimaFactura,
    --     -- Emisor with highest amount
    --     (
    --         SELECT TOP 1 EmisorNombre 
    --         FROM [Efisco].[tblDetallesSolicitudes] d2 
    --         WHERE d2.IDSolicitud = d.IDSolicitud 
    --         GROUP BY EmisorNombre 
    --         ORDER BY SUM(Total) DESC
    --     ) as EmisorPrincipal
    -- FROM [Efisco].[tblDetallesSolicitudes] d
    -- INNER JOIN [Efisco].[tblSolicitudesCreadas] s ON d.IDSolicitud = s.IDSolicitud
    -- WHERE d.IDSolicitud = @IDSolicitud
    -- GROUP BY d.IDSolicitud, s.FechaInicial, s.FechaFinal;

  
SELECT 
        d.IDSolicitud,
        s.FechaInicial,
        s.FechaFinal,
        -- Financial Metrics
        ISNULL(COUNT(DISTINCT d.UUID), 0) as TotalFacturas,
        ISNULL(SUM(d.Total), 0) as TotalImporte,
        ISNULL(SUM(d.Subtotal), 0) as SubtotalImporte,
        ISNULL(SUM(d.Descuento), 0) as TotalDescuentos,
        ISNULL(SUM(d.TotalPagados), 0) as TotalPagados,
        ISNULL(SUM(d.TotalDeRecepciones), 0) as TotalRecepciones,
        ISNULL(SUM(d.TotalDeducciones), 0) as TotalDeducciones,
        ISNULL(SUM(d.TotalOtros), 0) as TotalOtros,
        -- Most Common Values
        ISNULL(MAX(d.Moneda), '') as MonedaPredominante,
        ISNULL(MAX(d.MetodoPago), '') as MetodoPagoPredominante,
        -- Time Metrics
        ISNULL(MIN(d.Fecha), '1900-01-01') as PrimeraFactura,
        ISNULL(MAX(d.Fecha), '1900-01-01') as UltimaFactura,
        -- Emisor with highest amount
        ISNULL((
            SELECT TOP 1 EmisorNombre 
            FROM [Efisco].[tblDetallesSolicitudes] d2 
            WHERE d2.IDSolicitud = d.IDSolicitud 
            GROUP BY EmisorNombre 
            ORDER BY SUM(Total) DESC
        ), '') as EmisorPrincipal
    FROM [Efisco].[tblDetallesSolicitudes] d
    INNER JOIN [Efisco].[tblSolicitudesCreadas] s ON d.IDSolicitud = s.IDSolicitud
    WHERE d.IDSolicitud = @IDSolicitud
    GROUP BY d.IDSolicitud, s.FechaInicial, s.FechaFinal;

END
GO

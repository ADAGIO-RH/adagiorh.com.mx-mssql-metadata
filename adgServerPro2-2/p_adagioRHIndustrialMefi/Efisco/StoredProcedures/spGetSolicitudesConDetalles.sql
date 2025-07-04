USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Efisco].[spGetSolicitudesConDetalles](
    @IDSolicitud INT = 0,
    @IDUsuario INT = 0
)
AS
BEGIN
    SELECT 
        s.IDSolicitud,
        s.IDEfisco,
        s.RFC,
        s.TipoDocumento,
        s.FechaCreacion,
        s.FechaInicial,
        s.FechaFinal,
        s.Estado,
        s.TipoSolicitud,
        s.Mensaje,
        s.TotalArchivos,
        CAST(CASE 
            WHEN (SELECT TOP 1 IDSolicitud From Efisco.tblDetallesSolicitudes where IDSolicitud = S.IDSolicitud) IS NOT NULL THEN 1 
            ELSE 0 
        END as bit) AS TieneDetalles
    FROM 
        EFISCO.tblSolicitudesCreadas s
    

        Where s.IDSolicitud = ISNULL(@IDSolicitud,0) or ISNULL(@IDSolicitud,0) = 0
END
GO

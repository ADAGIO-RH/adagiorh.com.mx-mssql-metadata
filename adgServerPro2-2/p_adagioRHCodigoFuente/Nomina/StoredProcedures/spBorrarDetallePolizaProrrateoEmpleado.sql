USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBorrarDetallePolizaProrrateoEmpleado]
    @IDDetallePolizaProrrateoEmpleado INT,
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OldJSON VARCHAR(MAX);

    -- Obtener el registro a eliminar para auditoría
    SELECT 
        @OldJSON = (
            SELECT 
                d.IDDetallePolizaProrrateoEmpleado,
                d.IDPoliza,
                d.IDTipoPoliza,
                d.IDEmpleado,
                e.ClaveEmpleado,
                e.Nombre + ' ' + e.Paterno + ' ' + ISNULL(e.Materno, '') AS NombreCompleto,
                d.Filtro,
                d.IDReferencia,
                d.FechaCreacion
            FROM [Nomina].[tblDetallePolizaProrrateoEmpleado] d
            INNER JOIN [RH].[tblEmpleados] e ON d.IDEmpleado = e.IDEmpleado
            WHERE d.IDDetallePolizaProrrateoEmpleado = @IDDetallePolizaProrrateoEmpleado
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

    -- Eliminar el registro
    DELETE FROM [Nomina].[tblDetallePolizaProrrateoEmpleado]
    WHERE IDDetallePolizaProrrateoEmpleado = @IDDetallePolizaProrrateoEmpleado;

    -- Registrar la auditoría
    EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Nomina].[tblDetallePolizaProrrateoEmpleado]', '[Nomina].[spBorrarDetallePolizaProrrateoEmpleado]', 'DELETE', '', @OldJSON;
END
GO

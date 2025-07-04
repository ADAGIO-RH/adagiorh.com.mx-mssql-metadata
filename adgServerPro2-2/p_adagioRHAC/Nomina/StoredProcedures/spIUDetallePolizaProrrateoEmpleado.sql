USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spIUDetallePolizaProrrateoEmpleado](
    @IDDetallePolizaProrrateoEmpleado INT = 0,
    @IDPoliza INT,
    @IDTipoPoliza INT,
    @IDEmpleado INT,
    @Filtro VARCHAR(255),
    @IDReferencia VARCHAR(255) = NULL,
    @Porcentaje float = NULL,
    @IDUsuario INT
)
AS
BEGIN
    DECLARE 
        @OldJSON VARCHAR(MAX),
        @NewJSON VARCHAR(MAX),
        @IDReferenciaCalculado VARCHAR(255)
	;

    IF (@IDDetallePolizaProrrateoEmpleado = 0 OR @IDDetallePolizaProrrateoEmpleado IS NULL)
    BEGIN
        -- Validar si ya existe un registro para la misma combinación
        IF EXISTS(
            SELECT TOP 1 1 
            FROM Nomina.tblDetallePolizaProrrateoEmpleado 
            WHERE IDPoliza = @IDPoliza AND IDEmpleado = @IDEmpleado AND Filtro = @Filtro
        )
        BEGIN
            EXEC [App].[spObtenerError] @IDUsuario = 1, @CodigoError = '0302003'
            RETURN 0;
        END

        SELECT @IDReferenciaCalculado = 
            CASE @Filtro
                WHEN 'CentrosCostos' THEN CAST(IDCentroCosto AS VARCHAR(255))
                WHEN 'Departamentos' THEN CAST(IDDepartamento AS VARCHAR(255))
                WHEN 'Puestos' THEN CAST(IDPuesto AS VARCHAR(255))
                WHEN 'RazonesSociales' THEN CAST(IDRazonSocial AS VARCHAR(255))
                WHEN 'RegPatronales' THEN CAST(IDRegPatronal AS VARCHAR(255))
                ELSE @IDReferencia
            END
        FROM RH.tblEmpleadosMaster
        WHERE IDEmpleado = @IDEmpleado;

        INSERT INTO [Nomina].[tblDetallePolizaProrrateoEmpleado](IDPoliza,IDTipoPoliza,IDEmpleado,Filtro,IDReferencia, Porcentaje)
        VALUES(@IDPoliza,@IDTipoPoliza,@IDEmpleado,@Filtro,@IDReferenciaCalculado, 1)
				
        SET @IDDetallePolizaProrrateoEmpleado = SCOPE_IDENTITY()

        SELECT @NewJSON = (
					SELECT 
						d.IDDetallePolizaProrrateoEmpleado,
						d.IDPoliza,
						d.IDTipoPoliza,
						d.IDEmpleado,
						e.ClaveEmpleado,
						e.Nombre + ' ' + e.Paterno + ' ' + ISNULL(e.Materno,'') AS NombreCompleto,
						d.Filtro,
						d.IDReferencia,
						d.Porcentaje,
						d.FechaCreacion
					FROM [Nomina].[tblDetallePolizaProrrateoEmpleado] d
						INNER JOIN [RH].[tblEmpleados] e ON d.IDEmpleado = e.IDEmpleado
					WHERE d.IDDetallePolizaProrrateoEmpleado = @IDDetallePolizaProrrateoEmpleado FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
				)

        EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Nomina].[tblDetallePolizaProrrateoEmpleado]', '[Nomina].[spIUDetallePolizaProrrateoEmpleado]', 'INSERT', @NewJSON, ''
    END
    ELSE
    BEGIN
        -- Validar si ya existe un registro para la misma combinación, excluyendo el actual
        IF EXISTS(
            SELECT TOP 1 1 
            FROM Nomina.tblDetallePolizaProrrateoEmpleado 
            WHERE IDPoliza = @IDPoliza AND IDEmpleado = @IDEmpleado AND Filtro = @Filtro 
            	AND IDDetallePolizaProrrateoEmpleado <> @IDDetallePolizaProrrateoEmpleado
        )
        BEGIN
            EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
            RETURN 0;
        END

        SELECT @OldJSON = (
					SELECT 
						d.IDDetallePolizaProrrateoEmpleado,
						d.IDPoliza,
						d.IDTipoPoliza,
						d.IDEmpleado,
						e.ClaveEmpleado,
						e.Nombre + ' ' + e.Paterno + ' ' + ISNULL(e.Materno,'') AS NombreCompleto,
						d.Filtro,
						d.IDReferencia,
						d.Porcentaje,
						d.FechaCreacion
					FROM [Nomina].[tblDetallePolizaProrrateoEmpleado] d
						INNER JOIN [RH].[tblEmpleados] e ON d.IDEmpleado = e.IDEmpleado
					WHERE IDDetallePolizaProrrateoEmpleado = @IDDetallePolizaProrrateoEmpleado FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
				)

        UPDATE [Nomina].[tblDetallePolizaProrrateoEmpleado]
        SET 
            --IDPoliza = @IDPoliza,
            --IDTipoPoliza = @IDTipoPoliza,
            --IDEmpleado = @IDEmpleado,
            --Filtro = @Filtro,
            IDReferencia = @IDReferencia
        WHERE IDDetallePolizaProrrateoEmpleado = @IDDetallePolizaProrrateoEmpleado

        SELECT @NewJSON = (
					SELECT 
						d.IDDetallePolizaProrrateoEmpleado,
						d.IDPoliza,
						d.IDTipoPoliza,
						d.IDEmpleado,
						e.ClaveEmpleado,
						e.Nombre + ' ' + e.Paterno + ' ' + ISNULL(e.Materno,'') AS NombreCompleto,
						d.Filtro,
						d.IDReferencia,
						d.Porcentaje,
						d.FechaCreacion
					FROM [Nomina].[tblDetallePolizaProrrateoEmpleado] d
						INNER JOIN [RH].[tblEmpleados] e ON d.IDEmpleado = e.IDEmpleado
					WHERE IDDetallePolizaProrrateoEmpleado = @IDDetallePolizaProrrateoEmpleado FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
				)

        EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Nomina].[tblDetallePolizaProrrateoEmpleado]', '[Nomina].[spIUDetallePolizaProrrateoEmpleado]', 'UPDATE', @NewJSON, @OldJSON
    END

    EXEC [Nomina].[spBuscarDetallePolizaProrrateoEmpleado] @IDDetallePolizaProrrateoEmpleado = @IDDetallePolizaProrrateoEmpleado, @IDUsuario = @IDUsuario
END
GO

USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE    PROCEDURE [Nomina].[spBuscarDetallePolizaProrrateoEmpleado]
    @IDDetallePolizaProrrateoEmpleado INT = 0,
    @IDPoliza INT = NULL,
    @IDEmpleado INT = NULL,
	@IDUsuario int
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IDIdioma varchar(20)
    SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

    SELECT 
        d.IDDetallePolizaProrrateoEmpleado,
        d.IDPoliza,
        d.IDTipoPoliza,
        d.IDEmpleado,
        e.ClaveEmpleado,
        e.Nombre + ' ' + e.Paterno + ' ' + ISNULL(e.Materno, '') AS NombreCompleto,
        d.Filtro,
        d.IDReferencia,
        CASE d.Filtro
            WHEN 'CentrosCostos' THEN JSON_VALUE(cc.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))
            WHEN 'Departamentos' THEN JSON_VALUE(dep.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))
            WHEN 'Puestos' THEN JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))
            WHEN 'RazonesSociales' THEN rs.RazonSocial
            WHEN 'RegPatronales' THEN rp.RegistroPatronal + ' - ' + rp.RazonSocial
        END AS Referencia,
        d.Porcentaje,
        d.FechaCreacion,
        [Utilerias].[fnGetUrlFotoUsuario](e.ClaveEmpleado) as UrlFoto 
    FROM [Nomina].[tblDetallePolizaProrrateoEmpleado] d
        INNER JOIN [RH].[tblEmpleados] e ON d.IDEmpleado = e.IDEmpleado
        LEFT JOIN [RH].[tblCatCentroCosto] cc ON d.Filtro = 'CentrosCostos' AND d.IDReferencia = CAST(cc.IDCentroCosto AS VARCHAR(255))
        LEFT JOIN [RH].[tblCatDepartamentos] dep ON d.Filtro = 'Departamentos' AND d.IDReferencia = CAST(dep.IDDepartamento AS VARCHAR(255))
        LEFT JOIN [RH].[tblCatPuestos] p ON d.Filtro = 'Puestos' AND d.IDReferencia = CAST(p.IDPuesto AS VARCHAR(255))
        LEFT JOIN [RH].[tblCatRazonesSociales] rs ON d.Filtro = 'RazonesSociales' AND d.IDReferencia = CAST(rs.IDRazonSocial AS VARCHAR(255))
        LEFT JOIN [RH].[tblCatRegPatronal] rp ON d.Filtro = 'RegPatronales' AND d.IDReferencia = CAST(rp.IDRegPatronal AS VARCHAR(255))
    WHERE (ISNULL(@IDDetallePolizaProrrateoEmpleado, 0) = 0 OR d.IDDetallePolizaProrrateoEmpleado = @IDDetallePolizaProrrateoEmpleado)
        AND (ISNULL(@IDPoliza, 0)= 0 OR d.IDPoliza = @IDPoliza)
        AND (ISNULL(@IDEmpleado, 0)= 0  OR d.IDEmpleado = @IDEmpleado)
END
GO

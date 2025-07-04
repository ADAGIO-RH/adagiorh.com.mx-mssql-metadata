USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarControlAumentosDesempenoDetalle] 
    @IDControlAumentosDesempeno INT
    ,@IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IDIdioma varchar(max);
    SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');

    SELECT 
        d.IDControlAumentosDesempenoDetalle,
        d.IDControlAumentosDesempeno,
        d.IDEmpleado,
        d.IDRegPatronal,
        d.IDPuesto,
        d.IDDivision,
        d.IDRegion,
        d.IDArea,
        d.IDSucursal,
        d.IDCliente,
        d.IDEmpresa,
        d.IDCentroCosto,
        e.ClaveEmpleado,
        e.NombreCompleto,
        ISNULL(rp.RazonSocial, '') as RegPatronal,
        ISNULL(UPPER(JSON_VALUE(div.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))), '') as Division,
        ISNULL(UPPER(JSON_VALUE(r.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))), '') as Region,
        ISNULL(UPPER(JSON_VALUE(a.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))), '') as Area,
        ISNULL(s.Descripcion, '') as Sucursal,
        ISNULL(UPPER(JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))), '') as Cliente,
        ISNULL(emp.NombreComercial, '') as Empresa,
        ISNULL(UPPER(JSON_VALUE(cc.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))), '') as CentroCosto,
        ISNULL(UPPER(JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))), '') as Puesto,
        ISNULL(d.NivelSalarial, 0) as NivelSalarial,
        ISNULL(d.NivelSalarialCalibrado, 0) as NivelSalarialCalibrado,
        ISNULL(d.EvaluacionJefe, 0) as EvaluacionJefe,
        ISNULL(d.EvaluacionSubordinados, 0) as EvaluacionSubordinados,
        ISNULL(d.EvaluacionColegas, 0) as EvaluacionColegas,
        ISNULL(d.TotalEvaluacionPorcentual, 0) as TotalEvaluacionPorcentual,
        ISNULL(d.TotalEvaluacionPeso, 0) as TotalEvaluacionPeso,
        ISNULL(d.TotalEvaluacionCalibrado, 0) as TotalEvaluacionCalibrado,
        ISNULL(d.TotalObjetivosPorPesoEnCicloMedicion, 0) as TotalObjetivosPorPesoEnCicloMedicion,
        ISNULL(d.TotalObjetivosPeso, 0) as TotalObjetivosPeso,
        ISNULL(d.TotalObjetivosCalibrado, 0) as TotalObjetivosCalibrado,
        ISNULL(d.SueldoActual, 0) as SueldoActual,
        ISNULL(d.SueldoActualMensual, 0) as SueldoActualMensual,
        ISNULL(d.PorcentajeIncremento, 0) as PorcentajeIncremento,
        ISNULL(d.PorcentajeIncrementoCalibrado, 0) as PorcentajeIncrementoCalibrado,
        ISNULL(d.SueldoNuevo, 0) as SueldoNuevo,
        ISNULL(d.SueldoCalibrado, 0) as SueldoCalibrado,
        ISNULL(d.SueldoMensualNuevo, 0) as SueldoMensualNuevo,
        ISNULL(d.SueldoMensualCalibrado, 0) as SueldoMensualCalibrado,
        ISNULL(d.ExcluirColaborador, 0) as ExcluirColaborador
    FROM Nomina.TblControlAumentosDesempenoDetalle d
    INNER JOIN RH.tblEmpleadosMaster e ON d.IDEmpleado = e.IDEmpleado
    LEFT JOIN RH.tblCatRegPatronal rp ON d.IDRegPatronal = rp.IDRegPatronal

    LEFT JOIN RH.tblCatPuestos p ON d.IDPuesto = p.IDPuesto
    LEFT JOIN RH.tblCatDivisiones div ON d.IDDivision = div.IDDivision
    LEFT JOIN RH.tblCatRegiones r ON d.IDRegion = r.IDRegion
    LEFT JOIN RH.tblCatArea a ON d.IDArea = a.IDArea
    LEFT JOIN RH.tblCatSucursales s ON d.IDSucursal = s.IDSucursal
    LEFT JOIN RH.tblCatClientes c ON d.IDCliente = c.IDCliente
    LEFT JOIN RH.tblEmpresa emp ON d.IDEmpresa = emp.IdEmpresa
    LEFT JOIN RH.tblCatCentroCosto cc ON d.IDCentroCosto = cc.IDCentroCosto
    WHERE d.IDControlAumentosDesempeno = @IDControlAumentosDesempeno;
END
GO

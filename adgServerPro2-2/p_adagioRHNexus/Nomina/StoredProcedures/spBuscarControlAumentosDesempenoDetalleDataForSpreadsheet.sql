USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarControlAumentosDesempenoDetalleDataForSpreadsheet] 
    @IDControlAumentosDesempeno INT
    ,@IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    if object_id('tempdb..#Result') is not null drop table #Result;
    DECLARE @FechaMovAfiliatorio DATETIME = GETDATE();
    SELECT @FechaMovAfiliatorio = FechaMovAfiliatorio  FROM Nomina.tblControlAumentosDesempeno WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno
    DECLARE @ID_TIPO_MOV_AFILIATORIO_BAJA INT = 2;

    
    -- Declarar variables para formatos
    DECLARE @FormatoCurrency NVARCHAR(20) = '$#,##0.00';
    DECLARE @FormatoPercentage NVARCHAR(20) = '#0.00%';
    
    -- Variables para estilos de cabeceras
    DECLARE @ColorFondoEncabezadoDatosColaborador NVARCHAR(50) = '#9BC2E6';
    DECLARE @ColorTextoEncabezadoDatosColaborador NVARCHAR(50) = '#000000';
    DECLARE @ColorFondoEncabezadoDatosEvaluacion NVARCHAR(50) = '#0000FF';
    DECLARE @ColorTextoEncabezadoDatosEvaluacion NVARCHAR(50) = '#FFFFFF';
    DECLARE @ColorFondoEncabezadoDatosObjetivos NVARCHAR(50) = '#213C49';
    DECLARE @ColorTextoEncabezadoDatosObjetivos NVARCHAR(50) = '#FFFFFF';
    DECLARE @ColorFondoEncabezadoDatosCalculo NVARCHAR(50) = '#FFC000';
    DECLARE @ColorTextoEncabezadoDatosCalculo NVARCHAR(50) = '#000000';
    DECLARE @ColorFondoEncabezadoExcluirColaborador NVARCHAR(50) = '#FF0000';
    DECLARE @ColorTextoEncabezadoExcluirColaborador NVARCHAR(50) = '#FFFFFF';
    DECLARE @ColorFondoEncabezadoMovimiento NVARCHAR(50) = '#008000';
    DECLARE @ColorTextoEncabezadoMovimiento NVARCHAR(50) = '#FFFFFF';
    DECLARE @ColorFondoEncabezadoPorcentajeIncremento NVARCHAR(50) = '#D35400';
    DECLARE @ColorTextoEncabezadoPorcentajeIncremento NVARCHAR(50) = '#FFFFFF';
    


    DECLARE @FontFamilyEncabezado NVARCHAR(50) = 'Arial';
    DECLARE @FontSizeEncabezado INT = 12;
    DECLARE @BoldEncabezado VARCHAR(5) = 'true';


    -- Variables para estilos de contenido
    DECLARE @ColorFondoContenido NVARCHAR(50) = '#FFFFFF';
    DECLARE @ColorTextoContenido NVARCHAR(50) = '#000000';
    DECLARE @ColorFondoContenidoCalibracion NVARCHAR(50) = '#D3D3D3';
    DECLARE @ColorTextoContenidoCalibracion NVARCHAR(50) = '#000000';
    DECLARE @FontFamilyContenido NVARCHAR(50) = 'Arial';
    DECLARE @FontSizeContenido INT = 11;
    DECLARE @BoldContenido VARCHAR(5) = 'false';

    -- Obtener el idioma del usuario
    DECLARE @IDIdioma varchar(max);
    SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');

    -- Validar y crear tabla temporal
    SELECT @FormatoCurrency as FormatoCurrency,
           @FormatoPercentage as FormatoPercentage,
           @ColorFondoEncabezadoDatosColaborador as ColorFondoEncabezadoDatosColaborador,
           @ColorTextoEncabezadoDatosColaborador as ColorTextoEncabezadoDatosColaborador,
           @ColorFondoEncabezadoDatosEvaluacion as ColorFondoEncabezadoDatosEvaluacion,
           @ColorTextoEncabezadoDatosEvaluacion as ColorTextoEncabezadoDatosEvaluacion,
           @ColorFondoContenidoCalibracion as ColorFondoContenidoCalibracion,
           @ColorTextoContenidoCalibracion as ColorTextoContenidoCalibracion,
           @ColorFondoEncabezadoDatosObjetivos as ColorFondoEncabezadoDatosObjetivos,
           @ColorTextoEncabezadoDatosObjetivos as ColorTextoEncabezadoDatosObjetivos,
           @ColorFondoEncabezadoDatosCalculo as ColorFondoEncabezadoDatosCalculo,
           @ColorTextoEncabezadoDatosCalculo as ColorTextoEncabezadoDatosCalculo,
           @ColorFondoEncabezadoExcluirColaborador as ColorFondoEncabezadoExcluirColaborador,
           @ColorTextoEncabezadoExcluirColaborador as ColorTextoEncabezadoExcluirColaborador,
           @ColorFondoEncabezadoMovimiento as ColorFondoEncabezadoMovimiento,
           @ColorTextoEncabezadoMovimiento as ColorTextoEncabezadoMovimiento,
           @ColorFondoEncabezadoPorcentajeIncremento as ColorFondoEncabezadoPorcentajeIncremento,
           @ColorTextoEncabezadoPorcentajeIncremento as ColorTextoEncabezadoPorcentajeIncremento,
           @FontFamilyEncabezado as FontFamilyEncabezado,
           @FontSizeEncabezado as FontSizeEncabezado,
           @BoldEncabezado as BoldEncabezado,

           @ColorFondoContenido as ColorFondoContenido,

           @ColorTextoContenido as ColorTextoContenido,
           @FontFamilyContenido as FontFamilyContenido,
           @FontSizeContenido as FontSizeContenido,
           @BoldContenido as BoldContenido;
        
     SELECT 
        d.IDControlAumentosDesempenoDetalle,
        d.IDControlAumentosDesempeno,
        d.IDEmpleado,
        ISNULL(d.IDTipoPrestacion,0) as IDTipoPrestacion,
        ISNULL(d.Antiguedad,0) as Antiguedad,
        ISNULL(d.Factor,0) as Factor,
        ISNULL(d.IDRegPatronal,0) as IDRegPatronal,
        ISNULL(d.IDPuesto,0) as IDPuesto,
        ISNULL(d.IDDivision,0) as IDDivision,
        ISNULL(d.IDRegion,0) as IDRegion,
        ISNULL(d.IDArea,0) as IDArea,
        ISNULL(d.IDSucursal,0) as IDSucursal,
        ISNULL(d.IDCliente,0) as IDCliente,
        ISNULL(d.IDEmpresa,0) as IDEmpresa,
        ISNULL(d.IDCentroCosto,0) as IDCentroCosto,
        ISNULL(d.FechaAntiguedad, '') as FechaAntiguedad,
        e.ClaveEmpleado,
        e.NombreCompleto,
        ISNULL(rp.RazonSocial, '') as RegPatronal,
        ISNULL(UPPER(JSON_VALUE(div.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))), '') as Division,
        ISNULL(UPPER(JSON_VALUE(r.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))), '') as Region,
        ISNULL(UPPER(JSON_VALUE(a.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))), '') as Area,
        ISNULL(s.Descripcion, '') as Sucursal,
        ISNULL(UPPER(JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial'))), '') as Cliente,
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
        ISNULL(d.SueldoNuevoSinTope, 0) as SueldoNuevoSinTope,
        ISNULL(d.SueldoMensualNuevoSinTope, 0) as SueldoMensualNuevoSinTope,
        ISNULL(d.SueldoNuevoTopado, 0) as SueldoNuevoTopado,
        ISNULL(d.SueldoMensualNuevoTopado, 0) as SueldoMensualNuevoTopado,
        ISNULL(d.PorcentajeIncrementoInverso, 0) as PorcentajeIncrementoInverso,
        ISNULL(d.SueldoNuevo, 0) as SueldoNuevo,
        ISNULL(d.SueldoCalibrado, 0) as SueldoCalibrado,
        ISNULL(d.SueldoMensualNuevo, 0) as SueldoMensualNuevo,
        ISNULL(d.SueldoMensualCalibrado, 0) as SueldoMensualCalibrado,
        ISNULL(d.ExcluirColaborador, 0) as ExcluirColaborador,
        ISNULL(d.IDMovAfiliatorio, 0) as IDMovAfiliatorio,
        ISNULL(d.SalarioDiarioMovimiento, 0) as SalarioDiarioMovimiento,
        ISNULL(d.SalarioIntegradoMovimiento, 0) as SalarioIntegradoMovimiento,
        ISNULL(d.SalarioVariableMovimiento, 0) as SalarioVariableMovimiento,
        ISNULL(d.SalarioDiarioRealMovimiento, 0) as SalarioDiarioRealMovimiento,
        CASE WHEN d.IDMovAfiliatorio IS NOT NULL THEN 'SI' ELSE 'NO' END AS MovimientoAplicado,
        ISNULL(tp.Descripcion, '') as TipoPrestacion,
        CASE WHEN D.IDMovAfiliatorio IS  NULL THEN
            CASE WHEN MOV.IDMovAfiliatorio IS NOT NULL THEN 'ºEl colaborador cuenta con un movimiento afiliatorio la fecha de la aplicación. \n' ELSE '' END
            +CASE WHEN UltimoMov.IDMovAfiliatorio IS NOT NULL THEN 'ºEl ultimo movimiento afiliatorio del colaborador es una baja. \n' ELSE '' END     
            +CASE WHEN D.IDTipoPrestacion IS NULL OR ISNULL(D.Factor,0)=0 THEN 'ºEl colaborador no cuenta con una prestación o esta no cuenta con detalles para su atiguedad.\n' ELSE '' END  
            +CASE WHEN D.IDRegPatronal IS NULL THEN 'ºEl colaborador no pertenece a ningun registro patronal. \n' ELSE '' END  
            +CASE WHEN (ISNULL(D.NivelSalarial,0)=0 AND ISNULL(D.NivelSalarialCalibrado,0)=0) THEN 'ºEl colaborador no cuenta con un nivel salarial. \n' ELSE '' END  
            +CASE WHEN D.FechaAntiguedad > CA.FechaReferencia THEN 'ºLa antiguedad del colaborador es mayor a la fecha de referencia. \n' ELSE '' END
         ELSE '' END        
        AS Errores

    INTO #Result


    FROM Nomina.TblControlAumentosDesempenoDetalle d
    INNER JOIN Nomina.tblControlAumentosDesempeno ca ON d.IDControlAumentosDesempeno = ca.IDControlAumentosDesempeno
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
    LEFT JOIN RH.tblCatTiposPrestaciones tp ON d.IDTipoPrestacion = tp.IDTipoPrestacion
            LEFT JOIN IMSS.tblMovAfiliatorios MOV
            ON E.IDEmpleado=MOV.IDEmpleado
            AND MOV.Fecha=@FechaMovAfiliatorio
        LEFT JOIN (
            SELECT INFO.* 
            FROM (    
                SELECT 
                ROW_NUMBER() OVER(PARTITION BY IDEmpleado ORDER BY Fecha DESC, IDMovAfiliatorio) AS DIV
                ,*
                FROM IMSS.tblMovAfiliatorios WITH (nolock)
            ) AS INFO
            WHERE DIV=1 
        ) AS UltimoMov 
            ON UltimoMov.IDEmpleado=d.IDEmpleado 
            AND UltimoMov.IDTipoMovimiento=@ID_TIPO_MOV_AFILIATORIO_BAJA
    WHERE d.IDControlAumentosDesempeno = @IDControlAumentosDesempeno
    order by e.ClaveEmpleado


    SELECT * FROM #Result ORDER BY ClaveEmpleado,Errores
END
GO

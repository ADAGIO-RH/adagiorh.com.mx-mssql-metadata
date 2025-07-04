USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarControlBonosObjetivosDetalleDataForSpreadsheet]
    @IDControlBonosObjetivos INT
    ,@IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    if object_id('tempdb..#Result') is not null drop table #Result;

    -- Declarar variables para formatos
    DECLARE @FormatoCurrency NVARCHAR(20) = '$#,##0.00';
    DECLARE @FormatoPercentage NVARCHAR(20) = '#0.00%';
    DECLARE @ID_TIPO_MOV_AFILIATORIO_BAJA INT = 2;
    
    -- Variables para estilos de cabeceras (manteniendo el mismo patrón de colores)
    DECLARE @ColorFondoEncabezadoDatosColaborador NVARCHAR(50) = '#9BC2E6';
    DECLARE @ColorTextoEncabezadoDatosColaborador NVARCHAR(50) = '#000000';    
    DECLARE @ColorFondoEncabezadoDatosObjetivos NVARCHAR(50) = '#213C49';
    DECLARE @ColorTextoEncabezadoDatosObjetivos NVARCHAR(50) = '#FFFFFF';
    DECLARE @ColorFondoEncabezadoDatosCalculo NVARCHAR(50) = '#FFC000';
    DECLARE @ColorTextoEncabezadoDatosCalculo NVARCHAR(50) = '#000000';
    DECLARE @ColorFondoEncabezadoExcluirColaborador NVARCHAR(50) = '#FF0000';
    DECLARE @ColorTextoEncabezadoExcluirColaborador NVARCHAR(50) = '#FFFFFF';    
    DECLARE @ColorFondoEncabezadoFinal NVARCHAR(50) = '#D35400';
    DECLARE @ColorTextoEncabezadoFinal NVARCHAR(50) = '#FFFFFF';

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
    DECLARE @TopeFactorUtilidad NVARCHAR(50);
    DECLARE @TopeFactorObjetivos NVARCHAR(50);


    -- Obtener el idioma del usuario
    DECLARE @IDIdioma varchar(max);
    SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');

    SELECT 
           @TopeFactorUtilidad = CAST(CAST(TopeFactorUtilidad AS decimal(18,2)) AS NVARCHAR(50)),           
           @TopeFactorObjetivos = CAST(CAST(TopeFactorObjetivos AS decimal(18,2)) AS NVARCHAR(50))
    FROM Nomina.tblControlBonosObjetivos
    WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos

    -- Validar y crear tabla temporal
    SELECT 
        @FormatoCurrency AS FormatoCurrency,
        @FormatoPercentage AS FormatoPercentage,
        @ColorFondoEncabezadoDatosColaborador AS ColorFondoEncabezadoDatosColaborador,
        @ColorTextoEncabezadoDatosColaborador AS ColorTextoEncabezadoDatosColaborador,
        @ColorFondoEncabezadoDatosObjetivos AS ColorFondoEncabezadoDatosObjetivos,
        @ColorTextoEncabezadoDatosObjetivos AS ColorTextoEncabezadoDatosObjetivos,
        @ColorFondoEncabezadoDatosCalculo AS ColorFondoEncabezadoDatosCalculo,
        @ColorTextoEncabezadoDatosCalculo AS ColorTextoEncabezadoDatosCalculo,
        @ColorFondoEncabezadoExcluirColaborador AS ColorFondoEncabezadoExcluirColaborador,
        @ColorTextoEncabezadoExcluirColaborador AS ColorTextoEncabezadoExcluirColaborador,
        @ColorFondoEncabezadoFinal AS ColorFondoEncabezadoFinal,
        @ColorTextoEncabezadoFinal AS ColorTextoEncabezadoFinal,
        @FontFamilyEncabezado AS FontFamilyEncabezado,
        @FontSizeEncabezado AS FontSizeEncabezado,
        @BoldEncabezado AS BoldEncabezado,
        @ColorFondoContenido AS ColorFondoContenido,
        @ColorTextoContenido AS ColorTextoContenido,
        @ColorFondoContenidoCalibracion AS ColorFondoContenidoCalibracion,
        @ColorTextoContenidoCalibracion AS ColorTextoContenidoCalibracion,
        @FontFamilyContenido AS FontFamilyContenido,
        @FontSizeContenido AS FontSizeContenido,
        @BoldContenido AS BoldContenido,
        @TopeFactorUtilidad AS TopeFactorUtilidad,
        @TopeFactorObjetivos AS TopeFactorObjetivos

    SELECT 
        d.IDControlBonosObjetivosDetalle,
        d.IDControlBonosObjetivos,
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
        ISNULL(d.IDDepartamento,0) as IDDepartamento,
        ISNULL(d.FechaAntiguedad,'') as FechaAntiguedad,
        e.ClaveEmpleado,
        e.NombreCompleto,
        ISNULL(rp.RazonSocial,'') as RegPatronal,
        ISNULL(UPPER(JSON_VALUE(div.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))),'') as Division,
        ISNULL(UPPER(JSON_VALUE(r.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))),'') as Region,
        ISNULL(UPPER(JSON_VALUE(a.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))),'') as Area,
        ISNULL(s.Descripcion,'') as Sucursal,
        ISNULL(UPPER(JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial'))),'') as Cliente,
        ISNULL(emp.NombreComercial,'') as Empresa,
        ISNULL(UPPER(JSON_VALUE(cc.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))),'') as CentroCosto,
        ISNULL(UPPER(JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))),'') as Puesto,
        ISNULL(d.NivelSalarial,0) as NivelSalarial,
        ISNULL(d.CalibracionNivelSalarial,0) as CalibracionNivelSalarial,
        ISNULL(d.Dias,0) as Dias,
        ISNULL(d.CalibracionDias,0) as CalibracionDias,
        ISNULL(d.Incapacidades,0) as Incapacidades,
        ISNULL(d.CalibracionIncapacidades,0) as CalibracionIncapacidades,
        ISNULL(d.Ausentismos,0) as Ausentismos,
        ISNULL(d.CalibracionAusentismos,0) as CalibracionAusentismos,
        ISNULL(d.DiasEjercicio,0) as DiasEjercicio,
        ISNULL(d.CalibracionDiasEjercicio,0) as CalibracionDiasEjercicio,
        ISNULL(d.TotalEvaluacionPorcentual,0) as TotalEvaluacionPorcentual,
        ISNULL(d.CalibracionTotalEvaluacionPorcentual,0) as CalibracionTotalEvaluacionPorcentual,
        ISNULL(d.TotalObjetivos,0) as TotalObjetivos,
        ISNULL(d.CalibracionTotalObjetivos,0) as CalibracionTotalObjetivos,
        ISNULL(d.FactorObjetivos,0) as FactorObjetivos,
        ISNULL(d.CalibracionFactorObjetivos,0) as CalibracionFactorObjetivos,
        ISNULL(d.SueldoActual,0) as SueldoActual,        
        ISNULL(d.SueldoActualMensual,0) as SueldoActualMensual,
        ISNULL(d.SueldoActualAnual,0) as SueldoActualAnual,
        ISNULL(d.FactorParaBono,0) as FactorParaBono,
        ISNULL(d.CalibracionFactorParaBono,0) as CalibracionFactorParaBono,
        ISNULL(d.ResultadoUtilidadDesempeno,0) as ResultadoUtilidadDesempeno,
        ISNULL(d.CalibracionResultadoUtilidadDesempeno,0) as CalibracionResultadoUtilidadDesempeno,
        ISNULL(d.BonoAnual,0) as BonoAnual,
        ISNULL(d.CalibracionBonoAnual,0) as CalibracionBonoAnual,
        ISNULL(d.PTU,0) as PTU,
        ISNULL(d.CalibracionPTU,0) as CalibracionPTU,
        ISNULL(d.Complemento,0) as Complemento,
        ISNULL(d.CalibracionComplemento,0) as CalibracionComplemento,
        ISNULL(d.BonoFinal,0) as BonoFinal,
        ISNULL(d.CalibracionBonoFinal,0) as CalibracionBonoFinal,
        ISNULL(d.ExcluirColaborador,0) as ExcluirColaborador,
        ISNULL(tp.Descripcion,'') as TipoPrestacion,
        ISNULL(dep.Descripcion,'') as Departamento,
        CASE WHEN (ISNULL(d.BonoFinal,0) > 0 AND (ISNULL(d.CalibracionBonoFinal,0) = 0)) OR ISNULL(d.CalibracionBonoFinal,0) > 0 THEN 'SI' ELSE 'NO' END as PagaBono,
        CASE WHEN (ISNULL(d.Complemento,0) > 0 AND (ISNULL(d.CalibracionComplemento,0) = 0)) OR ISNULL(d.CalibracionComplemento,0) > 0 THEN 'SI' ELSE 'NO' END as PagaComplemento,    
        CASE WHEN ISNULL(cb.Aplicado,0)=0 THEN            
            CASE WHEN UltimoMov.IDMovAfiliatorio IS NOT NULL THEN 'ºEl ultimo movimiento afiliatorio del colaborador es una baja. \n' ELSE '' END                 
            +CASE WHEN (ISNULL(D.NivelSalarial,0)=0 AND ISNULL(D.CalibracionNivelSalarial,0)=0) THEN 'ºEl colaborador no cuenta con un nivel salarial. \n' ELSE '' END           
            +CASE WHEN D.FechaAntiguedad > CB.FechaReferencia THEN 'ºLa antiguedad del colaborador es mayor a la fecha de referencia. \n' ELSE '' END
        ELSE '' END        
        AS Errores

    INTO #Result
    FROM Nomina.tblControlBonosObjetivosDetalle d
    INNER JOIN Nomina.tblControlBonosObjetivos cb ON d.IDControlBonosObjetivos = cb.IDControlBonosObjetivos
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
    LEFT JOIN RH.tblCatDepartamentos dep ON d.IDDepartamento = dep.IDDepartamento
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
    WHERE d.IDControlBonosObjetivos = @IDControlBonosObjetivos
    ORDER BY e.ClaveEmpleado;

    SELECT * FROM #Result ORDER BY ClaveEmpleado;
END
GO

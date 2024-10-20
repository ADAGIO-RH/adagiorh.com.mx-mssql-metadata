USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Nomina].[spAperturaCuentaBancomer]
(
    @FechaInicio Date,    
    @FechaFin Date,   
    @IDLayout int , 
    @IDUsuario int   
)    
AS    
BEGIN    
    DECLARE @dtEmpleados RH.dtEmpleados, 
            @CuentaOrigen varchar(255), 
            @RFCOrigen varchar(255), 
            @Desconocido varchar(255);

    DECLARE @TablaVariablesBBVA AS TABLE(
        IDLayoutPago int,
        IDLayoutPapoParametros int,
        Parametro varchar(510),
        Valor varchar(255)
    );

    IF OBJECT_ID('tempdb..#tempResp') IS NOT NULL DROP TABLE #tempResp;    
    IF OBJECT_ID('tempdb..#tempRegistros') IS NOT NULL DROP TABLE #tempRegistros;    
    
    CREATE TABLE #tempResp(Respuesta nvarchar(max));    

    INSERT INTO @dtEmpleados    
    EXEC RH.spBuscarEmpleados @FechaIni= @FechaInicio, @Fechafin = @FechaFin, @IDUsuario = @IDUsuario

    INSERT INTO @TablaVariablesBBVA
    EXEC [Nomina].[spBuscarParametrosLayoutPago] @IDLayoutPago = @IDLayout

    SELECT @CuentaOrigen = ISNULL(Valor, '') 
    FROM @TablaVariablesBBVA 
    WHERE Parametro = 'Cuenta Origen'

    SELECT @RFCOrigen = ISNULL(Valor, '') 
    FROM @TablaVariablesBBVA 
    WHERE Parametro = 'RFC Origen'

    SELECT @Desconocido = ISNULL(Valor, '') 
    FROM @TablaVariablesBBVA 
    WHERE Parametro = 'Desconocido'

    SELECT     
        e.ClaveEmpleado AS [Clave_Colaborador],    
        COALESCE(LTRIM(RTRIM(ISNULL(E.Nombre,''))) + ' ' + LTRIM(RTRIM(ISNULL(E.SegundoNombre,''))), '') AS Nombres,    
        RTRIM(LTRIM(ISNULL(e.Paterno,''))) AS Paterno,    
        RTRIM(LTRIM(ISNULL(e.Materno,''))) AS Materno,    
        FORMAT(e.FechaNacimiento, 'yyyy-MM-dd') AS [Fecha_Nacimiento],    
        CASE 
            WHEN e.EstadoCivil = 'CASADO' THEN 'C'    
            WHEN e.EstadoCivil = 'SOLTERO' THEN 'S'    
            WHEN e.EstadoCivil = 'VIUDO' THEN 'V'    
            WHEN e.EstadoCivil = 'DIVORCIADO' THEN 'D'    
            WHEN e.EstadoCivil = 'UNION LIBRE' THEN 'U'    
            ELSE 'S' 
        END AS [Estado_Civil],    
        RTRIM(LTRIM(ISNULL(e.CURP,''))) AS CURP,    
        CASE 
            WHEN e.Sexo = 'MASCULINO' THEN 'M'    
            ELSE 'F' 
        END AS Sexo,    
        CASE 
            WHEN ISNULL(e.PaisNacimiento, 'MEXICO') = 'MEXICO' THEN 'M'    
            ELSE 'E' 
        END AS Nacionalidad,
        RTRIM(LTRIM(ISNULL(p.Codigo, ''))) AS [Codigo_Pais],
        FORMAT(e.FechaAntiguedad, 'yyyy-MM-dd') AS [Fecha_Antiguedad],
        RTRIM(LTRIM(ISNULL(de.Calle, ''))) AS Calle,    
        RTRIM(LTRIM(ISNULL(de.Exterior, 'SN'))) AS Exterior,    
        RTRIM(LTRIM(ISNULL(Colonias.NombreAsentamiento, ISNULL(de.Colonia, '')))) AS Colonia,    
        RTRIM(LTRIM(ISNULL(CP.CodigoPostal, ISNULL(de.CodigoPostal, '77710')))) AS [Codigo_Postal],    
        RTRIM(LTRIM(ISNULL(Municipios.Descripcion, ISNULL(de.Municipio, '')))) AS Municipio,    
        RTRIM(LTRIM(ISNULL(Estados.NombreEstado, ISNULL(de.Estado, '')))) AS Estado,    
        ISNULL(ce.Value, '9848773500') AS [Telefono_Trabajador],    
        '9848773500' AS [Otro_Telefono],    
        REPLACE(ISNULL(pe.Tarjeta, ''), ' ', '') AS Tarjeta,    
        '5133' AS [Sucursal_Gestora],  
        ISNULL(email.Value, '') AS [Email],    
        ROW_NUMBER() OVER (PARTITION BY e.ClaveEmpleado ORDER BY e.ClaveEmpleado ASC) AS RN  
    INTO #TempRegistros    
    FROM @dtEmpleados e    
    LEFT JOIN rh.tblPagoEmpleado pe WITH(NOLOCK) ON e.IDEmpleado = pe.IDEmpleado AND pe.IDLayoutPago = @IDLayout 
    LEFT JOIN Nomina.tblLayoutPago lp WITH(NOLOCK) ON lp.IDLayoutPago = pe.IDLayoutPago   
    LEFT JOIN Nomina.tblCatTiposLayout tl WITH(NOLOCK) ON lp.IDTipoLayout = tl.IDTipoLayout    
    LEFT JOIN [RH].[tblDireccionEmpleado] de WITH(NOLOCK) ON e.IDEmpleado = de.IDEmpleado AND de.FechaIni <= @Fechafin AND de.FechaFin >= @Fechafin  
    LEFT JOIN Sat.tblCatCodigosPostales CP WITH(NOLOCK) ON CP.IDCodigoPostal = de.IDCodigoPostal
    LEFT JOIN Sat.tblCatEstados Estados WITH(NOLOCK) ON de.IDEstado = Estados.IDEstado
    LEFT JOIN Sat.tblCatMunicipios Municipios WITH(NOLOCK) ON de.IDMunicipio = Municipios.IDMunicipio
    LEFT JOIN Sat.tblCatColonias Colonias WITH(NOLOCK) ON de.IDColonia = Colonias.IDColonia
    LEFT JOIN Sat.tblCatPaises p WITH(NOLOCK) ON de.IDPais = p.IDPais
    LEFT JOIN (
        SELECT cce.*
        FROM RH.tblContactoEmpleado cce WITH(NOLOCK)    
        JOIN rh.tblCatTipoContactoEmpleado tce WITH(NOLOCK) ON cce.IDTipoContactoEmpleado = tce.IDTipoContacto    
        WHERE tce.IDMedioNotificacion IN ('TelefonoFijo', 'Celular')
    ) ce ON e.IDEmpleado = ce.IDEmpleado    
    LEFT JOIN (
        SELECT cce.*
        FROM RH.tblContactoEmpleado cce WITH(NOLOCK)    
        JOIN rh.tblCatTipoContactoEmpleado tce WITH(NOLOCK) ON cce.IDTipoContactoEmpleado = tce.IDTipoContacto    
        WHERE tce.IDMedioNotificacion = 'EMAIL'    
    ) email ON e.IDEmpleado = email.IDEmpleado  
    WHERE pe.IDLayoutPago IS NOT NULL AND ISNULL(pe.Cuenta, '') = '';

    INSERT INTO #tempResp    
    SELECT [App].[fnAddString](2, '01', '0', 1)     
        + [App].[fnAddString](10, ISNULL(@CuentaOrigen, ''), '0', 1)  
        + [App].[fnAddString](13, ISNULL(@RFCOrigen, ''), ' ', 1)     
        + [App].[fnAddString](3, '115', '0', 1)     
        + [App].[fnAddString](10, CAST(FORMAT(GETDATE(), 'yyyy-MM-dd') AS varchar(10)), '', 1)     
        + [App].[fnAddString](9, '000000001', '0', 1) 
        + [App].[fnAddString](30, 'APERTURA DE CUENTAS', ' ', 2)   
        + [App].[fnAddString](7, CAST((SELECT COUNT(*) FROM #TempRegistros) AS varchar(7)), '0', 1)     
        + [App].[fnAddString](36, '', '', 2);  

    INSERT INTO #tempResp    
    SELECT 	
        [App].[fnAddString](2, '02', '0', 1)      
        + [App].[fnAddString](18, ISNULL(CURP, ''), '', 1)     
        + [App].[fnAddString](50, ISNULL(RTRIM(LTRIM(Email)), ''), '', 2)     
        + [App].[fnAddString](10, ISNULL(Telefono_Trabajador, ''), '', 1)     
        + [App].[fnAddString](4, ISNULL(@Desconocido, ''), '', 1)     
        + [App].[fnAddString](16, ISNULL(Tarjeta, '0'), '0', 2)     
        + [App].[fnAddString](20, '', '', 2)     
    FROM #tempRegistros    
    WHERE RN = 1;

    SELECT * FROM #tempResp;   
END
GO

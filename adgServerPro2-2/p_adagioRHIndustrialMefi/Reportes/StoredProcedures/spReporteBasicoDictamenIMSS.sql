USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************
** Descripción     : Procedimiento para creación del layout del dictamen del IMSS
** Autor           : Javier Peña
** Email           : jpena@adagio.com.mx
** FechaCreacion   : 2024-01-23
** Parámetros      :
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd) Autor            Comentario
------------------ ---------------- ------------------------------------------------------------
2024-04-24         Javier Peña      Se agregaron columnas informativas al reporte. Sucursal,Centro Costo,
                                    Fechas Alta y Baja del Registro Patronal, Nombre Completo
***************************************************************************************************/

CREATE PROCEDURE [Reportes].[spReporteBasicoDictamenIMSS](
    @dtFiltros [Nomina].[dtFiltrosRH] READONLY,
    @IDUsuario INT
) AS
BEGIN

    DECLARE
        --- Variables
         @FechaInicio                               DATETIME
        ,@FechaFin                                  DATETIME
        ,@IDsRegistrosPatronales                    VARCHAR(MAX)
        ,@Ejercicio                                 INT
        ,@IDTipoNominaPeriodos                      INT


        --- Constantes
        ,@CATALOGO_REGISTRO_PATRONAL                VARCHAR(50) = 'RegPatronales'
        ,@ID_ALTA                                   INT         = 1
        ,@ID_BAJA                                   INT         = 2
        ,@ID_REINGRESO                              INT         = 3


        ---- Table types
        ,@Filtros                                   Nomina.dtFiltrosRH
        ,@Periodos                                  Nomina.dtPeriodos
        ,@dtEmpleadosVigentes                       RH.dtEmpleados

        ---- Ramas Dictamen

        ,@SueldosSalarios                           VARCHAR(MAX)
        ,@GraficacionAnual                          VARCHAR(MAX)
        ,@ParticipacionUtilidades                   VARCHAR(MAX)
        ,@ReembolsoGastosMedicos                    VARCHAR(MAX)
        ,@FondoAhorroPatron                         VARCHAR(MAX)
        ,@FondoAhorroTrabajador                     VARCHAR(MAX)
        ,@CajaAhorro                                VARCHAR(MAX)
        ,@ContribucionesTrabajador                  VARCHAR(MAX)
        ,@PremiosPuntualidad                        VARCHAR(MAX)
        ,@PrimaSeguroVida                           VARCHAR(MAX)
        ,@SeguroGastosMedicosMayores                VARCHAR(MAX)
        ,@CuotasSindicales                          VARCHAR(MAX)
        ,@SubsidiosIncapacidad                      VARCHAR(MAX)
        ,@BecasTrabajadoresHijos                    VARCHAR(MAX)
        ,@HoraExtra                                 VARCHAR(MAX)
        ,@PrimaDominical                            VARCHAR(MAX)
        ,@PrimaVacacional                           VARCHAR(MAX)
        ,@PrimaAntiguedad                           VARCHAR(MAX)
        ,@PagosSeparacion                           VARCHAR(MAX)
        ,@SeguroRetiro                              VARCHAR(MAX)
        ,@Indemnizaciones                           VARCHAR(MAX)
        ,@ReembolsoFuneral                          VARCHAR(MAX)
        ,@CuotasSeguridadSocial                     VARCHAR(MAX)
        ,@Comisiones                                VARCHAR(MAX)
        ,@ValesDespensa                             VARCHAR(MAX)
        ,@ValesRestaurante                          VARCHAR(MAX)
        ,@ValesGasolina                             VARCHAR(MAX)
        ,@ValesRopa                                 VARCHAR(MAX)
        ,@AyudaRenta                                VARCHAR(MAX)
        ,@AyudaArticulosEscolares                   VARCHAR(MAX)
        ,@AyudaAnteojos                             VARCHAR(MAX)
        ,@AyudaTransporte                           VARCHAR(MAX)
        ,@AyudaGastosFuneral                        VARCHAR(MAX)
        ,@OtrosIngresosSalarios                     VARCHAR(MAX)
        ,@JubilacionesPensionesRetiro               VARCHAR(MAX)
        ,@JubilacionesPensionesRetiroParcialidades  VARCHAR(MAX)
        ,@IngresosAccionesTitulos                   VARCHAR(MAX)
        ,@Alimentacion                              VARCHAR(MAX)
        ,@Habitacion                                VARCHAR(MAX)
        ,@PremiosAsistencia                         VARCHAR(MAX)
        ,@Viaticos                                  VARCHAR(MAX)



    SELECT TOP 1
        @SueldosSalarios = [DictamenIMSS].[SueldosSalarios]
        ,@GraficacionAnual = [DictamenIMSS].[GratificacionAnual]
        ,@ParticipacionUtilidades = [DictamenIMSS].[ParticipacionUtilidades]
        ,@ReembolsoGastosMedicos = [DictamenIMSS].[ReembolsoGastosMedicos]
        ,@FondoAhorroPatron = [DictamenIMSS].[FondoAhorroPatron]
        ,@FondoAhorroTrabajador = [DictamenIMSS].[FondoAhorroTrabajador]
        ,@CajaAhorro = [DictamenIMSS].[CajaAhorro]
        ,@ContribucionesTrabajador = [DictamenIMSS].[ContribucionesTrabajador]
        ,@PremiosPuntualidad = [DictamenIMSS].[PremiosPuntualidad]
        ,@PrimaSeguroVida = [DictamenIMSS].[PrimaSeguroVida]
        ,@SeguroGastosMedicosMayores = [DictamenIMSS].[SeguroGastosMedicosMayores]
        ,@CuotasSindicales = [DictamenIMSS].[CuotasSindicales]
        ,@SubsidiosIncapacidad = [DictamenIMSS].[SubsidiosIncapacidad]
        ,@BecasTrabajadoresHijos = [DictamenIMSS].[BecasTrabajadoresHijos]
        ,@HoraExtra = [DictamenIMSS].[HoraExtra]
        ,@PrimaDominical = [DictamenIMSS].[PrimaDominical]
        ,@PrimaVacacional = [DictamenIMSS].[PrimaVacacional]
        ,@PrimaAntiguedad = [DictamenIMSS].[PrimaAntiguedad]
        ,@PagosSeparacion = [DictamenIMSS].[PagosSeparacion]
        ,@SeguroRetiro = [DictamenIMSS].[SeguroRetiro]
        ,@Indemnizaciones = [DictamenIMSS].[Indemnizaciones]
        ,@ReembolsoFuneral = [DictamenIMSS].[ReembolsoFuneral]
        ,@CuotasSeguridadSocial = [DictamenIMSS].[CuotasSeguridadSocial]
        ,@Comisiones = [DictamenIMSS].[Comisiones]
        ,@ValesDespensa = [DictamenIMSS].[ValesDespensa]
        ,@ValesRestaurante = [DictamenIMSS].[ValesRestaurante]
        ,@ValesGasolina = [DictamenIMSS].[ValesGasolina]
        ,@ValesRopa = [DictamenIMSS].[ValesRopa]
        ,@AyudaRenta = [DictamenIMSS].[AyudaRenta]
        ,@AyudaArticulosEscolares = [DictamenIMSS].[AyudaArticulosEscolares]
        ,@AyudaAnteojos = [DictamenIMSS].[AyudaAnteojos]
        ,@AyudaTransporte = [DictamenIMSS].[AyudaTransporte]
        ,@AyudaGastosFuneral = [DictamenIMSS].[AyudaGastosFuneral]
        ,@OtrosIngresosSalarios = [DictamenIMSS].[OtrosIngresosSalarios]
        ,@JubilacionesPensionesRetiro = [DictamenIMSS].[JubilacionesPensionesRetiro]
        ,@JubilacionesPensionesRetiroParcialidades = [DictamenIMSS].[JubilacionesPensionesRetiroParcialidades]
        ,@IngresosAccionesTitulos = [DictamenIMSS].[IngresosAccionesTitulos]
        ,@Alimentacion = [DictamenIMSS].[Alimentacion]
        ,@Habitacion = [DictamenIMSS].[Habitacion]
        ,@PremiosAsistencia = [DictamenIMSS].[PremiosAsistencia]
        ,@Viaticos = [DictamenIMSS].[Viaticos]
    FROM IMSS.tblConfiguracionDictamenIMSS DictamenIMSS;


    INSERT INTO @Filtros (Catalogo, [Value])
    SELECT Catalogo
          ,[Value]
    FROM @dtFiltros
    WHERE [Value] IS NOT NULL
          AND Catalogo <> @CATALOGO_REGISTRO_PATRONAL;



    SET @FechaInicio = CASE WHEN EXISTS ((SELECT TOP 1 TRY_CAST([Value] as DATETIME) FROM @dtFiltros WHERE Catalogo = 'FechaIni'))
                                          THEN (SELECT TOP 1 TRY_CAST([Value] as DATETIME) FROM @dtFiltros WHERE Catalogo = 'FechaIni')
                                          ELSE '1900-01-01'
                                   END
    SET @FechaFin = CASE WHEN EXISTS ((SELECT TOP 1 CAST([Value] as DATETIME) FROM @dtFiltros WHERE Catalogo = 'FechaFin'))
                                          THEN (SELECT TOP 1 TRY_CAST([Value] as DATETIME) FROM @dtFiltros WHERE Catalogo = 'FechaFin')
                                          ELSE '9999-12-31'
                                   END

    SET @Ejercicio = CASE WHEN EXISTS ((SELECT TOP 1 TRY_CAST([Value] as INT) FROM @dtFiltros WHERE Catalogo = 'Ejercicio'))
                                      THEN (SELECT TOP 1 TRY_CAST([Value] as INT) FROM @dtFiltros WHERE Catalogo = 'Ejercicio')
                                      ELSE NULL
                               END

     SET @IDsRegistrosPatronales = CASE WHEN EXISTS ((SELECT TOP 1 TRY_CAST([Value] as VARCHAR(MAX)) FROM @dtFiltros WHERE Catalogo = 'RegPatronales'))
                                          THEN (SELECT TOP 1 TRY_CAST([Value] as VARCHAR(MAX)) FROM @dtFiltros WHERE Catalogo = 'RegPatronales')
                                          ELSE NULL
                                   END

    SET @IDTipoNominaPeriodos = CASE WHEN EXISTS (SELECT TOP 1 TRY_CAST(item AS INT) FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'TipoNominaPeriodos'),','))
                                          THEN (SELECT TOP 1 TRY_CAST(item AS INT) FROM App.Split((SELECT TOP 1 VALUE FROM @dtFiltros WHERE Catalogo = 'TipoNominaPeriodos'),','))
                                          ELSE 0
                                   END

    IF(ISNULL(@IDTipoNominaPeriodos,0)=0 AND ISNULL(@Ejercicio,0)<>0)
	BEGIN
		RAISERROR('Debe seleccionar un cliente y tipo de nómina',16,1);
		RETURN;
	END

    IF(@IDsRegistrosPatronales IS NULL)
    BEGIN
        SELECT @IDsRegistrosPatronales = STRING_AGG(CAST(IDRegPatronal AS VARCHAR(10)), ', ')
        FROM RH.tblCatRegPatronal;
    END



    IF(@Ejercicio IS NOT NULL)
    BEGIN
     INSERT INTO @Periodos
	    SELECT *
	    	--IDPeriodo
	    	--,IDTipoNomina
	    	--,Ejercicio
	    	--,ClavePeriodo
	    	--,Descripcion
	    	--,FechaInicioPago
	    	--,FechaFinPago
	    	--,FechaInicioIncidencia
	    	--,FechaFinIncidencia
	    	--,Dias
	    	--,AnioInicio
	    	--,AnioFin
	    	--,MesInicio
	    	--,MesFin
	    	--,IDMes
	    	--,BimestreInicio
	    	--,BimestreFin
	    	--,Cerrado
	    	--,General
	    	--,Finiquito
	    	--,ISNULL(Especial,0)
	    FROM Nomina.tblCatPeriodos WITH (NOLOCK)
	    WHERE
             Ejercicio=@Ejercicio AND IDTipoNomina = @IDTipoNominaPeriodos

        IF EXISTS(SELECT TOP 1 1 FROM @Periodos)
        BEGIN
            SELECT  @FechaInicio = MIN(FechaInicioPago)
                ,@FechaFin = MAX(FechaFinPago)
            FROM @Periodos
        END

    END
    ELSE
    BEGIN
        INSERT INTO @Periodos
	    SELECT *
	    	--IDPeriodo
	    	--,IDTipoNomina
	    	--,Ejercicio
	    	--,ClavePeriodo
	    	--,Descripcion
	    	--,FechaInicioPago
	    	--,FechaFinPago
	    	--,FechaInicioIncidencia
	    	--,FechaFinIncidencia
	    	--,Dias
	    	--,AnioInicio
	    	--,AnioFin
	    	--,MesInicio
	    	--,MesFin
	    	--,IDMes
	    	--,BimestreInicio
	    	--,BimestreFin
	    	--,Cerrado
	    	--,General
	    	--,Finiquito
	    	--,ISNULL(Especial,0)
	    FROM Nomina.tblCatPeriodos WITH (NOLOCK)
	    WHERE
		(FechaFinPago BETWEEN @FechaInicio AND @FechaFin)

    END


    INSERT INTO @dtEmpleadosVigentes
    EXEC RH.spBuscarEmpleados
         @FechaIni  = @FechaInicio
        ,@FechaFin  = @FechaFin
        ,@dtFiltros = @Filtros
        ,@IDTipoNomina = @IDTipoNominaPeriodos
        ,@IDUsuario = @IDUsuario;

    IF OBJECT_ID('tempdb..#TemporalHistorialRegPatronalCTE') IS NOT NULL DROP TABLE #TemporalHistorialRegPatronalCTE

    CREATE TABLE #TemporalHistorialRegPatronalCTE (
        IDEmpleado INT,
        IDRegPatronal INT,
        FechaAlta DATE,
        FechaBaja DATE,
        RespetarAntiguedad BIT NULL,
        FechaAntiguedad DATE,
    );


    WITH AltasReingresos AS (
        SELECT
            IDEmpleado,
            IDRegPatronal,
            Fecha AS FechaAltaReingreso,
            RespetarAntiguedad
        FROM
            IMSS.tblMovAfiliatorios
        WHERE
            IDTipoMovimiento  IN (@ID_ALTA, @ID_REINGRESO)
            AND IDEmpleado    IN ( SELECT IDEMPLEADO FROM @dtEmpleadosVigentes )
            AND IDRegPatronal IN ( SELECT ITEM FROM app.Split(@IDsRegistrosPatronales,','))
    ),
    Bajas AS (
        SELECT
            IDEmpleado,
            IDRegPatronal,
            Fecha AS FechaBaja
        FROM
            IMSS.tblMovAfiliatorios
        WHERE
            IDTipoMovimiento = @ID_BAJA
            AND IDEmpleado  IN ( SELECT IDEMPLEADO FROM @dtEmpleadosVigentes )
            AND IDRegPatronal IN ( SELECT ITEM FROM app.Split(@IDsRegistrosPatronales,','))
    )
    INSERT INTO #TemporalHistorialRegPatronalCTE (IDEmpleado, IDRegPatronal, FechaAlta, FechaBaja,RespetarAntiguedad,FechaAntiguedad)
    SELECT
         AR.IDEmpleado
        ,AR.IDRegPatronal
        ,AR.FechaAltaReingreso AS FechaAlta
        ,COALESCE(B.FechaBaja, '9999-12-31')
        ,AR.RespetarAntiguedad
        ,(
            SELECT
                    MAX( Fecha )
    		FROM  IMSS.tblMovAfiliatorios ARA WITH(NOLOCK)
    		WHERE ARA.IDEmpleado = AR.IDEmpleado
                  AND ARA.IDTipoMovimiento IN (@ID_ALTA,@ID_REINGRESO)
    		      AND ARA.Fecha <= AR.FechaAltaReingreso
    		      AND ISNULL(ARA.RespetarAntiguedad,0) <> 1
        ) AS FechaAntiguedad
    FROM
        AltasReingresos AR
    LEFT JOIN
        Bajas B ON
        AR.IDEmpleado = B.IDEmpleado
        AND AR.IDRegPatronal = B.IDRegPatronal
        AND B.FechaBaja >= AR.FechaAltaReingreso
    LEFT JOIN
        Bajas B2 ON
        AR.IDEmpleado = B2.IDEmpleado
        AND AR.IDRegPatronal = B2.IDRegPatronal
        AND B2.FechaBaja > AR.FechaAltaReingreso
        AND B2.FechaBaja < COALESCE(B.FechaBaja, '9999-12-31')
    WHERE
        B2.IDEmpleado IS NULL;

    SELECT
         empleados.ClaveEmpleado                                                                            AS [CLAVE EMPLEADO]
        ,empleados.NOMBRECOMPLETO                                                                           AS [NOMBRE COMPLETO]
        ,FORMAT(historialRegPatronal.FechaAlta,'dd/MM/yyyy')                                                AS [Fecha de Alta]
        ,CASE WHEN historialRegPatronal.FechaBaja = '9999-12-31' THEN ' ' 
              ELSE FORMAT(historialRegPatronal.FechaBaja,'dd/MM/yyyy') END                                  AS [Fecha de Baja]
        ,FORMAT(historialRegPatronal.FechaAntiguedad,'dd/MM/yyyy')                                          AS [Fecha Antiguedad]
        ,UPPER(isnull(S.Descripcion,'SIN SUCURSAL'))                                                        AS [Sucursal]
        ,UPPER(isnull(CC.Descripcion,'SIN CENTRO DE COSTO'))                                                AS [Centro de Costo]
        ,catRegPatronal.RegistroPatronal                                                                    AS [RP  ]
        ,empleados.Paterno                                                                                  AS [Primer apellido]
        ,empleados.Materno                                                                                  AS [Segundo apellido]
        ,ISNULL(NULLIF(empleados.Nombre, '') + ' ' + NULLIF(empleados.SegundoNombre, ''), empleados.Nombre) AS [Nombre(s)]
        ,empleados.IMSS                                                                                     AS [NSS ]
        ,empleados.RFC                                                                                      AS [RFC ]
        ,empleados.CURP                                                                                     AS [CURP]
        ,FORMAT(historialRegPatronal.FechaAntiguedad,'dd/MM/yyyy')                                          AS [Fecha de ingreso del trabajador]
        ,ramaSueldosSalarios.ImporteTotal1                                                                  AS [Sueldos y Salarios Rayas y Jornales]
        ,ramaGraficacionAnual.ImporteTotal1                                                                 AS [Gratificación Anula (Aguinaldo)]
        ,ramaParticipacionUtilidades.ImporteTotal1                                                          AS [Participación de los Trabajadores en las Utilidades PTU]
        ,ramaReembolsoGastosMedicos.ImporteTotal1                                                           AS [Reembolso de Gastos Médicos Dentales y Hospitalarios]
        ,ramaFondoAhorroPatron.ImporteTotal1                                                                AS [Fondo de ahorro patrón]
        ,ramaFondoAhorroTrabajador.ImporteTotal1                                                            AS [Fondo de ahorro trabajador]
        ,ramaCajaAhorro.ImporteTotal1                                                                       AS [Caja de ahorro]
        ,ramaContribucionesTrabajador.ImporteTotal1                                                         AS [Contribuciones a Cargo del Trabajador Pagadas por el Patrón]
        ,ramaPremiosPuntualidad.ImporteTotal1                                                               AS [Premios por puntualidad]
        ,ramaPrimaSeguroVida.ImporteTotal1                                                                  AS [Prima de Seguro de vida]
        ,ramaSeguroGastosMedicosMayores.ImporteTotal1                                                       AS [Seguro de Gastos Médicos Mayores]
        ,ramaCuotasSindicales.ImporteTotal1                                                                 AS [Cuotas Sindicales Pagadas por el Patrón]
        ,ramaSubsidiosIncapacidad.ImporteTotal1                                                             AS [Subsidios por incapacidad]
        ,ramaBecasTrabajadoresHijos.ImporteTotal1                                                           AS [Becas para trabajadores y/o hijos]
        ,ramaHoraExtra.ImporteTotal1                                                                        AS [Hora extra]
        ,ramaPrimaDominical.ImporteTotal1                                                                   AS [Prima dominical]
        ,ramaPrimaVacacional.ImporteTotal1                                                                  AS [Prima vacacional]
        ,ramaPrimaAntiguedad.ImporteTotal1                                                                  AS [Prima por antigüedad]
        ,ramaPagosSeparacion.ImporteTotal1                                                                  AS [Pagos por separación]
        ,ramaSeguroRetiro.ImporteTotal1                                                                     AS [Seguro de retiro]        
        ,ramaIndemnizaciones.ImporteTotal1                                                                  AS [Indemnizaciones]        
        ,ramaReembolsoFuneral.ImporteTotal1                                                                 AS [Reembolso por funeral]        
        ,ramaCuotasSeguridadSocial.ImporteTotal1                                                            AS [Cuotas de seguridad social pagadas por el patrón]
        ,ramaComisiones.ImporteTotal1                                                                       AS [Comisiones]
        ,ramaValesDespensa.ImporteTotal1                                                                    AS [Vales de despensa]
        ,ramaValesRestaurante.ImporteTotal1                                                                 AS [Vales de restaurante]
        ,ramaValesGasolina.ImporteTotal1                                                                    AS [Vales de gasolina]
        ,ramaValesRopa.ImporteTotal1                                                                        AS [Vales de ropa]
        ,ramaAyudaRenta.ImporteTotal1                                                                       AS [Ayuda para renta]
        ,ramaAyudaArticulosEscolares.ImporteTotal1                                                          AS [Ayuda para artículos escolares]
        ,ramaAyudaAnteojos.ImporteTotal1                                                                    AS [Ayuda para anteojos]
        ,ramaAyudaTransporte.ImporteTotal1                                                                  AS [Ayuda para transporte]
        ,ramaAyudaGastosFuneral.ImporteTotal1                                                               AS [Ayuda para gastos de funeral]
        ,ramaOtrosIngresosSalarios.ImporteTotal1                                                            AS [Otros ingresos por salarios]
        ,ramaJubilacionesPensionesRetiro.ImporteTotal1                                                      AS [Jubilaciones, pensiones o haberes de retiro]
        ,ramaJubilacionesPensionesRetiroParcialidades.ImporteTotal1                                         AS [Jubilaciones, pensiones o haberes de retiro en parcialidades]
        ,ramaIngresosAccionesTitulos.ImporteTotal1                                                          AS [Ingresos en acciones o títulos valor que representan bienes]
        ,ramaAlimentacion.ImporteTotal1                                                                     AS [Alimentación]
        ,ramaHabitacion.ImporteTotal1                                                                       AS [Habitación]
        ,ramaPremiosAsistencia.ImporteTotal1                                                                AS [Premios por asistencia]
        ,ramaViaticos.ImporteTotal1                                                                         AS [Viáticos]
        ,(
          ramaSueldosSalarios.ImporteTotal1
          + ramaGraficacionAnual.ImporteTotal1
          + ramaParticipacionUtilidades.ImporteTotal1
          + ramaReembolsoGastosMedicos.ImporteTotal1
          + ramaFondoAhorroPatron.ImporteTotal1
          + ramaFondoAhorroTrabajador.ImporteTotal1
          + ramaCajaAhorro.ImporteTotal1
          + ramaContribucionesTrabajador.ImporteTotal1
          + ramaPremiosPuntualidad.ImporteTotal1
          + ramaPrimaSeguroVida.ImporteTotal1
          + ramaSeguroGastosMedicosMayores.ImporteTotal1
          + ramaCuotasSindicales.ImporteTotal1
          + ramaSubsidiosIncapacidad.ImporteTotal1
          + ramaBecasTrabajadoresHijos.ImporteTotal1
          + ramaHoraExtra.ImporteTotal1
          + ramaPrimaDominical.ImporteTotal1
          + ramaPrimaVacacional.ImporteTotal1
          + ramaPrimaAntiguedad.ImporteTotal1
          + ramaPagosSeparacion.ImporteTotal1
          + ramaSeguroRetiro.ImporteTotal1
          + ramaIndemnizaciones.ImporteTotal1
          + ramaReembolsoFuneral.ImporteTotal1
          + ramaCuotasSeguridadSocial.ImporteTotal1
          + ramaComisiones.ImporteTotal1
          + ramaValesDespensa.ImporteTotal1
          + ramaValesRestaurante.ImporteTotal1
          + ramaValesGasolina.ImporteTotal1
          + ramaValesRopa.ImporteTotal1
          + ramaAyudaRenta.ImporteTotal1
          + ramaAyudaArticulosEscolares.ImporteTotal1
          + ramaAyudaAnteojos.ImporteTotal1
          + ramaAyudaTransporte.ImporteTotal1
          + ramaAyudaGastosFuneral.ImporteTotal1
          + ramaOtrosIngresosSalarios.ImporteTotal1
          + ramaJubilacionesPensionesRetiro.ImporteTotal1
          + ramaJubilacionesPensionesRetiroParcialidades.ImporteTotal1
          + ramaIngresosAccionesTitulos.ImporteTotal1
          + ramaAlimentacion.ImporteTotal1
          + ramaHabitacion.ImporteTotal1
          + ramaPremiosAsistencia.ImporteTotal1
          + ramaViaticos.ImporteTotal1
        )                                                                                                   AS [Total]  
        ,''                                                                                                 AS [Excedentes por salario tope]
    FROM @dtEmpleadosVigentes empleados
        INNER JOIN #TemporalHistorialRegPatronalCTE historialRegPatronal
                ON empleados.IDEmpleado = historialRegPatronal.IDEmpleado
        INNER JOIN RH.tblCatRegPatronal catRegPatronal
                ON catRegPatronal.IDRegPatronal = historialRegPatronal.IDRegPatronal
        LEFT JOIN [RH].[tblCentroCostoEmpleado] CCE WITH(NOLOCK) 
                ON CCE.IDEmpleado = empleados.IDEmpleado 
                AND CCE.FechaIni<= historialRegPatronal.FechaBaja 
                AND CCE.FechaFin >= historialRegPatronal.FechaBaja
        LEFT JOIN [RH].[tblCatCentroCosto] CC WITH(NOLOCK) 
                ON CC.IDCentroCosto = CCE.IDCentroCosto
        LEFT JOIN [RH].[tblSucursalEmpleado] SE WITH(NOLOCK)
                ON  SE.IDEmpleado = empleados.IDEmpleado 
                AND SE.FechaIni <= historialRegPatronal.FechaBaja  
                AND SE.FechaFin >= historialRegPatronal.FechaBaja  
        LEFT JOIN [RH].[tblCatSucursales] S WITH(NOLOCK) 
                ON SE.IDSucursal = S.IDSucursal
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@SueldosSalarios) AS ramaSueldosSalarios
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@GraficacionAnual) AS ramaGraficacionAnual
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@ParticipacionUtilidades) AS ramaParticipacionUtilidades
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@ReembolsoGastosMedicos) AS ramaReembolsoGastosMedicos
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@FondoAhorroPatron) AS ramaFondoAhorroPatron
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@FondoAhorroTrabajador) AS ramaFondoAhorroTrabajador
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@CajaAhorro) AS ramaCajaAhorro
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@ContribucionesTrabajador) AS ramaContribucionesTrabajador
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@PremiosPuntualidad) AS ramaPremiosPuntualidad
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@PrimaSeguroVida) AS ramaPrimaSeguroVida
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@SeguroGastosMedicosMayores) AS ramaSeguroGastosMedicosMayores
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@CuotasSindicales) AS ramaCuotasSindicales
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@SubsidiosIncapacidad) AS ramaSubsidiosIncapacidad
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@BecasTrabajadoresHijos) AS ramaBecasTrabajadoresHijos
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@HoraExtra) AS ramaHoraExtra
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@PrimaDominical) AS ramaPrimaDominical
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@PrimaVacacional) AS ramaPrimaVacacional
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@PrimaAntiguedad) AS ramaPrimaAntiguedad
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@PagosSeparacion) AS ramaPagosSeparacion
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@SeguroRetiro) AS ramaSeguroRetiro
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@Indemnizaciones) AS ramaIndemnizaciones
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@ReembolsoFuneral) AS ramaReembolsoFuneral
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@CuotasSeguridadSocial) AS ramaCuotasSeguridadSocial
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@Comisiones) AS ramaComisiones
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@ValesDespensa) AS ramaValesDespensa
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@ValesRestaurante) AS ramaValesRestaurante
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@ValesGasolina) AS ramaValesGasolina
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@ValesRopa) AS ramaValesRopa
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@AyudaRenta) AS ramaAyudaRenta
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@AyudaArticulosEscolares) AS ramaAyudaArticulosEscolares
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@AyudaAnteojos) AS ramaAyudaAnteojos
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@AyudaTransporte) AS ramaAyudaTransporte
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@AyudaGastosFuneral) AS ramaAyudaGastosFuneral
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@OtrosIngresosSalarios) AS ramaOtrosIngresosSalarios
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@JubilacionesPensionesRetiro) AS ramaJubilacionesPensionesRetiro
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@JubilacionesPensionesRetiroParcialidades) AS ramaJubilacionesPensionesRetiroParcialidades
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@IngresosAccionesTitulos) AS ramaIngresosAccionesTitulos
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@Alimentacion) AS ramaAlimentacion
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@Habitacion) AS ramaHabitacion
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@PremiosAsistencia) AS ramaPremiosAsistencia
        CROSS APPLY [IMSS].[fnObtenerAcumuladoPorRamaDictamenIMSS] (historialRegPatronal.IDEmpleado,historialRegPatronal.IDRegPatronal,historialRegPatronal.FechaAlta,historialRegPatronal.FechaBaja,@Periodos,@Viaticos) AS ramaViaticos
    WHERE historialRegPatronal.FechaAlta<@FechaInicio AND historialRegPatronal.FechaBaja>@FechaFin
       OR historialRegPatronal.FechaBaja BETWEEN @FechaInicio AND @FechaFin
       OR historialRegPatronal.FechaAlta BETWEEN @FechaInicio AND @FechaFin
    ORDER BY empleados.ClaveEmpleado,historialRegPatronal.FechaAlta

END
GO

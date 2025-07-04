USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spIUControlBonosObjetivos]
(
     @IDControlBonosObjetivos INT = 0
    ,@Descripcion VARCHAR(MAX)
    ,@Ejercicio INT
    ,@IDTipoNomina INT
    ,@FechaReferencia DATE    
    ,@FechaInformacionColaboradores DATE
    ,@DiasCriterioMes DECIMAL(18,2)
    ,@DiasAnio DECIMAL(18,2)
    ,@AplicaMatrizPagoBono BIT
    ,@DescuentaIncapacidad BIT
    ,@TiposIncapacidadDescontar VARCHAR(MAX) = NULL
    ,@DescuentaAusentismos BIT
    ,@AusentismosDescontar VARCHAR(MAX) = NULL
    ,@FechaInicioIncidenciaIncapacidad DATE = NULL
    ,@FechaFinIncidenciaIncapacidad DATE = NULL
    ,@PesoEvaluacionJefe DECIMAL(18,2)
    ,@PesoEvaluacionOtros DECIMAL(18,2)
    ,@TopeCumplimientoObjetivos DECIMAL(18,2)
    ,@PresupuestoUtilidadBruta DECIMAL(18,2)
    ,@ResultadoEjercicio DECIMAL(18,2)
    ,@PorcentajeUtilidadMinima DECIMAL(18,4)
    ,@TopeFactorUtilidad DECIMAL(18,4)
    ,@PresupuestoObjetivosPersonales DECIMAL(18,2)
    ,@ResultadoMinimoBono DECIMAL(18,2)
    ,@TopeFactorObjetivos DECIMAL(18,2)
    ,@Complemento DECIMAL(18,2)
    ,@IDConceptoComplemento INT = NULL
    ,@IDPeriodoComplemento INT = NULL
    ,@IDConceptoBono INT = NULL
    ,@IDPeriodoBono INT = NULL    
    ,@AfectarSalarioDiarioReal BIT
    ,@IDReporteBasico INT = NULL
    ,@IDUsuario INT
) AS
BEGIN
    DECLARE 
        @OldJSON VARCHAR(MAX) = '',
        @NewJSON VARCHAR(MAX),
        @NombreSP VARCHAR(MAX) = '[Nomina].[spIUControlBonosObjetivos]',
        @Tabla VARCHAR(MAX) = '[Nomina].[tblControlBonosObjetivos]',
        @Accion VARCHAR(20) = '';

    SET @Descripcion = UPPER(@Descripcion)

    IF @DescuentaIncapacidad = 0
    BEGIN
        SET @TiposIncapacidadDescontar = NULL;        
    END
    
    IF @DescuentaAusentismos = 0
    BEGIN
        SET @AusentismosDescontar = NULL;
    END

    IF @DescuentaAusentismos = 0 AND @DescuentaIncapacidad = 0
    BEGIN
        SET @FechaInicioIncidenciaIncapacidad = NULL;
        SET @FechaFinIncidenciaIncapacidad = NULL;
    END

    IF @AplicaMatrizPagoBono = 0
    BEGIN
        SET @PesoEvaluacionJefe = NULL;
        SET @PesoEvaluacionOtros = NULL;

        IF ISNULL(@IDControlBonosObjetivos, 0) <>0
        BEGIN
            DELETE [Nomina].[tblControlBonosObjetivosProyectos]            
            WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos;
        END
    END

    IF @IDConceptoComplemento = @IDConceptoBono
    BEGIN
        RAISERROR('El concepto de bono y el concepto de complemento no pueden ser el mismo', 16, 1);
        RETURN;
    END

    IF (@IDControlBonosObjetivos = 0 OR @IDControlBonosObjetivos IS NULL)
    BEGIN
        INSERT INTO [Nomina].[tblControlBonosObjetivos] (
             Descripcion
            ,Ejercicio
            ,IDTipoNomina
            ,FechaReferencia
            ,FechaInformacionColaboradores
            ,DiasCriterioMes
            ,DiasAnio
            ,AplicaMatrizPagoBono
            ,DescuentaIncapacidad
            ,TiposIncapacidadDescontar
            ,DescuentaAusentismos
            ,AusentismosDescontar
            ,FechaInicioIncidenciaIncapacidad
            ,FechaFinIncidenciaIncapacidad
            ,PesoEvaluacionJefe
            ,PesoEvaluacionOtros
            ,TopeCumplimientoObjetivos
            ,PresupuestoUtilidadBruta
            ,ResultadoEjercicio
            ,PorcentajeUtilidadMinima
            ,TopeFactorUtilidad
            ,PresupuestoObjetivosPersonales
            ,ResultadoMinimoBono
            ,TopeFactorObjetivos
            ,Complemento
            ,IDConceptoComplemento
            ,IDPeriodoComplemento
            ,IDConceptoBono
            ,IDPeriodoBono    
            ,AfectarSalarioDiarioReal
            ,IDReporteBasico
            ,Aplicado
            ,IDUsuario
        )
        VALUES (
             @Descripcion
            ,@Ejercicio
            ,@IDTipoNomina
            ,@FechaReferencia
            ,@FechaInformacionColaboradores
            ,@DiasCriterioMes
            ,@DiasAnio
            ,@AplicaMatrizPagoBono
            ,@DescuentaIncapacidad
            ,@TiposIncapacidadDescontar
            ,@DescuentaAusentismos
            ,@AusentismosDescontar
            ,@FechaInicioIncidenciaIncapacidad
            ,@FechaFinIncidenciaIncapacidad
            ,@PesoEvaluacionJefe
            ,@PesoEvaluacionOtros
            ,@TopeCumplimientoObjetivos
            ,@PresupuestoUtilidadBruta
            ,@ResultadoEjercicio
            ,@PorcentajeUtilidadMinima
            ,@TopeFactorUtilidad
            ,@PresupuestoObjetivosPersonales
            ,@ResultadoMinimoBono
            ,@TopeFactorObjetivos
            ,@Complemento
            ,@IDConceptoComplemento
            ,@IDPeriodoComplemento
            ,@IDConceptoBono
            ,@IDPeriodoBono
            ,@AfectarSalarioDiarioReal
            ,@IDReporteBasico
            ,0
            ,@IDUsuario
        );

        SELECT @IDControlBonosObjetivos = SCOPE_IDENTITY();

        SELECT @NewJSON = a.JSON,
               @Accion = 'INSERT'
        FROM [Nomina].[tblControlBonosObjetivos] b
            CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT 
             b.IDControlBonosObjetivos
            ,b.Descripcion
            ,b.Ejercicio
            ,b.IDTipoNomina
            ,b.FechaReferencia
            ,b.FechaInformacionColaboradores
            ,b.DiasCriterioMes
            ,b.DiasAnio
            ,b.AplicaMatrizPagoBono
            ,b.DescuentaIncapacidad
            ,b.TiposIncapacidadDescontar
            ,b.DescuentaAusentismos
            ,b.AusentismosDescontar
            ,b.FechaInicioIncidenciaIncapacidad
            ,b.FechaFinIncidenciaIncapacidad
            ,b.PesoEvaluacionJefe
            ,b.PesoEvaluacionOtros
            ,b.TopeCumplimientoObjetivos
            ,b.PresupuestoUtilidadBruta
            ,b.ResultadoEjercicio
            ,b.PorcentajeUtilidadMinima
            ,b.TopeFactorUtilidad
            ,b.PresupuestoObjetivosPersonales
            ,b.ResultadoMinimoBono
            ,b.TopeFactorObjetivos
            ,b.Complemento
            ,b.IDConceptoComplemento
            ,b.IDPeriodoComplemento
            ,b.IDConceptoBono
            ,b.IDPeriodoBono    
            ,b.AfectarSalarioDiarioReal
            ,b.IDReporteBasico
            ,b.Aplicado
            ,b.IDUsuario
            
            
            FOR XML RAW))) a
        WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos;
    END
    ELSE
    BEGIN
        SELECT @OldJSON = a.JSON,
               @Accion = 'UPDATE'
        FROM [Nomina].[tblControlBonosObjetivos] b
            CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT 
             b.IDControlBonosObjetivos
            ,b.Descripcion
            ,b.Ejercicio
            ,b.IDTipoNomina
            ,b.FechaReferencia
            ,b.FechaInformacionColaboradores
            ,b.DiasCriterioMes
            ,b.DiasAnio
            ,b.AplicaMatrizPagoBono
            ,b.DescuentaIncapacidad
            ,b.TiposIncapacidadDescontar
            ,b.DescuentaAusentismos
            ,b.AusentismosDescontar
            ,b.FechaInicioIncidenciaIncapacidad
            ,b.FechaFinIncidenciaIncapacidad
            ,b.PesoEvaluacionJefe
            ,b.PesoEvaluacionOtros
            ,b.TopeCumplimientoObjetivos
            ,b.PresupuestoUtilidadBruta
            ,b.ResultadoEjercicio
            ,b.PorcentajeUtilidadMinima
            ,b.TopeFactorUtilidad
            ,b.PresupuestoObjetivosPersonales
            ,b.ResultadoMinimoBono
            ,b.TopeFactorObjetivos
            ,b.Complemento
            ,b.IDConceptoComplemento
            ,b.IDPeriodoComplemento
            ,b.IDConceptoBono
            ,b.IDPeriodoBono    
            ,b.AfectarSalarioDiarioReal
            ,b.IDReporteBasico
            ,b.Aplicado
            ,b.IDUsuario
            
            
            
            
             FOR XML RAW))) a
        WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos;

        UPDATE [Nomina].[tblControlBonosObjetivos]
        SET  Descripcion = @Descripcion
            ,Ejercicio = @Ejercicio
            ,IDTipoNomina = @IDTipoNomina
            ,FechaReferencia = @FechaReferencia
            ,FechaInformacionColaboradores = @FechaInformacionColaboradores
            ,DiasCriterioMes = @DiasCriterioMes
            ,DiasAnio = @DiasAnio
            ,AplicaMatrizPagoBono = @AplicaMatrizPagoBono
            ,DescuentaIncapacidad = @DescuentaIncapacidad
            ,TiposIncapacidadDescontar = @TiposIncapacidadDescontar
            ,DescuentaAusentismos = @DescuentaAusentismos
            ,AusentismosDescontar = @AusentismosDescontar
            ,FechaInicioIncidenciaIncapacidad = @FechaInicioIncidenciaIncapacidad
            ,FechaFinIncidenciaIncapacidad = @FechaFinIncidenciaIncapacidad
            ,PesoEvaluacionJefe = @PesoEvaluacionJefe
            ,PesoEvaluacionOtros = @PesoEvaluacionOtros
            ,TopeCumplimientoObjetivos = @TopeCumplimientoObjetivos
            ,PresupuestoUtilidadBruta = @PresupuestoUtilidadBruta
            ,ResultadoEjercicio = @ResultadoEjercicio
            ,PorcentajeUtilidadMinima = @PorcentajeUtilidadMinima
            ,TopeFactorUtilidad = @TopeFactorUtilidad
            ,PresupuestoObjetivosPersonales = @PresupuestoObjetivosPersonales
            ,ResultadoMinimoBono = @ResultadoMinimoBono
            ,TopeFactorObjetivos = @TopeFactorObjetivos
            ,Complemento = @Complemento
            ,IDConceptoComplemento = @IDConceptoComplemento
            ,IDPeriodoComplemento = @IDPeriodoComplemento
            ,IDConceptoBono = @IDConceptoBono
            ,IDPeriodoBono = @IDPeriodoBono            
            ,AfectarSalarioDiarioReal = @AfectarSalarioDiarioReal
            ,IDReporteBasico = @IDReporteBasico
            ,IDUsuario = @IDUsuario
        WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos;

        SELECT @NewJSON = a.JSON,
               @Accion = 'INSERT'
        FROM [Nomina].[tblControlBonosObjetivos] b
            CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT 
             b.IDControlBonosObjetivos
            ,b.Descripcion
            ,b.Ejercicio
            ,b.IDTipoNomina
            ,b.FechaReferencia
            ,b.FechaInformacionColaboradores
            ,b.DiasCriterioMes
            ,b.DiasAnio
            ,b.AplicaMatrizPagoBono
            ,b.DescuentaIncapacidad
            ,b.TiposIncapacidadDescontar
            ,b.DescuentaAusentismos
            ,b.AusentismosDescontar
            ,b.FechaInicioIncidenciaIncapacidad
            ,b.FechaFinIncidenciaIncapacidad
            ,b.PesoEvaluacionJefe
            ,b.PesoEvaluacionOtros
            ,b.TopeCumplimientoObjetivos
            ,b.PresupuestoUtilidadBruta
            ,b.ResultadoEjercicio
            ,b.PorcentajeUtilidadMinima
            ,b.TopeFactorUtilidad
            ,b.PresupuestoObjetivosPersonales
            ,b.ResultadoMinimoBono
            ,b.TopeFactorObjetivos
            ,b.Complemento
            ,b.IDConceptoComplemento
            ,b.IDPeriodoComplemento
            ,b.IDConceptoBono
            ,b.IDPeriodoBono    
            ,b.AfectarSalarioDiarioReal
            ,b.IDReporteBasico
            ,b.Aplicado
            ,b.IDUsuario
            
            
            FOR XML RAW))) a
        WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos;
    END;

    EXEC [Auditoria].[spIAuditoria]
        @IDUsuario      = @IDUsuario,
        @Tabla          = @Tabla,
        @Procedimiento  = @NombreSP,
        @Accion         = @Accion,
        @NewData        = @NewJSON,
        @OldData        = @OldJSON;

    SELECT * 
    FROM [Nomina].[tblControlBonosObjetivos]
    WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos;
END;
GO

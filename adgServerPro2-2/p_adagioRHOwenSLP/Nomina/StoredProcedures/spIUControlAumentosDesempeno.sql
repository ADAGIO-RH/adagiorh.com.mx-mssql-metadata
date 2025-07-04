USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Nomina].[spIUControlAumentosDesempeno]
(
     @IDControlAumentosDesempeno INT = 0
    ,@Descripcion VARCHAR(MAX)
    ,@Ejercicio INT
    ,@FechaReferencia DATE
    ,@FechaMovAfiliatorio DATE
    ,@FechaInformacionColaboradores DATE
    ,@IDRazonMovimiento INT = NULL    
    ,@DiasSueldoMensual DECIMAL(18,4)
    ,@TopeCumplimientoObjetivo DECIMAL(18,2)
    ,@PesoEvaluacionJefe DECIMAL(18,2)
    ,@PesoEvaluacionOtros DECIMAL(18,2)
    ,@PesoEvaluaciones DECIMAL(18,2)
    ,@PesoObjetivos DECIMAL(18,2)    
    ,@AfectarSalarioDiarioReal BIT
    ,@RespetarSalarioVariable BIT    
    ,@MetaIncrementoSalarialGeneral DECIMAL(18,4)
    ,@IDReporteBasico INT = NULL
    ,@IDUsuario INT


) AS
BEGIN
    DECLARE 
        @OldJSON VARCHAR(MAX) = '',
        @NewJSON VARCHAR(MAX),
        @NombreSP VARCHAR(MAX) = '[Nomina].[spIUControlAumentosDesempeno]',
        @Tabla VARCHAR(MAX) = '[Nomina].[tblControlAumentosDesempeno]',
        @Accion VARCHAR(20) = '';

    SET @Descripcion = UPPER(@Descripcion)

    IF @PesoObjetivos <= 0
    BEGIN
        DELETE FROM [Nomina].[tblControlAumentosDesempenoCiclosMedicion]
        WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno;
    END

    
    

    IF (@IDControlAumentosDesempeno = 0 OR @IDControlAumentosDesempeno IS NULL)
    BEGIN
        
        INSERT INTO [Nomina].[tblControlAumentosDesempeno] (
             Descripcion
            ,Ejercicio
            ,FechaReferencia
            ,FechaMovAfiliatorio
            ,FechaInformacionColaboradores
            ,DiasSueldoMensual
            ,TopeCumplimientoObjetivo
            ,PesoEvaluacionJefe
            ,PesoEvaluacionOtros
            ,PesoEvaluaciones
            ,PesoObjetivos            
            ,IDRazonMovimiento
            ,AfectarSalarioDiarioReal
            ,RespetarSalarioVariable
            ,MetaIncrementoSalarialGeneral
            ,Aplicado
            ,IDReporteBasico
            ,IDUsuario


        )
        VALUES (
             @Descripcion
            ,@Ejercicio
            ,@FechaReferencia
            ,@FechaMovAfiliatorio
            ,@FechaInformacionColaboradores
            ,@DiasSueldoMensual
            ,@TopeCumplimientoObjetivo
            ,@PesoEvaluacionJefe
            ,@PesoEvaluacionOtros
            ,@PesoEvaluaciones
            ,@PesoObjetivos            
            ,@IDRazonMovimiento
            ,@AfectarSalarioDiarioReal
            ,@RespetarSalarioVariable
            ,@MetaIncrementoSalarialGeneral
            ,0
            ,@IDReporteBasico
            ,@IDUsuario


        );

        SELECT @IDControlAumentosDesempeno = SCOPE_IDENTITY();

        SELECT @NewJSON = a.JSON,
               @Accion = 'INSERT'
        FROM [Nomina].[tblControlAumentosDesempeno] b
            CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT 
             b.IDControlAumentosDesempeno
            ,b.Descripcion
            ,b.Ejercicio
            ,b.FechaReferencia
            ,b.FechaMovAfiliatorio
            ,b.FechaInformacionColaboradores
            ,b.DiasSueldoMensual
            ,b.TopeCumplimientoObjetivo
            ,b.PesoEvaluacionJefe
            ,b.PesoEvaluacionOtros
            ,b.PesoEvaluaciones
            ,b.PesoObjetivos
            ,b.IDTabuladorDesempeno
            ,b.IDTabuladorNivelSalarialAumentosDesempeno
            ,b.IDRazonMovimiento
            ,AfectarSalarioDiarioReal
            ,RespetarSalarioVariable
            ,MetaIncrementoSalarialGeneral
            ,Aplicado
            ,IDReporteBasico
            ,IDUsuario            
             FOR XML RAW))) a
        WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno;
    END
    ELSE
    BEGIN
        SELECT @OldJSON = a.JSON,
               @Accion = 'UPDATE'
        FROM [Nomina].[tblControlAumentosDesempeno] b
            CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT 
             b.IDControlAumentosDesempeno
            ,b.Descripcion
            ,b.Ejercicio
            ,b.FechaReferencia
            ,b.FechaMovAfiliatorio            
            ,b.FechaInformacionColaboradores
            ,b.DiasSueldoMensual
            ,b.TopeCumplimientoObjetivo
            ,b.PesoEvaluacionJefe
            ,b.PesoEvaluacionOtros
            ,b.PesoEvaluaciones
            ,b.PesoObjetivos
            ,b.IDTabuladorDesempeno
            ,b.IDTabuladorNivelSalarialAumentosDesempeno
            ,b.IDRazonMovimiento
            ,b.AfectarSalarioDiarioReal
            ,b.RespetarSalarioVariable
            ,b.MetaIncrementoSalarialGeneral
            ,b.Aplicado
            ,b.IDReporteBasico
            ,b.IDUsuario            
            FOR XML RAW))) a
        WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno;

        UPDATE [Nomina].[tblControlAumentosDesempeno]
        SET Descripcion = @Descripcion,
            Ejercicio = @Ejercicio,
            FechaReferencia = @FechaReferencia,      
            FechaInformacionColaboradores = @FechaInformacionColaboradores,
            FechaMovAfiliatorio = @FechaMovAfiliatorio,            
            DiasSueldoMensual = @DiasSueldoMensual,
            TopeCumplimientoObjetivo = @TopeCumplimientoObjetivo,
            PesoEvaluacionJefe = @PesoEvaluacionJefe,
            PesoEvaluacionOtros = @PesoEvaluacionOtros,
            PesoEvaluaciones = @PesoEvaluaciones,
            PesoObjetivos = @PesoObjetivos,            
            IDRazonMovimiento = @IDRazonMovimiento,
            AfectarSalarioDiarioReal = @AfectarSalarioDiarioReal,
            RespetarSalarioVariable = @RespetarSalarioVariable,      
            MetaIncrementoSalarialGeneral = @MetaIncrementoSalarialGeneral,
            IDReporteBasico = @IDReporteBasico,
            IDUsuario = @IDUsuario


        WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno;

        SELECT @NewJSON = a.JSON
        FROM [Nomina].[tblControlAumentosDesempeno] b
            CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (
                    SELECT  
                    b.IDControlAumentosDesempeno
                    ,b.Descripcion
                    ,b.Ejercicio
                    ,b.FechaReferencia
                    ,b.FechaMovAfiliatorio                    
                    ,b.FechaInformacionColaboradores
                    ,b.DiasSueldoMensual
                    ,b.TopeCumplimientoObjetivo
                    ,b.PesoEvaluacionJefe
                    ,b.PesoEvaluacionOtros
                    ,b.PesoEvaluaciones
                    ,b.PesoObjetivos
                    ,b.IDTabuladorDesempeno
                    ,b.IDTabuladorNivelSalarialAumentosDesempeno
                    ,b.IDRazonMovimiento
                    ,b.AfectarSalarioDiarioReal
                    ,b.RespetarSalarioVariable
                    ,b.MetaIncrementoSalarialGeneral
                    ,b.Aplicado
                    ,b.IDReporteBasico
                    ,b.IDUsuario
                     FOR XML RAW))) a
        WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno;
    END;

    EXEC [Auditoria].[spIAuditoria]
        @IDUsuario      = @IDUsuario,
        @Tabla          = @Tabla,
        @Procedimiento  = @NombreSP,
        @Accion         = @Accion,
        @NewData        = @NewJSON,
        @OldData        = @OldJSON;

    SELECT * 
    FROM [Nomina].[tblControlAumentosDesempeno]
    WHERE IDControlAumentosDesempeno = @IDControlAumentosDesempeno;
END;
GO

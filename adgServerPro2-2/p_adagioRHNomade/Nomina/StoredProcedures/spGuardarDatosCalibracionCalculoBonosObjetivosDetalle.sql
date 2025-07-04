USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spGuardarDatosCalibracionCalculoBonosObjetivosDetalle]
    @dtCalibracion [Nomina].[dtCalibracionControlBonosObjetivos] READONLY,
    @IDUsuario INT
AS
BEGIN
    DECLARE 
        @OldJSON VARCHAR(MAX) = '',
        @NewJSON VARCHAR(MAX),
        @IDControlBonosObjetivos INT,
        @NombreSP VARCHAR(MAX) = '[Nomina].[spGuardarDatosCalibracionCalculoBonosObjetivosDetalle]',
        @Tabla VARCHAR(MAX) = '[Nomina].[tblControlBonosObjetivosDetalle]',
        @Accion VARCHAR(20) = 'UPDATE';

        SELECT TOP 1 @IDControlBonosObjetivos = D.IDControlBonosObjetivos
        FROM @dtCalibracion C
        INNER JOIN [Nomina].[tblControlBonosObjetivosDetalle] D
            ON D.IDControlBonosObjetivosDetalle = C.IDControlBonosObjetivosDetalle;
    

    -- Actualizar datos
    UPDATE d
    SET d.CalibracionNivelSalarial = c.CalibracionNivelSalarial,
        d.CalibracionDias = c.CalibracionDias,
        d.CalibracionIncapacidades = c.CalibracionIncapacidades,
        d.CalibracionAusentismos = c.CalibracionAusentismos,
        d.CalibracionDiasEjercicio = c.CalibracionDiasEjercicio,
        d.CalibracionTotalEvaluacionPorcentual = c.CalibracionTotalEvaluacionPorcentual,
        d.CalibracionTotalObjetivos = c.CalibracionTotalObjetivos,
        d.CalibracionFactorObjetivos = c.CalibracionFactorObjetivos,        
        d.CalibracionFactorParaBono = c.CalibracionFactorParaBono,
        d.CalibracionResultadoUtilidadDesempeno = c.CalibracionResultadoUtilidadDesempeno,
        d.CalibracionBonoAnual = c.CalibracionBonoAnual,
        d.CalibracionPTU = c.CalibracionPTU,
        d.CalibracionComplemento = c.CalibracionComplemento,
        d.CalibracionBonoFinal = c.CalibracionBonoFinal,        
        d.ExcluirColaborador = c.ExcluirColaborador
    FROM [Nomina].[tblControlBonosObjetivosDetalle] d
    INNER JOIN @dtCalibracion c ON d.IDControlBonosObjetivosDetalle = c.IDControlBonosObjetivosDetalle;

    -- Obtener JSON de nuevos datos
    SELECT @NewJSON = a.JSON
                FROM [Nomina].[tblControlBonosObjetivos] b
                CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.IDControlBonosObjetivos,b.Descripcion,b.Ejercicio,b.Aplicado FOR XML RAW))) a
                WHERE b.IDControlBonosObjetivos = @IDControlBonosObjetivos;

    -- Registrar auditoria
    EXEC [Auditoria].[spIAuditoria]
        @IDUsuario = @IDUsuario,
        @Tabla = @Tabla,
        @Procedimiento = @NombreSP,
        @Accion = @Accion,
        @NewData = @NewJSON,
        @OldData = @OldJSON;
END
GO

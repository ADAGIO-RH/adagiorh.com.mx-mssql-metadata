USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spGuardarDatosCalibracionCalculoAumentoDesempenoDetalle]
    @dtCalibracion [Nomina].[dtCalibracionControlAumentosDesempeno] READONLY,
    @IDUsuario INT
AS
BEGIN
    DECLARE 
        @OldJSON VARCHAR(MAX) = '',
        @NewJSON VARCHAR(MAX),
        @NombreSP VARCHAR(MAX) = '[Nomina].[spGuardarDatosCalibracionCalculoAumentoDesempenoDetalle]',
        @Tabla VARCHAR(MAX) = '[Nomina].[TblControlAumentosDesempenoDetalle]',
        @Accion VARCHAR(20) = 'UPDATE',
        @IDControlAumentosDesempeno INT;

    -- Obtener JSON de datos anteriores
    SELECT TOP 1 @IDControlAumentosDesempeno = D.IDControlAumentosDesempeno
    FROM @dtCalibracion C
    INNER JOIN [Nomina].[TblControlAumentosDesempenoDetalle] D
        ON D.IDControlAumentosDesempenoDetalle = C.IDControlAumentosDesempenoDetalle;

    -- Actualizar datos
    UPDATE d
    SET d.NivelSalarialCalibrado = c.NivelSalarialCalibrado,
        d.TotalEvaluacionCalibrado = c.TotalEvaluacionCalibrado,
        d.TotalObjetivosCalibrado = c.TotalObjetivosCalibrado,
        d.PorcentajeIncrementoCalibrado = c.PorcentajeIncrementoCalibrado,
        d.SueldoCalibrado = c.SueldoCalibrado,
        d.ExcluirColaborador = c.ExcluirColaborador
    FROM [Nomina].[TblControlAumentosDesempenoDetalle] d
    INNER JOIN @dtCalibracion c ON d.IDControlAumentosDesempenoDetalle = c.IDControlAumentosDesempenoDetalle;

    -- Obtener JSON de nuevos datos
    SELECT @NewJSON = a.JSON
    FROM [Nomina].[tblControlAumentosDesempeno] b
    CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.IDControlAumentosDesempeno,b.Descripcion,b.Ejercicio,b.Aplicado FOR XML RAW))) a
    WHERE b.IDControlAumentosDesempeno = @IDControlAumentosDesempeno;

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

USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spIUTabuladorNivelSalarialCompensacionesDetalle]
(
    @IDTabuladorNivelSalarialCompensacionesDetalle INT = 0,
    @IDTabuladorNivelSalarialCompensaciones INT,
    @Nivel INT,
    @Minimo DECIMAL(18,4),
    @Maximo DECIMAL(18,4),
    @PorcentajeResultadoUtilidad DECIMAL(18,4),
    @PorcentajeDesempenoEvaluacionPersonal DECIMAL(18,4),
    @PorcentajeBonoAnual DECIMAL(18,4),
    @IDUsuario INT
) AS
BEGIN
    DECLARE 
        @OldJSON VARCHAR(MAX) = '',
        @NewJSON VARCHAR(MAX),
        @NombreSP VARCHAR(MAX) = '[Nomina].[spIUTabuladorNivelSalarialCompensacionesDetalle]',
        @Tabla VARCHAR(MAX) = '[Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle]',
        @Accion VARCHAR(20) = '';

    IF (@IDTabuladorNivelSalarialCompensacionesDetalle = 0 OR @IDTabuladorNivelSalarialCompensacionesDetalle IS NULL)
    BEGIN
        SET @Accion = 'INSERT';
        
        INSERT INTO [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle]
        (
            IDTabuladorNivelSalarialCompensaciones,
            Nivel,
            Minimo,
            Maximo,
            PorcentajeResultadoUtilidad,
            PorcentajeDesempenoEvaluacionPersonal,
            PorcentajeBonoAnual
        )
        VALUES
        (
            @IDTabuladorNivelSalarialCompensaciones,
            @Nivel,
            @Minimo,
            @Maximo,
            @PorcentajeResultadoUtilidad,
            @PorcentajeDesempenoEvaluacionPersonal,
            @PorcentajeBonoAnual
        );

        SET @IDTabuladorNivelSalarialCompensacionesDetalle = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        SET @Accion = 'UPDATE';

        SELECT @OldJSON = a.JSON
        FROM [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
        WHERE IDTabuladorNivelSalarialCompensacionesDetalle = @IDTabuladorNivelSalarialCompensacionesDetalle;

        UPDATE [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle]
        SET 
            IDTabuladorNivelSalarialCompensaciones = @IDTabuladorNivelSalarialCompensaciones,
            Nivel = @Nivel,
            Minimo = @Minimo,
            Maximo = @Maximo,
            PorcentajeResultadoUtilidad = @PorcentajeResultadoUtilidad,
            PorcentajeDesempenoEvaluacionPersonal = @PorcentajeDesempenoEvaluacionPersonal,
            PorcentajeBonoAnual = @PorcentajeBonoAnual
        WHERE IDTabuladorNivelSalarialCompensacionesDetalle = @IDTabuladorNivelSalarialCompensacionesDetalle;
    END;

    SELECT @NewJSON = a.JSON
    FROM [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle] b
    CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
    WHERE IDTabuladorNivelSalarialCompensacionesDetalle = @IDTabuladorNivelSalarialCompensacionesDetalle;

    EXEC [Auditoria].[spIAuditoria]
        @IDUsuario      = @IDUsuario,
        @Tabla          = @Tabla,
        @Procedimiento  = @NombreSP,
        @Accion         = @Accion,
        @NewData        = @NewJSON,
        @OldData        = @OldJSON;

    SELECT * 
    FROM [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle]
    WHERE IDTabuladorNivelSalarialCompensacionesDetalle = @IDTabuladorNivelSalarialCompensacionesDetalle;
END;
GO

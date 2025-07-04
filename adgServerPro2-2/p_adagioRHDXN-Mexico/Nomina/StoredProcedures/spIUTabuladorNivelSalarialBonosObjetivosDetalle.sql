USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spIUTabuladorNivelSalarialBonosObjetivosDetalle]
(
    @IDTabuladorNivelSalarialBonosObjetivosDetalle INT = 0,
    @IDTabuladorNivelSalarialBonosObjetivos INT,
    @Nivel INT,
    @PorcentajeResultadoUtilidad DECIMAL(18, 4),
    @PorcentajeDesempenoEvaluacionPersonal DECIMAL(18, 4),
    @PorcentajeBonoAnual DECIMAL(18, 4),
    @IDUsuario INT
)
AS
BEGIN
    DECLARE @OldJSON VARCHAR(MAX),
            @NewJSON VARCHAR(MAX);

    IF (ISNULL(@IDTabuladorNivelSalarialBonosObjetivosDetalle, 0) = 0)
    BEGIN
        INSERT INTO [Nomina].[tblTabuladorNivelSalarialBonosObjetivosDetalle]
        (
            [IDTabuladorNivelSalarialBonosObjetivos],
            [Nivel],
            [PorcentajeResultadoUtilidad],
            [PorcentajeDesempenoEvaluacionPersonal],
            [PorcentajeBonoAnual]
        )
        VALUES
        (
            @IDTabuladorNivelSalarialBonosObjetivos,
            @Nivel,
            @PorcentajeResultadoUtilidad,
            @PorcentajeDesempenoEvaluacionPersonal,
            @PorcentajeBonoAnual
        );

        SET @IDTabuladorNivelSalarialBonosObjetivosDetalle = @@IDENTITY;

        SELECT @NewJSON = (SELECT * FROM [Nomina].[tblTabuladorNivelSalarialBonosObjetivosDetalle] WHERE [IDTabuladorNivelSalarialBonosObjetivosDetalle] = @IDTabuladorNivelSalarialBonosObjetivosDetalle FOR JSON AUTO);

        EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Nomina].[tblTabuladorNivelSalarialBonosObjetivosDetalle]', '[Nomina].[spIUTabuladorNivelSalarialBonosObjetivosDetalle]', 'INSERT', @NewJSON, '';
    END
    ELSE
    BEGIN
        SELECT @OldJSON = (SELECT * FROM [Nomina].[tblTabuladorNivelSalarialBonosObjetivosDetalle] WHERE [IDTabuladorNivelSalarialBonosObjetivosDetalle] = @IDTabuladorNivelSalarialBonosObjetivosDetalle FOR JSON AUTO);

        UPDATE [Nomina].[tblTabuladorNivelSalarialBonosObjetivosDetalle]
        SET
            [Nivel] = @Nivel,
            [PorcentajeResultadoUtilidad] = @PorcentajeResultadoUtilidad,
            [PorcentajeDesempenoEvaluacionPersonal] = @PorcentajeDesempenoEvaluacionPersonal,
            [PorcentajeBonoAnual] = @PorcentajeBonoAnual
        WHERE [IDTabuladorNivelSalarialBonosObjetivosDetalle] = @IDTabuladorNivelSalarialBonosObjetivosDetalle;

        SELECT @NewJSON = (SELECT * FROM [Nomina].[tblTabuladorNivelSalarialBonosObjetivosDetalle] WHERE [IDTabuladorNivelSalarialBonosObjetivosDetalle] = @IDTabuladorNivelSalarialBonosObjetivosDetalle FOR JSON AUTO);

        EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Nomina].[tblTabuladorNivelSalarialBonosObjetivosDetalle]', '[Nomina].[spIUTabuladorNivelSalarialBonosObjetivosDetalle]', 'UPDATE', @NewJSON, @OldJSON;
    END
END;
GO

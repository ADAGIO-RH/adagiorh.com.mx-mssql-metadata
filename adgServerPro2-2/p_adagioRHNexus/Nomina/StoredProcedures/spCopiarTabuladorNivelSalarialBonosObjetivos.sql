USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spCopiarTabuladorNivelSalarialBonosObjetivos]
    @IDControlBonosObjetivos INT,
    @IDTabuladorNivelSalarialCompensaciones INT,
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NuevoIDTabuladorNivelSalarialBonosObjetivos INT;
    DECLARE @OldJSON VARCHAR(MAX) = '',
            @NewJSON VARCHAR(MAX),
            @NombreSP VARCHAR(MAX) = '[Nomina].[spCopiarTabuladorNivelSalarialBonosObjetivos]',
            @Tabla VARCHAR(MAX) = '[Nomina].[tblTabuladorNivelSalarialBonosObjetivos]',
            @Accion VARCHAR(20) = 'INSERT';

    INSERT INTO [Nomina].[tblTabuladorNivelSalarialBonosObjetivos] (Descripcion)
    SELECT 
        COALESCE(Descripcion, '') + ' ' + 
        COALESCE(
            (SELECT TOP 1 Descripcion 
             FROM [Nomina].[tblControlBonosObjetivos] 
             WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos), 
            ''
        )
    FROM [Nomina].[tblTabuladorNivelSalarialCompensaciones]
    WHERE IDTabuladorNivelSalarialCompensaciones = @IDTabuladorNivelSalarialCompensaciones;

    SET @NuevoIDTabuladorNivelSalarialBonosObjetivos = SCOPE_IDENTITY();

    SELECT @NewJSON = a.JSON
    FROM [Nomina].[tblTabuladorNivelSalarialBonosObjetivos] b
        CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
    WHERE IDTabuladorNivelSalarialBonosObjetivos = @NuevoIDTabuladorNivelSalarialBonosObjetivos;

    INSERT INTO [Nomina].[tblTabuladorNivelSalarialBonosObjetivosDetalle] 
    (
        IDTabuladorNivelSalarialBonosObjetivos, 
        Nivel, 
        PorcentajeResultadoUtilidad,
        PorcentajeDesempenoEvaluacionPersonal,
        PorcentajeBonoAnual
    )
    SELECT 
        @NuevoIDTabuladorNivelSalarialBonosObjetivos, 
        Nivel, 
        PorcentajeResultadoUtilidad,
        PorcentajeDesempenoEvaluacionPersonal,
        PorcentajeBonoAnual
    FROM [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle]
    WHERE IDTabuladorNivelSalarialCompensaciones = @IDTabuladorNivelSalarialCompensaciones;

    UPDATE [Nomina].[tblControlBonosObjetivos]
    SET IDTabuladorNivelSalarialBonosObjetivos = @NuevoIDTabuladorNivelSalarialBonosObjetivos
    WHERE IDControlBonosObjetivos = @IDControlBonosObjetivos;

    EXEC [Auditoria].[spIAuditoria]
        @IDUsuario      = @IDUsuario,
        @Tabla          = @Tabla,
        @Procedimiento  = @NombreSP,
        @Accion         = @Accion,
        @NewData        = @NewJSON,
        @OldData        = @OldJSON

    SELECT *
    FROM [Nomina].[tblTabuladorNivelSalarialBonosObjetivos]
    WHERE IDTabuladorNivelSalarialBonosObjetivos = @NuevoIDTabuladorNivelSalarialBonosObjetivos
END;
GO

USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spIControlBonosObjetivosCiclosMedicion]
    @IDControlBonosObjetivos INT,
    @IDCicloMedicionObjetivo INT,
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE 
        @NewJSON VARCHAR(MAX),
        @NombreSP VARCHAR(MAX) = '[Nomina].[spIControlBonosObjetivosCiclosMedicion]',
        @Tabla VARCHAR(MAX) = '[Nomina].[tblControlBonosObjetivosCiclosMedicion]',
        @Accion VARCHAR(20) = 'INSERT';

    BEGIN TRY
        INSERT INTO [Nomina].[tblControlBonosObjetivosCiclosMedicion]
        (
            IDControlBonosObjetivos,
            IDCicloMedicionObjetivo
        )
        VALUES
        (
            @IDControlBonosObjetivos,
            @IDCicloMedicionObjetivo
        );

        SELECT @NewJSON = (SELECT *
                          FROM [Nomina].[tblControlBonosObjetivosCiclosMedicion]
                          WHERE IDControlBonosObjetivosCiclo = SCOPE_IDENTITY()
                          FOR JSON AUTO);

        EXEC [Auditoria].[spIAuditoria]
            @IDUsuario = @IDUsuario,
            @Tabla = @Tabla,
            @Procedimiento = @NombreSP,
            @Accion = @Accion,
            @NewData = @NewJSON,
            @OldData = NULL;

    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine;
        
        RAISERROR ('Ocurrió un error en el procedimiento [Nomina].[spIControlBonosObjetivosCiclosMedicion].', 16, 1);
    END CATCH;
END
GO

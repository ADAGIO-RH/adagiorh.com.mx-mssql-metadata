USE [p_adagioRHDusgem]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBorrarControlBonosObjetivosCiclosMedicion]
    @IDControlBonosObjetivosCiclo INT,
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @OldJSON VARCHAR(MAX),
        @NombreSP VARCHAR(MAX) = '[Nomina].[spBorrarControlBonosObjetivosCiclosMedicion]',
        @Tabla VARCHAR(MAX) = '[Nomina].[tblControlBonosObjetivosCiclosMedicion]',
        @Accion VARCHAR(20) = 'DELETE';

    BEGIN TRY
        IF @IDControlBonosObjetivosCiclo IS NULL OR @IDUsuario IS NULL
        BEGIN
            RAISERROR ('Faltan parametros.', 16, 1);
            RETURN;
        END;

        SELECT @OldJSON = (SELECT * 
                          FROM [Nomina].[tblControlBonosObjetivosCiclosMedicion]
                          WHERE IDControlBonosObjetivosCiclo = @IDControlBonosObjetivosCiclo
                          FOR JSON AUTO);

        IF @OldJSON IS NULL
        BEGIN
            RAISERROR ('El registro especificado no existe.', 16, 1);
            RETURN;
        END;

        DELETE FROM [Nomina].[tblControlBonosObjetivosCiclosMedicion]
        WHERE IDControlBonosObjetivosCiclo = @IDControlBonosObjetivosCiclo;

        EXEC [Auditoria].[spIAuditoria]
            @IDUsuario = @IDUsuario,
            @Tabla = @Tabla,
            @Procedimiento = @NombreSP,
            @Accion = @Accion,
            @NewData = NULL,
            @OldData = @OldJSON;

    END TRY
    BEGIN CATCH
        SELECT 
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine;

        RAISERROR ('Ocurrió un error en el procedimiento [Nomina].[spBorrarControlBonosObjetivosCiclosMedicion].', 16, 1);
    END CATCH;
END
GO

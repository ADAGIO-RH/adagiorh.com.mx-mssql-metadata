USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spIControlBonosObjetivosProyectos]
    @IDControlBonosObjetivos INT,
    @IDProyecto INT,
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE 
        @NewJSON VARCHAR(MAX),
        @NombreSP VARCHAR(MAX) = '[Nomina].[spIControlBonosObjetivosProyectos]',
        @Tabla VARCHAR(MAX) = '[Nomina].[tblControlBonosObjetivosProyectos]',
        @Accion VARCHAR(20) = 'INSERT';

    BEGIN TRY
        INSERT INTO [Nomina].[tblControlBonosObjetivosProyectos]
        (
            IDControlBonosObjetivos,
            IDProyecto
        )
        VALUES
        (
            @IDControlBonosObjetivos,
            @IDProyecto
        );

        SELECT @NewJSON = (SELECT *
                          FROM [Nomina].[tblControlBonosObjetivosProyectos]
                          WHERE IDControlBonosObjetivosProyecto = SCOPE_IDENTITY()
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
        
        RAISERROR ('Ocurrió un error en el procedimiento [Nomina].[spIControlBonosObjetivosProyectos].', 16, 1);
    END CATCH;
END
GO

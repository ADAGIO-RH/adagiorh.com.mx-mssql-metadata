USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spIUPoliza](
    @IDPoliza int = 0,
    @IDTipoPoliza int,
    @Nombre varchar(100),
    @Filtro varchar(255) = null,
    @IDUsuario int
)
AS
BEGIN
    DECLARE 
        @OldJSON Varchar(Max),
        @NewJSON Varchar(Max)
    ;

    IF (@IDPoliza = 0 or @IDPoliza is null)
    BEGIN
        IF EXISTS(Select Top 1 1 from Nomina.tblPolizas where Nombre = @Nombre)
        BEGIN
            EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
            RETURN 0;
        END

        INSERT INTO [Nomina].[tblPolizas](IDTipoPoliza,Nombre,Filtro,IDUsuario)
        VALUES(@IDTipoPoliza,@Nombre,@Filtro,@IDUsuario)
				
        Set @IDPoliza = @@IDENTITY

        select @NewJSON = (SELECT 
                IDPoliza,
                IDTipoPoliza,
                Nombre,
                Filtro,
                IDUsuario,
                FechaCreacion
            FROM [Nomina].[tblPolizas]
            WHERE IDPoliza = @IDPoliza FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

        EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Nomina].[tblPolizas]','[Nomina].[spIUPoliza]','INSERT',@NewJSON,''
    END
    ELSE
    BEGIN
        IF EXISTS(Select Top 1 1 from Nomina.tblPolizas where Nombre = @Nombre and IDPoliza <> @IDPoliza)
        BEGIN
            EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
            RETURN 0;
        END

        select @OldJSON = (SELECT 
                IDPoliza,
                IDTipoPoliza,
                Nombre,
                Filtro,
                IDUsuario,
                FechaCreacion
            FROM [Nomina].[tblPolizas]
            WHERE IDPoliza = @IDPoliza FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

        UPDATE [Nomina].[tblPolizas]
        SET IDTipoPoliza = @IDTipoPoliza,
            Nombre = @Nombre,
            Filtro = @Filtro,
            IDUsuario = @IDUsuario
        WHERE IDPoliza = @IDPoliza

        select @NewJSON = (SELECT 
                IDPoliza,
                IDTipoPoliza,
                Nombre,
                Filtro,
                IDUsuario,
                FechaCreacion
            FROM [Nomina].[tblPolizas]
            WHERE IDPoliza = @IDPoliza FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

        EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Nomina].[tblPolizas]','[Nomina].[spIUPoliza]','UPDATE',@NewJSON,@OldJSON
    END

    EXEC [Nomina].[spBuscarPolizas] @IDPoliza = @IDPoliza, @IDUsuario = @IDUsuario
END
GO

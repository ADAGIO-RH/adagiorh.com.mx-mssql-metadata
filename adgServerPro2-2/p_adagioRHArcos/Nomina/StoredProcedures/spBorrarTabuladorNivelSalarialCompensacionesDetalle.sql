USE [p_adagioRHArcos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBorrarTabuladorNivelSalarialCompensacionesDetalle]
(
    @IDTabuladorNivelSalarialCompensacionesDetalle INT,
    @IDUsuario INT
) AS
BEGIN
    DECLARE 
        @OldJSON VARCHAR(MAX) = '',
        @NombreSP VARCHAR(MAX) = '[Nomina].[spBorrarTabuladorNivelSalarialCompensacionesDetalle]',
        @Tabla VARCHAR(MAX) = '[Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle]';

    SELECT @OldJSON = a.JSON
    FROM [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle] b
    CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
    WHERE IDTabuladorNivelSalarialCompensacionesDetalle = @IDTabuladorNivelSalarialCompensacionesDetalle;

    DELETE FROM [Nomina].[tblTabuladorNivelSalarialCompensacionesDetalle]
    WHERE IDTabuladorNivelSalarialCompensacionesDetalle = @IDTabuladorNivelSalarialCompensacionesDetalle;

    EXEC [Auditoria].[spIAuditoria]
        @IDUsuario      = @IDUsuario,
        @Tabla          = @Tabla,
        @Procedimiento  = @NombreSP,
        @Accion         = 'DELETE',
        @NewData        = '',
        @OldData        = @OldJSON;
END;
GO

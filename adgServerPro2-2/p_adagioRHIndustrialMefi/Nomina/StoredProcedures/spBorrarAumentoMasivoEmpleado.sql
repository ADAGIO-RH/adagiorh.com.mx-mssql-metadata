USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBorrarAumentoMasivoEmpleado]
(
    @IDAumentoMasivoEmpleado INT,
    @IDUsuario INT
)
AS
BEGIN
    DECLARE @OldJSON VARCHAR(MAX)
           ,@IDMovAfiliatorio int;
    

    SELECT @OldJSON = a.JSON FROM [Nomina].[tblAumentoMasivoEmpleado] b
    CROSS APPLY (SELECT JSON = [Utilerias].[fnStrJSON](0, 1, (SELECT b.* FOR XML RAW))) a
    WHERE b.[IDAumentoMasivoEmpleado] = @IDAumentoMasivoEmpleado;

    SELECT @IDMovAfiliatorio=IDMovAfiliatorio
    FROM Nomina.tblAumentoMasivoEmpleado
    WHERE IDAumentoMasivoEmpleado=@IDAumentoMasivoEmpleado

    -- DELETE FROM [Nomina].[tblAumentoMasivoEmpleado]
    -- WHERE [IDAumentoMasivoEmpleado] = @IDAumentoMasivoEmpleado;

    EXEC [IMSS].[spBorrarMovAfiliatorio]  @IDMovAfiliatorio=@IDMovAfiliatorio,@IDUsuario=@IDUsuario


    EXEC [Auditoria].[spIAuditoria] @IDUsuario, '[Nomina].[tblAumentoMasivoEmpleado]', '[Nomina].[spBorrarAumentoMasivoEmpleado]', 'DELETE', '', @OldJSON
END;
GO

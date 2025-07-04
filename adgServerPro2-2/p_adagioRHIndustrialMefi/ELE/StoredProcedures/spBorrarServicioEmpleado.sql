USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [ELE].[spBorrarServicioEmpleado]-- 2,1
(
	@IDServicioEmpleado int,
	@IDUsuario int
)
AS
BEGIN
	
	
    DECLARE @OldJSON Varchar(Max),
    @NewJSON Varchar(Max),
    @IDIdioma varchar(225)
	;
    select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))

    select @OldJSON =(SELECT IDCliente
                        ,GenerarNoNomina
                        ,LongitudNoNomina
                        ,Codigo
                        ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as NombreComercial
                        FROM [RH].[tblCatClientes]                   
                    WHERE IDCliente = @IDServicioEmpleado FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[ELE].[tblServicioEmpleados]','[ELE].[spBorrarServicioEmpleado]','DELETE','',@OldJSON


   BEGIN TRY  
	  Delete ELE.[tblServicioEmpleados] 
	    WHERE IDServicioEmpleado = @IDServicioEmpleado
	  
    END TRY  
    BEGIN CATCH  
    EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
    END CATCH ;


END
GO

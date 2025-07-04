USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [ELE].[spBorrarCatTipoServicio]-- 2,1
(
	@IDTipoServicio int,
	@IDUsuario int
)
AS
BEGIN
        DECLARE  @IDIdioma varchar(225)

		select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))

	IF EXISTS(Select Top 1 1 from ELE.tblServicioEmpleados where IDTipoServicio = @IDTipoServicio)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = 1, @CodigoError = '0302002'
		return 0;
	END	
		
    DECLARE @OldJSON Varchar(Max),
    @NewJSON Varchar(Max)

    select @OldJSON = (SELECT IDCliente, 
                              GenerarNoNomina,
                              LongitudNoNomina,
                              JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as NombreComercial FROM [RH].[tblCatClientes]
                    WHERE IDCliente = @IDTipoServicio
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)


    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[ELE].[tblCatTiposServicios]','[ELE].[spBorrarCatTipoServicio]','DELETE','',@OldJSON


   BEGIN TRY  
	  Delete ELE.[tblCatTiposServicios] 
	WHERE IDTipoServicio = @IDTipoServicio
	  
    END TRY  
    BEGIN CATCH  
    EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
    END CATCH ;


END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarCatTipoContactoEmpleado]
(
	 @IDTipoContacto int,
	@IDUsuario int
)
AS
BEGIN
    DECLARE  
		@IDIdioma varchar(225)
	;
    select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))
	--EXEC [RH].[spBuscarCatTipoContactoEmpleado] @IDTipoContacto = @IDTipoContacto, @IDUsuario=@IDUsuario

	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = (SELECT IDTipoContacto
                        ,Mask
                        ,IDMedioNotificacion
                        ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
                        FROM [RH].[tblCatTipoContactoEmpleado]                  
                    WHERE IDTipoContacto = @IDTipoContacto FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTipoContactoEmpleado]','[RH].[spBorrarCatTipoContactoEmpleado]','DELETE','',@OldJSON


    BEGIN TRY  
	Delete [RH].[tblCatTipoContactoEmpleado]
	where IDTipoContacto = @IDTipoContacto
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;

END
GO

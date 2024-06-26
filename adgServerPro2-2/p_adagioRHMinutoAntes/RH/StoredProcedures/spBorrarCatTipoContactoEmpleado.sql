USE [p_adagioRHMinutoAntes]
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

	--EXEC [RH].[spBuscarCatTipoContactoEmpleado] @IDTipoContacto = @IDTipoContacto, @IDUsuario=@IDUsuario

	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [RH].[tblCatTipoContactoEmpleado] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDTipoContacto = @IDTipoContacto

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

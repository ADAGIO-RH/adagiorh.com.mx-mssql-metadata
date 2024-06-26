USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarCatPuestos]
(
	@IDPuesto int,
	@IDUsuario int
)
AS
BEGIN

		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [RH].[tblCatPuestos] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDPuesto = @IDPuesto

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatPuestos]','[RH].[spBorrarCatPuestos]','DELETE','',@OldJSON



    exec [RH].[spBuscarCatPuestos] @IDPuesto;

    BEGIN TRY  
	   DELETE [RH].[tblCatPuestos]
	   WHERE IDPuesto = @IDPuesto

	    EXEC [Seguridad].[spBorrarFiltrosUsuariosMasivoCatalogo] 
		 @IDFiltrosUsuarios  = 0  
		 ,@IDUsuario  = @IDUsuario   
		 ,@Filtro = 'Puestos'  
		 ,@ID = @IDPuesto   
		 ,@Descripcion = ''
		 ,@IDUsuarioLogin = @IDUsuario 

    END TRY  
    BEGIN CATCH  
    EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
    END CATCH ;
END
GO

USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarCatTiposPrestaciones]
(
	@IDTipoPrestacion Int,
	@IDUsuario int
)
AS
BEGIN

IF EXISTS(Select Top 1 1 from RH.tblPrestacionesEmpleado where IDTipoPrestacion = @IDTipoPrestacion)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END


	
	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [RH].[tblCatTiposPrestaciones] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDTipoPrestacion = @IDTipoPrestacion

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTiposPrestaciones]','[RH].[spBorrarCatTiposPrestaciones]','DELETE','',@OldJSON


	BEGIN TRY  
	Delete [RH].[tblCatTiposPrestacionesDetalle]
	WHERE IDTipoPrestacion = @IDTipoPrestacion

	Delete [RH].[tblCatTiposPrestaciones]
	WHERE IDTipoPrestacion = @IDTipoPrestacion

	 EXEC [Seguridad].[spBorrarFiltrosUsuariosMasivoCatalogo] 
		 @IDFiltrosUsuarios  = 0  
		 ,@IDUsuario  = @IDUsuario   
		 ,@Filtro = 'Prestaciones'  
		 ,@ID = @IDTipoPrestacion   
		 ,@Descripcion = ''
		 ,@IDUsuarioLogin = @IDUsuario 
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;


END
GO

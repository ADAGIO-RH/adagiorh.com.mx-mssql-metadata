USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [RH].[spBorrarCatTiposPrestacionesDetalle](
	 @IDTipoPrestacionDetalle int
	,@IDUsuario int
) as

  DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);

	select @OldJSON = a.JSON from [RH].[tblCatTiposPrestacionesDetalle] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDTipoPrestacion = IDTipoPrestacionDetalle 

	-- EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTiposPrestacionesDetalle]','[RH].[spBorrarCatTiposPrestacionesDetalle]','DELETE','',@OldJSON
		
	BEGIN TRY  
		DELETE [RH].[tblCatTiposPrestacionesDetalle] WHERE IDTipoPrestacionDetalle = @IDTipoPrestacionDetalle
	END TRY  
	BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END CATCH ;
GO

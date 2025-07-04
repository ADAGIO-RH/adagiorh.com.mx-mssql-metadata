USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE proc [RH].[spBorrarConfigAsignacionPredeterminada](
	 @IDConfigAsignacionPredeterminada int	 
	,@IDUsuario int					
)AS


	DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	select @OldJSON = a.JSON from [RH].[tblConfigAsignacionesPredeterminadas] b
	Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
	WHERE b.IDConfigAsignacionPredeterminada = @IDConfigAsignacionPredeterminada

	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblConfigAsignacionesPredeterminadas]','[RH].[spBorrarConfigAsignacionPredeterminada]','DELETE','',@OldJSON


	delete from RH.tblConfigAsignacionesPredeterminadas
	where IDConfigAsignacionPredeterminada = @IDConfigAsignacionPredeterminada
GO

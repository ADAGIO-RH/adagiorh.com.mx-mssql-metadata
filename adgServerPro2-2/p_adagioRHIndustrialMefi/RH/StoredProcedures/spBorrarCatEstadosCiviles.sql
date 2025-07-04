USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarCatEstadosCiviles]
(
	@IDEstadoCivil int,
	@IDUsuario int
)
AS
BEGIN

		SELECT 
			IDEstadoCivil
			,Codigo
			,Descripcion
		FROM [RH].[tblCatEstadosCiviles]
		WHERE IDEstadoCivil = @IDEstadoCivil

			DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [RH].[tblCatEstadosCiviles] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDEstadoCivil = @IDEstadoCivil

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatEstadosCiviles]','[RH].[spBorrarCatEstadosCiviles]','DELETE','',@OldJSON

	
	DELETE RH.tblCatEstadosCiviles
	WHERE IDEstadoCivil = @IDEstadoCivil
END
GO

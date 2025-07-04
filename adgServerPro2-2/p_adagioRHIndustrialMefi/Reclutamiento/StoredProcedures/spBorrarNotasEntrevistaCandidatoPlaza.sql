USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reclutamiento].[spBorrarNotasEntrevistaCandidatoPlaza](
	 @IDNotasEntrevistaCandidatoPlaza int
	,@IDUsuario int
) as
begin

		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [Reclutamiento].[tblNotasEntrevistaCandidatoPlaza] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.[IDNotasEntrevistaCandidatoPlaza] = @IDNotasEntrevistaCandidatoPlaza

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblNotasEntrevistaCandidatoPlaza]','[Reclutamiento].[spBorrarNotasEntrevistaCandidatoPlaza]','DELETE','',@OldJSON


		DELETE FROM [Reclutamiento].[tblNotasEntrevistaCandidatoPlaza]
        WHERE [IDNotasEntrevistaCandidatoPlaza] = @IDNotasEntrevistaCandidatoPlaza

END;
GO

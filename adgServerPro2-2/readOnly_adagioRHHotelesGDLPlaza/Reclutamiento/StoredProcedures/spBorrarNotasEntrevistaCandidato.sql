USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reclutamiento].[spBorrarNotasEntrevistaCandidato](
	 @IDNotasEntrevistaCandidato int = 0
	,@IDUsuario int
) as
begin

		SELECT [IDNotasEntrevistaCandidato]
			  ,[IDCandidato]
			  ,[Nota]
			  ,[FechaHora]
			  ,[IDUsuario]
		FROM [Reclutamiento].[tblNotasEntrevistaCandidato]
		WHERE ([IDNotasEntrevistaCandidato] = @IDNotasEntrevistaCandidato)

		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from [Reclutamiento].[tblNotasEntrevistaCandidato] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.[IDNotasEntrevistaCandidato] = @IDNotasEntrevistaCandidato

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblNotasEntrevistaCandidato]','[Reclutamiento].[spBorrarNotasEntrevistaCandidato]','DELETE','',@OldJSON


		DELETE FROM [Reclutamiento].[tblNotasEntrevistaCandidato]
        WHERE [IDNotasEntrevistaCandidato] = @IDNotasEntrevistaCandidato;

END;
GO

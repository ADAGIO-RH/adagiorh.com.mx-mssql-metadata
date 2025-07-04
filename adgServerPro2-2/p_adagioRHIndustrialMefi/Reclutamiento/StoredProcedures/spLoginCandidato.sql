USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reclutamiento].[spLoginCandidato]
(
	@Email Varchar(50),
	@Password Varchar(50)
)
AS
BEGIN
	declare @IDCandidato int = null;

	Select top 1 @IDCandidato=C.IDCandidato
	from Reclutamiento.tblCandidatos C with(nolock)
	Where C.Email = @Email
	and C.Password = @Password 

	IF (@IDCandidato is not null)
	BEGIN
		exec [Reclutamiento].[spBuscarCandidatos] 
			@IDCandidato=@IDCandidato,
			@IDUsuario = 1
	END
	ELSE
	BEGIN
		--RAISERROR('Cuenta o Clave Incorrecto.',16,1);
		exec [App].[spObtenerError] null,'0000001', 'Es probable que el Candidato no se encuentre vigente.'
	END
	
END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reclutamiento].[spBuscarNotasEntrevistaCandidatoPlaza](
	@IDNotasEntrevistaCandidatoPlaza int = 0
	,@IDCandidatoPlaza int = 0
	,@IDCandidato int = 0
) as



SELECT [Notas].[IDNotasEntrevistaCandidatoPlaza]
      ,ISNULL([Notas].[IDCandidatoPlaza],0) as [IDCandidatoPlaza]
      ,[Notas].[IDCandidato]
	  ,CONCAT(Candidato.Nombre, ' ' ,Candidato.Paterno ,' ', Candidato.Materno) as NombreCandidato
      ,[Notas].[Nota]
      ,[Notas].[FechaHora]
      ,[Notas].[IDUsuario]
	  ,CONCAT(Usuario.Cuenta, ' - ' ,Usuario.Nombre ,' ', Usuario.Apellido) as NombreUsuario

  FROM [Reclutamiento].[tblNotasEntrevistaCandidatoPlaza] Notas
  INNER JOIN Reclutamiento.tblCandidatos Candidato on Notas.IDCandidato = Candidato.IDCandidato
  INNER JOIN Seguridad.tblUsuarios Usuario on Notas.IDUsuario = Usuario.IDUsuario

  WHERE
  (Notas.IDNotasEntrevistaCandidatoPlaza = ISNULL(@IDNotasEntrevistaCandidatoPlaza,0) or ISNULL(@IDNotasEntrevistaCandidatoPlaza,0) = 0)
   and (Notas.[IDCandidatoPlaza] = ISNULL(@IDCandidatoPlaza,0) or ISNULL(@IDCandidatoPlaza,0) = 0)
   and (Notas.IDCandidato = ISNULL(@IDCandidato,0) or ISNULL(@IDCandidato,0) = 0)
order by [FechaHora] asc
GO

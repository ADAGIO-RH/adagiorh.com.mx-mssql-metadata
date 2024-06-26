USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reclutamiento].[spBuscarNotasEntrevistaCandidato](
	@IDNotasEntrevistaCandidato int = 0
	,@IDCandidato int = 0	
) as
	


SELECT [Notas].[IDNotasEntrevistaCandidato]
      ,[Notas].[IDCandidato]
      ,[Notas].[Nota]
      ,[Notas].[FechaHora]
      ,[Notas].[IDUsuario]
	  ,FORMAT ([Notas].[FechaHora], 'dd/MM/yyyy hh:mm:ss tt') as FormatoFecha
	  ,CONCAT(Candidato.Nombre, ' ' ,Candidato.Paterno ,' ', Candidato.Materno) as NombreCandidato
	  ,Usuario.NOMBRECOMPLETO as NombreUsuario
	  ,ROW_NUMBER()over(ORDER BY [Notas].[IDNotasEntrevistaCandidato])as ROWNUMBER

  FROM [Reclutamiento].[tblNotasEntrevistaCandidato] Notas
  join Reclutamiento.tblCandidatos Candidato on Notas.IDCandidato = Candidato.IDCandidato
  join RH.tblEmpleadosMaster Usuario on Notas.IDUsuario = Usuario.IDEmpleado

  where (Notas.IDNotasEntrevistaCandidato = @IDNotasEntrevistaCandidato or @IDNotasEntrevistaCandidato = 0) and (Notas.IDCandidato = @IDCandidato or @IDCandidato = 0) 
order by [FechaHora] asc
GO

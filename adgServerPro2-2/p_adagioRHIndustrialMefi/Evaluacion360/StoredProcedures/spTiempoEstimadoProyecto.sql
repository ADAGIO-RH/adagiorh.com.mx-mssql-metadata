USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Evaluacion360].[spTiempoEstimadoProyecto](
	@IDProyecto int
	,@IDUsuario int
) as
--DECLARE	@IDEvaluador int = 20310
--			,@IDProyecto int = 36

--	;
SELECT      
	CASE 
		WHEN cast(CONVERT(VARCHAR(12), s.Segundos /60/60/24) AS int) = 1 then CONVERT(VARCHAR(12), s.Segundos /60/60/24) + ' Día, ' 
		WHEN cast(CONVERT(VARCHAR(12), s.Segundos /60/60/24) AS int) > 1 then CONVERT(VARCHAR(12), s.Segundos /60/60/24) + ' Días, ' 
		ELSE ''  END
  +	  case when cast( CONVERT(VARCHAR(12), s.Segundos /60/60 % 24) as int) = 1 then CONVERT(VARCHAR(12), s.Segundos /60/60 % 24) +' hora'
		   when  cast( CONVERT(VARCHAR(12), s.Segundos /60/60 % 24) as int) > 1 then CONVERT(VARCHAR(12), s.Segundos /60/60 % 24) +' horas' ELSE '' end	
  + ' ' + case when cast( CONVERT(VARCHAR(2),  s.Segundos /60 % 60) as int) = 1 then + RIGHT('0' + CONVERT(VARCHAR(2),  s.Segundos /60 % 60), 2) + ' minuto'
				when cast( CONVERT(VARCHAR(2),  s.Segundos /60 % 60) as int) > 1 then + RIGHT('0' + CONVERT(VARCHAR(2),  s.Segundos /60 % 60), 2) + ' minutos' ELSE '' end
  + ' ' + case when cast(CONVERT(VARCHAR(2),  s.Segundos % 60) as int) = 1 then RIGHT('0' + CONVERT(VARCHAR(2),  s.Segundos % 60), 2) +' segundo'
				when cast(CONVERT(VARCHAR(2),  s.Segundos % 60) as int) > 1 then RIGHT('0' + CONVERT(VARCHAR(2),  s.Segundos % 60), 2) +' segundos' ELSE '' end AS TiempoTotal
from (
	SELECT SUM((tctdp.TiempoEstimadoRespuesta * tcudt.TiempoEnSegundos)) AS Segundos --tee.IDEvaluacionEmpleado 
	FROM Evaluacion360.tblCatGrupos tcg WITH (nolock)   
		JOIN Evaluacion360.tblCatPreguntas tcp WITH (nolock)  ON tcg.IDGrupo = tcp.IDGrupo
		JOIN Evaluacion360.tblCatTiposDePreguntas tctdp WITH (nolock)  ON tcp.IDTipoPregunta = tctdp.IDTipoPregunta
		JOIN App.tblCatUnidadesDeTiempo tcudt WITH (nolock)  ON tctdp.IDUnidadDeTiempo = tcudt.IDUnidadDeTiempo
	WHERE tcg.IDReferencia = @IDProyecto AND tcg.TipoReferencia = 1
		) s
GO

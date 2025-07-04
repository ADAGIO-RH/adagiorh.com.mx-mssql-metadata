USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2022-06-14
-- Description:	sp para Borrar Resultados Evaluados de Reclutamiento
-- =============================================
CREATE PROCEDURE [Reclutamiento].[spBorrarResultadosEvaluados]
	(
		@IDResultadosCandidato int = 0
		,@IDUsuario int = 0		
	)
AS
BEGIN

SELECT        
	IDResultadosCandidato, 
	IDEvaluado,
	TipoEvaluado, 
	IDAspectoEvaluar, 
	Resultado, 
	FechaAplicacion
	,ROW_NUMBER()over(ORDER BY tblResultadosEvaluados.[IDResultadosCandidato])as ROWNUMBER
FROM            
	Reclutamiento.tblResultadosEvaluados
	  WHERE ([IDResultadosCandidato] = @IDResultadosCandidato OR isnull(@IDResultadosCandidato,0) = 0)

		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = a.JSON from Reclutamiento.tblResultadosEvaluados b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.[IDResultadosCandidato] = @IDResultadosCandidato

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblResultadosEvaluados]','[Reclutamiento].[spBorrarResultadosEvaluados]','DELETE','',@OldJSON



	if @IDResultadosCandidato > 0
		delete from Reclutamiento.tblResultadosEvaluados
		where IDResultadosCandidato = @IDResultadosCandidato 

END
GO

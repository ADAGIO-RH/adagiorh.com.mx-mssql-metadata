USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [Evaluacion360].[spUChkPreguntas](
	@IDPregunta int 
	,@Type varchar(20)
	,@Valor bit
	,@IDUsuario int
) as

	if (@Type = 'chkPregReq') -- Pregunta Requerida
	begin
		update [Evaluacion360].[tblCatPreguntas]
			set EsRequerida = @Valor
		where IDPregunta = @IDPregunta
	end else
	if (@Type = 'chkComHab') -- Comentarios Habilitados
	begin
		update [Evaluacion360].[tblCatPreguntas]
			set Comentario = @Valor
		where IDPregunta = @IDPregunta
	end else
	if (@Type = 'chkComReq') -- Comentarios Requeridos
	begin
		update [Evaluacion360].[tblCatPreguntas]
			set ComentarioEsRequerido = @Valor
				,Comentario = @Valor
		where IDPregunta = @IDPregunta
	end else
	if (@Type = 'chk9BoxHab') -- 9 box Habilitado
	begin
		update [Evaluacion360].[tblCatPreguntas]
			set Box9 = @Valor		
		where IDPregunta = @IDPregunta
	end else
	if (@Type = 'chk9BoxReq') -- 9 box Requerido
	begin
		update [Evaluacion360].[tblCatPreguntas]
			set Box9EsRequerido = @Valor
				,Box9 = @Valor
		where IDPregunta = @IDPregunta
	end;
GO

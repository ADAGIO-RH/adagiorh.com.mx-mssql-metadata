USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc Evaluacion360.spIUCatCalificacionLiteral(
	 @IDCalificacionLiteral int	= 0
	,@Literal char(2)
	,@CalificacionInicial decimal(10,2)
	,@CalificacionFinal decimal(10,2)
	,@IDUsuario int
) as

	if (isnull(@IDCalificacionLiteral,0) = 0)
	begin
		insert Evaluacion360.tblCatCalificacionesLiterales(Literal,CalificacionInicial,CalificacionFinal)
		values( upper(@Literal),@CalificacionInicial,@CalificacionFinal) 

		set @IDCalificacionLiteral = @@IDENTITY
	end else
	begin
		update Evaluacion360.tblCatCalificacionesLiterales
		set Literal = upper(@Literal)
			,CalificacionInicial = @CalificacionInicial
			,CalificacionFinal = @CalificacionFinal
		where IDCalificacionLiteral = @IDCalificacionLiteral
	end;
GO

USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [RH].[spBuscarTabuladorSalarial] (
	@IDNivelSalarial int = 0,
	@Nivel int = 0,
	@IDUsuario int
) as
	select 
		ts.IDNivelSalarial,
		ts.Nivel,
		ts.Minimo,
		ts.Q1,
		ts.Medio,
		ts.Q3,
		ts.Maximo,
		ts.Amplitud,
		ts.Progresion
	from RH.tblTabuladorSalarial ts with(nolock)
	where  (ts.IDNivelSalarial = @IDNivelSalarial or isnull(@IDNivelSalarial, 0) = 0)
	and (ts.Nivel = @Nivel or isnull(@Nivel, 0) = 0)
	order by Nivel asc
GO

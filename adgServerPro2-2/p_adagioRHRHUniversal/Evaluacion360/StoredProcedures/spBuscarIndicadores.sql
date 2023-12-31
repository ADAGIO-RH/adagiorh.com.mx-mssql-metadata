USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create   proc Evaluacion360.spBuscarIndicadores(
	@IDIndicador int = 0,
	@IDUsuario int
) as

	select 
		i.IDIndicador
		,i.Nombre
		,i.Descripcion
		,i.IsDefault
		,i.NombreIcono
	from Evaluacion360.tblCatIndicadores i
	where (i.IDIndicador = @IDIndicador or isnull(@IDIndicador, 0) = 0)
	order by i.Nombre
GO

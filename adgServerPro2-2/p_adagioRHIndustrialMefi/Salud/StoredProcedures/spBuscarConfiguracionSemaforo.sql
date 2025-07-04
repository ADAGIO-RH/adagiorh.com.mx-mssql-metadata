USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Salud].[spBuscarConfiguracionSemaforo](
	@IDConfiguracionSemaforo int = 0
	,@IDCuestionario int = 0
	,@IDUsuario int
) as
	
	select *
	from [Salud].[tblConfiguracionSemaforo] cs with (nolock)
	where (cs.IDConfiguracionSemaforo = @IDConfiguracionSemaforo or isnull(@IDConfiguracionSemaforo,0) = 0 )
		and (cs.IDCuestionario = @IDCuestionario or @IDCuestionario = 0)
GO

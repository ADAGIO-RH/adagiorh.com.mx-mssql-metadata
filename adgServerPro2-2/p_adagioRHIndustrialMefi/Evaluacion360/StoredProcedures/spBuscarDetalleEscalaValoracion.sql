USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBuscarDetalleEscalaValoracion](	
	@IDDetalleEscalaValoracion int = 0
	,@IDEscalaValoracion int = 0
) as
	select 
	IDDetalleEscalaValoracion
	,IDEscalaValoracion
	,Nombre
	,Valor
	from [Evaluacion360].[tblDetalleEscalaValoracion] with (nolock) 
	where (IDDetalleEscalaValoracion = @IDDetalleEscalaValoracion or @IDDetalleEscalaValoracion = 0) and (IDEscalaValoracion = @IDEscalaValoracion or @IDEscalaValoracion = 0)
	order by isnull(Valor,0) desc
GO

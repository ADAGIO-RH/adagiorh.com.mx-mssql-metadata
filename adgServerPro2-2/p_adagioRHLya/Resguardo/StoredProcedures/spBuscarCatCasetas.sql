USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Resguardo].[spBuscarCatCasetas](
	@IDCaseta int = 0
	,@IDUsuario int
) as
	
	select 
		c.IDCaseta
		,c.Nombre
		,c.Activa
		,isnull(c.FechaHora,getdate()) as FechaHora
	from [Resguardo].[tblCatCasetas] c with (nolock)
	where c.IDCaseta = @IDCaseta or @IDCaseta = 0
GO

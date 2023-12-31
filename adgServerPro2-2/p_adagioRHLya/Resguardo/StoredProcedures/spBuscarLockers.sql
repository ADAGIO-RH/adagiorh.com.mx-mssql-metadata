USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select * from [Resguardo].[tblCatLockers]
--select * from [Resguardo].[tblCatCasetas]

CREATE proc [Resguardo].[spBuscarLockers](
	@IDLocker int = 0	
	,@IDCaseta int = 0	
	,@IDUsuario int
) as

	select *
	from (
		select 
			 l.IDLocker
			,l.IDCaseta
			,c.Nombre as Caseta
			,l.Codigo
			,l.Disponible
			,l.Activo
			,isnull(l.FechaHora,getdate()) as FechaHora
			,Orden = ROW_NUMBER()over(order by cast(l.Codigo as int) asc)
		from [Resguardo].[tblCatLockers] l with (nolock)
			join [Resguardo].[tblCatCasetas] c with (nolock) on l.IDCaseta = c.IDCaseta
		where (l.IDLocker = @IDLocker or @IDLocker = 0) and (c.IDCaseta = @IDCaseta or @IDCaseta = 0) 
	) as cat
	order by cat.Orden asc
GO

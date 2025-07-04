USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Resguardo].[spEntregarArticulos](
	@IDsHistoriales varchar(max)
	,@IDUsuario int
) as
	
	update h
		set h.Entregado = 1
			,h.FechaEntrega = getdate()
			,h.IDUsuarioEntrega = @IDUsuario
	from [Resguardo].[tblHistorial] h
		join (select cast(Item as int) as ID
				from [App].[Split](@IDsHistoriales,',')) s on h.IDHistorial = s.ID

	update clk
		set clk.Disponible = 1
	from [Resguardo].[tblHistorial] h
		join (select cast(Item as int) as ID
				from [App].[Split](@IDsHistoriales,',')) s on h.IDHistorial = s.ID
		join [Resguardo].[tblCatLockers] clk on h.IDLocker = clk.IDLocker
GO

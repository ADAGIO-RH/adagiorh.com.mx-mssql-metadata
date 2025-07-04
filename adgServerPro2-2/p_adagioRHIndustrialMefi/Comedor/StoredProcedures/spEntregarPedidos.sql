USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Comedor].[spEntregarPedidos](
	@IDEmpleadoRecoge int,
	@IDsPedidos varchar(max)
) as

	update Comedor.tblPedidos
		set IDEmpleadoAutorizo = @IDEmpleadoRecoge,
			Autorizado = 1,
			FechaHoraAutorizacion = getdate()
	where IDPedido in (select cast(item as Int) from App.Split(@IDsPedidos, ','))
GO

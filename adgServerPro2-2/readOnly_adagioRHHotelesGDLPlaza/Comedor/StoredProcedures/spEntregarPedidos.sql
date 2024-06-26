USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Comedor].[spEntregarPedidos](
	@IDEmpleadoRecoge int,
	@IDsPedidos varchar(max)
) as
	--declare 
	--	@IDEmpleadoRecoge int,
	--	@IDsPedidos varchar(max) = '5,6'


	update Comedor.tblPedidos
		set IDEmpleadoAutorizo = @IDEmpleadoRecoge,
			Autorizado = 1,
			FechaHoraAutorizacion = getdate()
	where IDPedido in (select cast(item as Int) from App.Split(@IDsPedidos, ','))
GO

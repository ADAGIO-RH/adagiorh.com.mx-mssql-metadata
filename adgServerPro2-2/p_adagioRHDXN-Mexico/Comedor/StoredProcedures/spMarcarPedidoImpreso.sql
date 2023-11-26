USE [p_adagioRHDXN-Mexico]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc Comedor.spMarcarPedidoImpreso(@IDPedido int) as
begin

	update Comedor.tblPedidos
		set ComandaImpresa = 1,
			FechaHoraImpresion = getdate()
	where IDPedido = @IDPedido

end
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Comedor].[spCancelarAutorizarPedido](
	@IDPedido int,
	@Tipo int, -- 1: Autorizar 2: Cancelar
	@Estatus bit, -- Indica si o no se autoriza o se cancencela el pedido
	@Nota varchar(max), -- Justificación de la Autorización o Cancelación
	@IDUsuario int
) as

	if (@Tipo = 1) 
	begin
		update Comedor.tblPedidos
			set Autorizado = @Estatus,
				Cancelada = case when @Estatus = 1 then 0 else Cancelada end,
				NotaAutorizacion = @Nota,
				IDUsuarioAutorizo = @IDUsuario,
				FechaHoraAutorizacion = getdate()
		where IDPedido = @IDPedido
	end else 
	if (@Tipo = 2)
	begin
		update Comedor.tblPedidos
			set 
				Cancelada = @Estatus,
				NotaCancelacion = @Nota,
				IDUsuarioCancelo = @IDUsuario,
				FechaCancelacion = getdate()
		where IDPedido = @IDPedido
	end
GO

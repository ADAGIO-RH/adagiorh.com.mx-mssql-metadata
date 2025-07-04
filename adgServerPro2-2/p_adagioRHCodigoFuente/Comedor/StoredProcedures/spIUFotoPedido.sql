USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create   proc Comedor.spIUFotoPedido(
	@IDFotoPedido int = 0,
	@FotoUrl varchar(max),
	@IdentifyResults varchar(max),
	@Pedidos varchar(max),
	@IDsPedidos varchar(max) = null,
	@IDRestaurante int = null,
	@Valido bit = 0,
	@Mensaje varchar(max),
	@NumeroPedido int = null
) as
begin
	
	if (ISNULL(@IDFotoPedido, 0) = 0)
	begin
		insert into Comedor.tblFotosPedidos(FotoUrl, IdentifyResults, Pedidos, IDsPedidos, IDRestaurante, Valido, Mensaje)
		values (
			@FotoUrl, 
			@IdentifyResults, 
			@Pedidos, 
			@IDsPedidos, 
			case when ISNULL(@IDRestaurante,0) = 0 then null else @IDRestaurante end,
			@Valido,
			@Mensaje
		)

		set @IDFotoPedido = SCOPE_IDENTITY()
	end else 
	begin
		if (ISNULL(@NumeroPedido, '') != '')
		begin
			select top 1 @IDsPedidos = IDPedido
			from Comedor.tblPedidos
			where Numero = @NumeroPedido and IDRestaurante = @IDRestaurante and FechaCreacion = CAST(GETDATE() as date)
		end

		update Comedor.tblFotosPedidos
		set 
			IDsPedidos = @IDsPedidos,
			IDRestaurante = case when ISNULL(@IDRestaurante,0) = 0 then null else @IDRestaurante end
		where IDFotoPedido = @IDFotoPedido

	end

	select @IDFotoPedido as IDFotoPedido
end
GO

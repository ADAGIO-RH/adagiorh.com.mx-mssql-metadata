USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function Comedor.fnFormatoNumeroPedido(@NumeroPedido int)
returns varchar(max)
as
begin
	declare
		@NumeroConFormato varchar(max)

	select @NumeroConFormato = App.fnAddString(4,cast(@NumeroPedido as varchar(max)),'0',1)

	return @NumeroConFormato
end
GO

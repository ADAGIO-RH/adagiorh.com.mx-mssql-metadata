USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Utilerias].[fnConvertNumerosALetras_FS]
(
	@Numero Varchar(Max)
)
returns Varchar(Max)
AS
BEGIN

--set @Numero = '1524.76'

Declare @res Varchar(max) = '',
		@dec varchar(max) ='',
		@entero numeric,
		@decimales numeric(25,2),
		@nro decimal(25,2),
		@esNegativo bit = 0,
		@NumeroDecimal decimal(25,2) = cast(isnull(@Numero,0.00) as decimal(25,2))

	set @esNegativo = case when @NumeroDecimal < 0.00 then 1 else 0 end
	set @Numero = case when @NumeroDecimal < 0.00 then @NumeroDecimal * -1 else @NumeroDecimal end
	set @nro = cast(@Numero as numeric(25,2)) 
	set @entero = cast(@nro as bigint) 
	set @decimales = @nro - @entero 
	
	--select @decimales as decimales,@entero as entero ,@nro as Numero

	if(@decimales > 0)
	BEGIN
		set @dec = ' PESOS CON ' + REPLACE(cast(@decimales as Varchar(max)),'0.','') + ' / 100'
	END

	set @res = case when @esNegativo = 1 then 'MENOS ' + [Utilerias].[fnConvertNumerosALetrasDiccionario]( cast(@entero as decimal(25,2))) + @dec
					else [Utilerias].[fnConvertNumerosALetrasDiccionario]( cast(@entero as decimal(25,2))) + @dec end
	

	return @res
END
GO

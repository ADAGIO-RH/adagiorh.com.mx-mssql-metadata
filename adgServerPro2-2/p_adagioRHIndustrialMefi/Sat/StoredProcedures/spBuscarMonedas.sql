USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarMonedas]
(
	@Moneda Varchar(50) = ''
)
AS
BEGIN
	IF(@Moneda = '' or @Moneda is null)
	BEGIN
		select 
			IDMoneda
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion
			,Decimales
			,PorcentajeVariacion 
		From [Sat].[tblCatMonedas]
	END
	ELSE
	BEGIN
		select 
			IDMoneda
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion
			,Decimales
			,PorcentajeVariacion 
		From [Sat].[tblCatMonedas]
		where Descripcion like @Moneda +'%'
			OR Codigo like @Moneda+'%'
	END
END
GO

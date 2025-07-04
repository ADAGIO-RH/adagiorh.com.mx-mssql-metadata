USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarMetodosPago]
(
	@MetodoPago Varchar(50) = ''
)
AS
BEGIN
	IF(@MetodoPago = '' or @MetodoPago is null)
	BEGIN
		select 
			IDMetodoPago
			,UPPER(Codigo) as Codigo
			,UPPER(Descripcion) as Descripcion
		From [Sat].[tblCatMetodosPago]
	END
	ELSE
	BEGIN
		select 
			IDMetodoPago
			,UPPER(Codigo) as Codigo
			,UPPER(Descripcion) as Descripcion
		From [Sat].[tblCatMetodosPago]
		where Descripcion like @MetodoPago +'%'
			OR Codigo like @MetodoPago+'%'
	END
END
GO

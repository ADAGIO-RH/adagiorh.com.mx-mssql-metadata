USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Sat].[spBuscarPeriodicidadesPago]
(
	@PeriodicidadPago Varchar(50) = ''
)
AS
BEGIN
	IF(@PeriodicidadPago = '' or @PeriodicidadPago is null)
	BEGIN
		select 
			IDPeriodicidadPago
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion
		From [Sat].[tblCatPeriodicidadesPago]
	END
	ELSE
	BEGIN
		select 
			IDPeriodicidadPago
			,UPPER(Codigo) AS Codigo
			,UPPER(Descripcion) AS Descripcion 
		From [Sat].[tblCatPeriodicidadesPago]
		where Descripcion like @PeriodicidadPago +'%'
			OR Codigo like @PeriodicidadPago+'%'
	END
END
GO

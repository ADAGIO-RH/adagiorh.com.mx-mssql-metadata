USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create proc [Norma035].[spCalcularMuestraEmpleados](
	  @TodaEmpresa bit, 
	  @Entidad int
) as
begin 

declare @TamanoPoblacion float,
		@tamanoMuestra float
	
	IF (@TodaEmpresa = 1)
	BEGIN
		select @TamanoPoblacion = COUNT(*)  from [RH].[tblEmpresaEmpleado] TEE
		join [RH].[tblEmpresa] TE on TEE.IdEmpresa = TE.IdEmpresa
		where TE.IdEmpresa = @Entidad
	END

	ELSE

	BEGIN
	select @TamanoPoblacion = COUNT(*)  from [RH].[tblSucursalEmpleado] TSE
		join [RH].[tblCatSucursales] TS on TSE.IDSucursal = TS.IDSucursal
		where TS.IDSucursal = @Entidad
	END

	select @tamanoMuestra = round((0.9604 * @TamanoPoblacion) / ((0.0025*(@TamanoPoblacion-1))+0.9604 ),0)
	select @TamanoPoblacion as POBLACION, @tamanoMuestra as MUESTRA

end
GO

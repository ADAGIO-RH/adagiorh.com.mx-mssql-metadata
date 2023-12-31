USE [p_adagioRHSimensGamesa]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Asistencia].[fnGetSucursalesChecadas_SIEMENS](
	@IDEmpleado int,
	@FechaInicio date,
	@FechaFin date
)
RETURNS INT
AS
BEGIN
	Declare @TotalSucursales int;

	select @TotalSucursales = COUNT(*) from (select IDEmpleado
													,count(Sucursal) TotalSucursales
												from
													(select 
														IDEmpleado
														,Asistencia.fnGetIDSucursalChecada_SIEMENS(c.Latitud,c.Longitud) Sucursal
														from Asistencia.tblChecadas c with (nolock)
														where IDEmpleado = @IDEmpleado
															and Fecha between @FechaInicio and @FechaFin) S
													group by IDEmpleado, Sucursal) x

	RETURN @TotalSucursales
END
GO

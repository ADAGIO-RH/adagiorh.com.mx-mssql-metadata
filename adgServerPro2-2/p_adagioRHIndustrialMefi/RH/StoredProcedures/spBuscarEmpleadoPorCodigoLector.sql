USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc RH.spBuscarEmpleadoPorCodigoLector(
	@CodigoLector varchar(50)
) as
	select 
		e.IDEmpleado,
		e.ClaveEmpleado,
		coalesce(e.Nombre,'')+' '+coalesce(e.Paterno, '') as NombreCompleto
	from RH.tblEmpleados e with (nolock)
	where e.CodigoLector = @CodigoLector
GO

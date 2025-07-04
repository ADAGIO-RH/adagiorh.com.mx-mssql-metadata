USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [ChecadorDelphi].spBuscarEmpleado(@ClaveEmpleado varchar(20))
as
	select
		IDEmpleado
		,ClaveEmpleado
		,NOMBRECOMPLETO
		,Departamento
		,Sucursal
		,Puesto
		,FechaNacimiento as FECHA_NACIMIENTO
	from RH.tblEmpleadosMaster with (nolock)
	where ClaveEmpleado = @ClaveEmpleado
GO

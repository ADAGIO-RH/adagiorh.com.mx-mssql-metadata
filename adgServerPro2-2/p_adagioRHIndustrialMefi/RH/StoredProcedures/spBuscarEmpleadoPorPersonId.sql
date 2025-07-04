USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc RH.spBuscarEmpleadoPorPersonId(
	@personId varchar(max)	
) as

	select
		e.IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO as NombreCompleto
		,e.Sucursal
		,e.Puesto
		,e.Departamento
		,@personId as PersonId
	from AzureCognitiveServices.tblPersons p with (nolock)
		join RH.tblEmpleadosMaster e with (nolock) on e.IDEmpleado = p.IDEmpleado
	where p.PersonId = @personId
GO

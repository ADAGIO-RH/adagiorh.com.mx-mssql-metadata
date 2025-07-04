USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc RH.spBuscarEmpleadosConFotosSinRegistroEnAzure as
	select
		e.IDEmpleado,
		e.ClaveEmpleado,
		e.NOMBRECOMPLETO as NombreCompleto
	from RH.tblEmpleadosMaster e
		join RH.tblFotosEmpleados fe on fe.IDEmpleado = e.IDEmpleado
		left join AzureCognitiveServices.tblPersons person on person.IDEmpleado = e.IDEmpleado
	where isnull(e.Vigente, 0) = 1 and person.IDEmpleado is null



--select max(IDEmpleado) from RH.tblEmpleados
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc RH.spBuscarEmpleadosConExpedienteDigital(
	@IDUsuario int
) as
begin
	select distinct
		e.IDEmpleado,
		e.ClaveEmpleado,
		e.NOMBRECOMPLETO
	from RH.ExpedienteDigitalEmpleado ede
		join RH.tblEmpleadosMaster e on e.IDEmpleado = ede.IDEmpleado

end
GO

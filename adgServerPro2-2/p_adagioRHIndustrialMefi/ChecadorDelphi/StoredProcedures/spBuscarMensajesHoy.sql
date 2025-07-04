USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [ChecadorDelphi].spBuscarMensajesHoy(
	@ClaveEmpleado varchar(20)
) as
	Select Mensaje          
	from Asistencia.tblMensajesEmpleados m with (nolock)          
		join RH.tblEmpleadosMaster e on m.IDEmpleado = e.IDEmpleado
	where e.ClaveEmpleado = @ClaveEmpleado and  cast(getdate() as date) Between FechaInicio and FechaFin
GO

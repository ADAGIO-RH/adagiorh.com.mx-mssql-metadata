USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc zkteco.spBuscarFingerPrintEmpleado(
	@IDEmpleado int
) as
	select *
	from zkteco.tblFingerPrintEmpleado
	where IDEmpleado = @IDEmpleado
GO

USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Intranet.spBuscarContadorSolicitudesEmpleado --390,3
(
	@IDEmpleado int,
	@IDTipoSolicitud int = 0,
	@IDUsuario int
)
AS
BEGIN
	
	DECLARE @Autorizadas int = 0,
			@Rechazadas int = 0,
			@TotalSolicitudes int = 0,
			@Pendientes int = 0;

	select @Autorizadas = count(*)
	from Intranet.tblSolicitudesEmpleado 
	where IDEmpleado = @IDEmpleado 
	and ((IDTipoSolicitud = @IDTipoSolicitud) or (@IDTipoSolicitud = 0))
	and IDEstatusSolicitud = 2

	select @Rechazadas = count(*)
	from Intranet.tblSolicitudesEmpleado 
	where IDEmpleado = @IDEmpleado 
	and ((IDTipoSolicitud = @IDTipoSolicitud) or (@IDTipoSolicitud = 0))
	and IDEstatusSolicitud = 3

	select @Pendientes = count(*)
	from Intranet.tblSolicitudesEmpleado 
	where IDEmpleado = @IDEmpleado 
	and ((IDTipoSolicitud = @IDTipoSolicitud) or (@IDTipoSolicitud = 0))
	and IDEstatusSolicitud = 1

	select @TotalSolicitudes = count(*)
	from Intranet.tblSolicitudesEmpleado 
	where IDEmpleado = @IDEmpleado 
	and ((IDTipoSolicitud = @IDTipoSolicitud) or (@IDTipoSolicitud = 0))


	Select @Autorizadas as Autorizadas, @Rechazadas as Rechazadas, @Pendientes as Pendientes, @TotalSolicitudes as TotalSolicitudes

END
GO

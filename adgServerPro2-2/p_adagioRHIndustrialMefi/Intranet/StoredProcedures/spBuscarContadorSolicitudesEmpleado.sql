USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Intranet].[spBuscarContadorSolicitudesEmpleado] --390,3
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
			@TotalSolicitudesSinVacaciones int = 0,
			@TotalSolicitudesPrestamos int = 0,
			@PrestamosAutorizados int = 0,
			@PrestamosRechazados int = 0,
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

	select @TotalSolicitudesSinVacaciones = count(*)
	from Intranet.tblSolicitudesEmpleado 
	where IDEmpleado = @IDEmpleado 
	and (IDTipoSolicitud != 1) 

	select @TotalSolicitudesPrestamos = count(*)
	from Intranet.tblSolicitudesPrestamos
	where IDEmpleado = @IDEmpleado 

		select @TotalSolicitudesPrestamos = count(*)
	from Intranet.tblSolicitudesPrestamos
	where IDEmpleado = @IDEmpleado 

	select @PrestamosAutorizados = count(*)
	from Intranet.tblSolicitudesPrestamos
	where IDEmpleado = @IDEmpleado 
	and IDEstatusSolicitudPrestamo = 3

		select @PrestamosRechazados = count(*)
	from Intranet.tblSolicitudesPrestamos
	where IDEmpleado = @IDEmpleado 
	and IDEstatusSolicitudPrestamo = 4


	Select @Autorizadas as Autorizadas,
	@Rechazadas as Rechazadas,
	@Pendientes as Pendientes, 
	@TotalSolicitudes as TotalSolicitudes, 
	sum(@TotalSolicitudesSinVacaciones + @TotalSolicitudesPrestamos) as TotalSolicitudesSinVacaciones,
	sum(@Autorizadas + @PrestamosAutorizados ) as TotalAutorizadas,
	sum(@Rechazadas +@PrestamosRechazados) as TotalRechazados
END
GO

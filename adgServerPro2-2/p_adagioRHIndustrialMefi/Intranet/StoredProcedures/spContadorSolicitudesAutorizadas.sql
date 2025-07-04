USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [Intranet].[spContadorSolicitudesAutorizadas] 
(
	@IDEmpleado int,
	@IDTipoSolicitud int = 0,
	@IDUsuario int
)
AS BEGIN
	DECLARE @Permisos int = 0,
			@Prestamos int = 0,
			@Documentos int = 0,
			 @fechasanteriores date =DATEADD(MONTH,-3,GETDATE())
			 		



	select @Permisos = count(*)
	from Intranet.tblSolicitudesEmpleado 
	where IDEmpleado = @IDEmpleado 
	and (IDTipoSolicitud =2) 	
	and IDEstatusSolicitud = 2
	and FechaCreacion>=@fechasanteriores

	select @Prestamos = COUNT(*)		
	from [Intranet].[tblSolicitudesPrestamos] sp with (nolock)
		join [RH].[tblEmpleadosMaster] e with (nolock) on e.IDEmpleado = sp.IDEmpleado
		join [Nomina].[tblCatTiposPrestamo] ctp with (nolock) on ctp.IDTipoPrestamo = sp.IDTipoPrestamo
		join [Intranet].[tblCatEstatusSolicitudesPrestamos] cesp with (nolock) on cesp.IDEstatusSolicitudPrestamo = sp.IDEstatusSolicitudPrestamo 
		left join [Nomina].[tblCatEstatusPrestamo] cep on cep.IDEstatusPrestamo = sp.IDEstatusPrestamo
	where sp.IDEmpleado = @IDEmpleado
	and Sp.IDEstatusSolicitudPrestamo = 3
	and FechaCreacion>=@fechasanteriores
	
	Select @Documentos= Count(*)	
		from Intranet.tblSolicitudesEmpleado 
	where IDEmpleado = @IDEmpleado 
	and (IDTipoSolicitud = 3) 	
	and IDEstatusSolicitud = 2
	and FechaCreacion>=@fechasanteriores

	Select @Permisos as Permisos, @Prestamos as Prestamos, @Documentos as Documentos





END
GO

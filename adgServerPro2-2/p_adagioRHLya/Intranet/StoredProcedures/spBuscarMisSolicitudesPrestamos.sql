USE [p_adagioRHLya]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Intranet].[spBuscarMisSolicitudesPrestamos](
	@IDEmpleado int = 0
	,@IDUsuario int
) as

	select 
		sp.IDSolicitudPrestamo
		,sp.IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO as Colaborador
		,sp.IDTipoPrestamo
		,ctp.Descripcion as TipoPrestamo
		,isnull(sp.MontoPrestamo,0.00) as MontoPrestamo
		,isnull(sp.Cuotas, 0) as Cuotas
		,sp.CantidadCuotas
		,sp.FechaCreacion
		,sp.FechaInicioPago
		,sp.Autorizado
		,isnull(sp.IDUsuarioAutorizo,0) as IDUsuarioAutorizo
		,sp.FechaHoraAutorizacion
		,sp.Cancelado
		,isnull(sp.IDUsuarioCancelo,0) as IDUsuarioCancelo	   
		,sp.FechaHoraCancelacion
		,sp.MotivoCancelacion
		,isnull(sp.IDPrestamo,0) as IDPrestamo		   
		,sp.Descripcion
		,isnull(sp.Intereses,0.00) as Intereses		
		,sp.IDEstatusSolicitudPrestamo
		,cesp.Nombre as Estatus
		,cesp.CssClass
		,isnull(sp.IDFondoAhorro,0) as IDFondoAhorro	
	from [Intranet].[tblSolicitudesPrestamos] sp with (nolock)
		join [RH].[tblEmpleadosMaster] e with (nolock) on e.IDEmpleado = sp.IDEmpleado
		join [Nomina].[tblCatTiposPrestamo] ctp with (nolock) on ctp.IDTipoPrestamo = sp.IDTipoPrestamo
		join [Intranet].[tblCatEstatusSolicitudesPrestamos] cesp with (nolock) on cesp.IDEstatusSolicitudPrestamo = sp.IDEstatusSolicitudPrestamo 
	where sp.IDEmpleado = @IDEmpleado
GO

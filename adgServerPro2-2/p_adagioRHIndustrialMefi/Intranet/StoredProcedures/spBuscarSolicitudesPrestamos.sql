USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Intranet].[spBuscarSolicitudesPrestamos](
	@IDSolicitudPrestamo int = 0
	,@IDEstatusSolicitudPrestamo int = 0
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
		,isnull(sp.IDEstatusPrestamo, 0) as IDEstatusPrestamo
		,isnull(cep.Descripcion, 'Sin estatus préstamo') as EstatusPrestamo
	from [Intranet].[tblSolicitudesPrestamos] sp					with (nolock)
		join [RH].[tblEmpleadosMaster] e							with (nolock) on e.IDEmpleado					= sp.IDEmpleado
		join [Nomina].[tblCatTiposPrestamo] ctp						with (nolock) on ctp.IDTipoPrestamo				= sp.IDTipoPrestamo
		join [Intranet].[tblCatEstatusSolicitudesPrestamos] cesp	with (nolock) on cesp.IDEstatusSolicitudPrestamo = sp.IDEstatusSolicitudPrestamo 
		join [Seguridad].[tblDetalleFiltrosEmpleadosUsuarios] dfeu	with (nolock) on dfeu.IDEmpleado				= sp.IDEmpleado and dfeu.IDUsuario = @IDUsuario
		left join [Nomina].[tblCatEstatusPrestamo] cep				with (nolock) on cep.IDEstatusPrestamo			= sp.IDEstatusPrestamo
	where (sp.IDSolicitudPrestamo = isnull(@IDSolicitudPrestamo, 0) or isnull(@IDSolicitudPrestamo, 0) = 0)
		and (sp.IDEstatusSolicitudPrestamo = isnull(@IDEstatusSolicitudPrestamo, 0) or isnull(@IDEstatusSolicitudPrestamo, 0) = 0)
	order by sp.FechaCreacion desc
GO

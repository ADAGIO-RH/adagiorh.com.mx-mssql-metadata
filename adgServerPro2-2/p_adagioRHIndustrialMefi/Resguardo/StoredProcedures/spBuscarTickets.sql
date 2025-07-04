USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Resguardo].[spBuscarTickets](
	@IDHistorial int
) as
	select 
		 h.IDHistorial
		,caseta.IDCaseta
		,caseta.Nombre as Caseta
		,h.IDLocker
		,lockers.Codigo as Locker
		,h.IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO as Colaborador
		,h.IDArticulo
		,isnull(h.FechaRecibe , '1990-01-01') as FechaRecibe
		,isnull(h.FechaEntrega, '1990-01-01') as FechaEntrega
		,isnull(h.Entregado, 0) as Entregado
		,h.IDUsuarioRecibe
		,coalesce(uRecibe.Nombre,'')+' '+coalesce(uRecibe.Apellido, '') as UsuarioRecibe
		,isnull(h.IDUsuarioEntrega, 0) as IDUsuarioEntrega
		,case when isnull(h.IDUsuarioEntrega, 0) > 0 then coalesce(uRecibe.Nombre,'')+' '+coalesce(uRecibe.Apellido, '') else '[NO ENTREGADO]' end as UsuarioEntrega
		,isnull(h.TicketImpreso,0 ) as TicketImpreso
		,isnull(h.FechaHoraImpresion, '1990-01-01') as FechaHoraImpresion
		,isnull(h.TicketCancelado,0 ) as TicketCancelado
		,isnull(h.FechaHoraCancelacion,'1990-01-01') as FechaHoraCancelacion
		,isnull(h.IDUsuarioCancela, 0) as IDUsuarioCancela
		,case when isnull(h.IDUsuarioCancela, 0) > 0 then coalesce(uCancela.Nombre,'')+' '+coalesce(uCancela.Apellido, '') else '[NO CANCELADA]' end as UsuarioCancela
	from [Resguardo].[tblHistorial] h with (nolock)
		join [RH].[tblEmpleadosMaster] e with (nolock) on e.IDEmpleado = h.IDEmpleado
		join [Resguardo].[tblCatLockers] lockers with (nolock) on lockers.IDLocker = h.IDLocker
		join [Resguardo].[tblCatCasetas] caseta with (nolock) on caseta.IDCaseta = lockers.IDCaseta
		join [Seguridad].[tblUsuarios] uRecibe with (nolock) on uRecibe.IDUsuario = h.IDUsuarioRecibe
		left join [Seguridad].[tblUsuarios] uEntrega with (nolock) on uEntrega.IDUsuario = h.IDUsuarioEntrega
		left join [Seguridad].[tblUsuarios] uCancela with (nolock) on uCancela.IDUsuario = h.IDUsuarioCancela
	where h.IDHistorial = @IDHistorial
GO

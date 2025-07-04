USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc Reportes.spReciboResguardo(
		@IDs varchar(max)
		,@IDUsuario int	 
) as
	--declare
	--	@IDs varchar(max) = '15,16'
	--	,@IDUsuario int	 
	--;

	declare
		@Titulo varchar(255)
	;

	select @Titulo = Valor
	from App.tblConfiguracionesGenerales with (nolock)
	where IDConfiguracion = 'NombreEmpresaReportes'

	select 
		 h.IDHistorial
		,c.IDCaseta
		,c.Nombre as Caseta
		,h.IDLocker
		,l.Codigo as Locker
		,h.IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO as NombreCompleto
		,h.IDArticulo
		,ta.Nombre as Articulo
		,h.FechaRecibe
		,h.FechaEntrega
		,h.Entregado
		,h.IDUsuarioRecibe
		,coalesce(usuarioRecibe.Nombre,'')+' '+coalesce(usuarioRecibe.Apellido,'') as UsuarioRecibe
		,h.IDUsuarioEntrega
		,@Titulo as Titulo
	from Resguardo.tblHistorial h with (nolock)
		join Resguardo.tblArticulos a on a.IDArticulo = h.IDArticulo
		join Resguardo.tblCatTiposArticulos ta on ta.IDTipoArticulo = a.IDTipoArticulo
		join Resguardo.tblCatLockers l with (nolock) on l.IDLocker = h.IDLocker
		join Resguardo.tblCatCasetas c with (nolock) on c.IDCaseta = l.IDCaseta
		join RH.tblEmpleadosMaster e with (nolock) on h.IDEmpleado = e.IDEmpleado
		left join Seguridad.tblUsuarios usuarioRecibe with (nolock) on h.IDUsuarioRecibe = usuarioRecibe.IDUsuario 
	where h.IDHistorial in (select cast(item as int) from App.Split(@IDs,','))
GO

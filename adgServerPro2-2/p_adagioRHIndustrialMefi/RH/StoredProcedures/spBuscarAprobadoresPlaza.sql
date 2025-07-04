USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc RH.spBuscarAprobadoresPlaza(
	@IDPlaza int,
	@IDUsuario int
) as

	declare 
		@Secuencia int
	;

	select @Secuencia = MAX(Secuencia) from RH.tblAprobadoresPlazas where IDPlaza = @IDPlaza

	select 
		ap.IDAprobadorPlaza
		,ap.IDPlaza
		,ap.IDUsuario
		,u.Cuenta
		,coalesce(u.Nombre,'') +' '+coalesce(u.Apellido,'') as Usuario
		,ap.Aprobacion
		,ap.Observacion
		,ap.FechaAprobacion
		,ap.Secuencia
		,ap.Orden
	from RH.tblAprobadoresPlazas ap with (nolock)
		join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = ap.IDUsuario
	where ap.IDPlaza = @IDPlaza and ap.Secuencia = @Secuencia
	order by ap.Orden
GO

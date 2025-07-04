USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc RH.spBuscarAprobadoresPosicion(
	@IDPosicion int,
	@IDUsuario int
) as

	declare 
		@Secuencia int
	;

	select @Secuencia = MAX(Secuencia) from RH.tblAprobadoresPosiciones where IDPosicion = @IDPosicion

	select 
		ap.IDAprobadorPosicion
		,ap.IDPosicion
		,ap.IDUsuario
		,u.Cuenta
		,coalesce(u.Nombre,'') +' '+coalesce(u.Apellido,'') as Usuario
		,ap.Aprobacion
		,ap.Observacion
		,ap.FechaAprobacion
		,ap.Secuencia
		,ap.Orden
	from RH.tblAprobadoresPosiciones ap with (nolock)
		join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = ap.IDUsuario
	where ap.IDPosicion = @IDPosicion and ap.Secuencia = @Secuencia
	order by ap.Orden
GO

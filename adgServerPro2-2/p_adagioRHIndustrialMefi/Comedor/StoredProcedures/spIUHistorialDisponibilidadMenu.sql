USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create   proc Comedor.spIUHistorialDisponibilidadMenu(
	@IDHistorialDisponibilidadMenu int = 0,
	@IDMenu int,
	@FechaInicio date,
	@FechaFin date,
	@HoraInicio time,
	@HoraFin time,
	@Activo bit,
	@OpcionesArticulosDisponbibles varchar(max),
	@IDUsuario int
) as

	if (isnull(@IDHistorialDisponibilidadMenu, 0) = 0)
	begin
		insert Comedor.tblHistorialDisponibilidadMenu(IDMenu, FechaInicio, FechaFin, HoraInicio, HoraFin, OpcionesArticulosDisponbibles, Activo)
		select @IDMenu, @FechaInicio, @FechaFin, @HoraInicio, @HoraFin, @OpcionesArticulosDisponbibles, @Activo
	end else
	begin
		update Comedor.tblHistorialDisponibilidadMenu
			set
				FechaInicio	= @FechaInicio,
				FechaFin	= @FechaFin,
				HoraInicio	= @HoraInicio,
				HoraFin		= @HoraFin,
				Activo		= @Activo,
				OpcionesArticulosDisponbibles = @OpcionesArticulosDisponbibles
		where IDHistorialDisponibilidadMenu = @IDHistorialDisponibilidadMenu
	end
GO

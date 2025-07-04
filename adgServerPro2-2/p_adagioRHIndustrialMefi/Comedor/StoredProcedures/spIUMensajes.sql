USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Comedor].[spIUMensajes](
	@IDMensaje int = 0,
	@Mensaje varchar(max),
	@TipoMensaje varchar(10),
	@FechaIni date,
	@FechaFin date,
	@IdsRestaurantes varchar(max),
	@IDUsuario int 
) as

	if (@IDMensaje = 0) 
	begin
		insert Comedor.tblMensajes(Mensaje, TipoMensaje, FechaIni, FechaFin, IdsRestaurantes, IDUsuario)
		values(@Mensaje, @TipoMensaje, @FechaIni, @FechaFin, @IdsRestaurantes, @IDUsuario)
	end
	else 
	begin
		update Comedor.tblMensajes
			set Mensaje = @Mensaje,
				TipoMensaje = @TipoMensaje,
				FechaIni = @FechaIni,
				FechaFin = @FechaFin,
				IdsRestaurantes = @IdsRestaurantes
		where IDMensaje = @IDMensaje
	end
GO

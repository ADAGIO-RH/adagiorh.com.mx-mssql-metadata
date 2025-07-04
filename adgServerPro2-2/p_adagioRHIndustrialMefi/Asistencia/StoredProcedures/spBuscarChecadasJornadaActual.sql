USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create   proc Asistencia.spBuscarChecadasJornadaActual (
	@IDEmpleado int,
	@ZonaHoraria varchar(100) = 'America/Mexico_City'
) as
	declare 
		--@IDEmpleado int = 1279,
		@Entrada datetime,
		@Salida datetime,
		@Hoy date = getdate(),
		@IDZonaHorariaEntrada int,
		@IDZonaHorariaSalida int,
		@ZonaHorariaEntrada varchar(50),
		@ZonaHorariaSalida varchar(50),
		@ID_ZONA_HORARIA_DEFULT int = 161, --America/Mexico_City
		@ZONA_HORARIA_DEFULT varchar(50) = 'America/Mexico_City'
	;

	select top 1 
		@Entrada = c.Fecha,
		@IDZonaHorariaEntrada = isnull(c.IDZonaHoraria, @ID_ZONA_HORARIA_DEFULT),
		@ZonaHorariaEntrada = isnull(z.[Name], @ZONA_HORARIA_DEFULT)
	from Asistencia.tblChecadas c
		left join Tzdb.Zones z on z.ID = c.IDZonaHoraria
	where c.IDEmpleado = @IDEmpleado and c.IDTipoChecada in ('ET', 'SH') and c.FechaOrigen = @Hoy
	order by c.Fecha asc

	select top 1 
		@Salida = c.Fecha,
		@IDZonaHorariaSalida = isnull(c.IDZonaHoraria, @ID_ZONA_HORARIA_DEFULT),
		@ZonaHorariaSalida = isnull(z.[Name], @ZONA_HORARIA_DEFULT)
	from Asistencia.tblChecadas c
		left join Tzdb.Zones z on z.ID = c.IDZonaHoraria
	where c.IDEmpleado = @IDEmpleado and c.IDTipoChecada = 'ST' and c.FechaOrigen = @Hoy
	order by c.Fecha desc

	SELECT 
		[Tzdb].[ConvertZone](@Entrada, @ZonaHorariaEntrada, @ZonaHoraria,1 ,1) as Entrada,
		[Tzdb].[ConvertZone](@Salida, @ZonaHorariaSalida, @ZonaHoraria,1 ,1) as Salida
GO

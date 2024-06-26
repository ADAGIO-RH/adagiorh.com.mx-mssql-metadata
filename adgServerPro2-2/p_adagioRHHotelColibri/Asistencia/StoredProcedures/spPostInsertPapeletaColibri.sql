USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spPostInsertPapeletaColibri](
	@IDPapeleta int,
	@IDUsuario int
) as

	declare 
		@Periodo varchar(max)
		,@IDEmpleado int
		,@SaldoVacaciones decimal(18, 2)
		,@Fecha date
		,@Duracion int
		,@IDIncidencia varchar(10)
		,@tblVacaciones [Asistencia].[dtSaldosDeVacaciones] 
	;

	select 
		@IDEmpleado = IDEmpleado
		,@Fecha = Fecha
		,@Duracion = Duracion
		,@IDIncidencia = IDIncidencia
		from Asistencia.tblPapeletas
		where IDPapeleta = @IDPapeleta

------ Determina Periodo

	if @IDIncidencia = 'V'
	begin
		--declare @tblVacaciones as table (
		--					Anio int
		--					,FechaIni date
		--					,FechaFin date
		--					,Dias int
		--					,DiasTomados int
		--					,DiasVencidos int
		--					,DiasDisponibles decimal(18, 2)
		--					,TipoPrestacion varchar(200)
		--				)

		--DELETE FROM @tblVacaciones

		insert into @tblVacaciones
		exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado = @IDEmpleado, @Proporcional = 1, @FechaBaja = null, @IDUsuario = 1

		select top 1 @Periodo = Anio 
			from @tblVacaciones
			where DiasDisponibles <> 0
			order by Anio

------------

		if not exists (
			select top 1 1 
				from Asistencia.tblPapeletaPeriodo
				where IDPapeleta = @IDPapeleta
		)
		begin
			insert Asistencia.tblPapeletaPeriodo
			values(@IDPapeleta, @IDUsuario, @Periodo, @Fecha, @Duracion )
		end else
		begin
			update Asistencia.tblPapeletaPeriodo
				set Periodo = @Periodo
					,Fecha = @Fecha
					,Duracion = @Duracion
				where IDPapeleta = @IDPapeleta
					and (Fecha <> @Fecha or Duracion <> @Duracion )
		end
	end
GO

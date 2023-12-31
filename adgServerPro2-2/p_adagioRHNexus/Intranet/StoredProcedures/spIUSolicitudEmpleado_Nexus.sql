USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Crea y actualiza Solicitudes de intranet
** Autor			: Jose Roman
** Email			: jroman@adagio.com.mx
** FechaCreacion	: 2018-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
------------------- ------------------- ------------------------------------------------------------
2022-04-01			Emmanuel Contreras	Se agregó FechaFin y se hace el calculo para guardar cuando 
										terminará la solicitud 

EXEC  [Intranet].[spIUSolicitudEmpleado]
	 @IDSolicitud				= 0
	,@IDEmpleado				= 1279
	,@IDTipoSolicitud			= 1
	,@IDEstatusSolicitud		= 1
	,@IDIncidencia				= 'V'
	,@FechaIni					= '2022-09-01'
	,@CantidadDias				= 20
	,@DiasDescanso				= '1,7'
	,@ComentarioEmpleado		= null
	,@ComentarioSupervisor		= null
	,@CantidadMonto				= null
	,@IDUsuario					= 1
------------------- ------------------- ------------------------------------------------------------
2022-04-06			Emmanuel Contreras	Se agrego campo DiasDisponibles a la tabla 
										Intranet.tblSolicitudesEmpleado y se calculan los días que 
										quedan disponibles al momento de solicitar vacaciones/permisos

***************************************************************************************************/
Create PROCEDURE [Intranet].[spIUSolicitudEmpleado_Nexus](
	 @IDSolicitud int = 0
	,@IDEmpleado int 
	,@IDTipoSolicitud int 
	,@IDEstatusSolicitud int 
	,@IDIncidencia varchar(10) null 
	,@FechaIni Date null
	,@CantidadDias int null
	,@DiasDescanso Varchar(20) null
	,@ComentarioEmpleado Varchar(MAX) =''
	,@ComentarioSupervisor Varchar(MAX) =''
	,@CantidadMonto Decimal(18,2) = null
	,@IDUsuarioAutoriza int = null 
	,@IDUsuario int  = null
)
AS
BEGIN
	declare 
		@FechaFinCalculo date = null,
		@JsonErrorsSaldosDisponible varchar(max) = N'
			{
				"esmx": {
					"message": "No tienes saldo de vacaciones disponible. Tu saldo es de %d días."
				},
				"enus": {
					"message": "You do not have an available vacation balance. Your balance is %d days."
				}
			}
		',
		@ErrorMessageNoTieneSaldoDisponible varchar(max),
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if object_id('tempdb..#tblFechaFin') is not null drop table #tblFechaFin;	

	create table #tblFechaFin(Fecha date);

	if (@IDTipoSolicitud  = 1) 
	BEGIN
		if ((select Sum(cast(item as int))
				from App.split(@DiasDescanso, ',')) = 28)				
		begin
			--raiserror('No puedes seleccionar todos los días de la semana como días de descanso.', 16,1)
			exec [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0611003'
			return
		end
	END
	
	if(@IDTipoSolicitud = 1)
	begin
		exec [Asistencia].[spFechaFinVacacionesOutPut]
			@IDEmpleado = @IDEmpleado,
			@Fecha		= @FechaIni,
			@Duracion	= @CantidadDias,
			@DiasDescanso	= @DiasDescanso,
			@IDUsuario		= @IDUsuario,
			@FechaFinCalculo = @FechaFinCalculo out
	end

	DECLARE @tempResponse AS TABLE (
		ID INT,
		IDIncidenciaSaldo INT,
		IDIncidencia VARCHAR(10),
		Descripcion VARCHAR(255),
		FechaInicio DATE,
		FechaFin DATE,
		FechaRegistro DATETIME,
		Cantidad INT,
		IncTomadas INT,
		IncVencidas INT,
		IncDisponibles INT,
		TotalPaginas INT
	);

	IF(@IDSolicitud = 0)
	BEGIN
		IF(@IDTipoSolicitud = 1 OR @IDTipoSolicitud = 2)
		BEGIN

        if(@IDIncidencia is null) 
        begin 
        raiserror('Seleccione una incidencia', 16, 1)
		RETURN
        end
			if ((select isnull(AdministrarSaldos, 0) from Asistencia.tblCatIncidencias where IDIncidencia = @IDIncidencia) = 1)
			begin
				insert @tempResponse(ID, IDIncidenciaSaldo, IDIncidencia, Descripcion, FechaInicio, FechaFin, FechaRegistro, Cantidad, IncTomadas, IncVencidas, IncDisponibles, TotalPaginas)
				exec [Asistencia].[spBuscarIncidenciasSaldos]
					@IDIncidenciaSaldo = 0,
					@IDEmpleado = @IDEmpleado,
					@IDIncidencia = @IDIncidencia,
					@IDUsuario=@IDUsuario

				if not exists(select top 1 1 from @tempResponse where @FechaIni between FechaInicio and FechaFin and IncDisponibles >= @CantidadDias)
				begin
					--raiserror('No tienes saldos disponibles en esta fecha.', 16, 1)
					exec [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0611004'
					return
				end
				if @IDInCidencia = 'NULL'
				BEGIN
						raiserror('No tienes saldos disponibles en esta fecha.', 16, 1)
						RETURN
				END
			end

			declare @DiasDisponibles int = 0
			declare @tblTempVacaciones as table(
				Anio int
				,FechaIni date
				,FechaFin date
				,Dias int
				,DiasTomados int
				,DiasVencidos int
				,DiasDisponibles decimal(18,2)
				,TipoPrestacion Varchar(200)
			)

		
			if (@IDIncidencia = 'V')
			begin
				insert into @tblTempVacaciones
					exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado,0,@FechaIni,@IDUsuario
					select @DiasDisponibles = isnull(floor(sum(DiasDisponibles)),0) from @tblTempVacaciones
                
				if (@DiasDisponibles < @CantidadDias)
				begin
					set @ErrorMessageNoTieneSaldoDisponible = JSON_VALUE(@JsonErrorsSaldosDisponible, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'message'))
					set @ErrorMessageNoTieneSaldoDisponible  = FORMATMESSAGE(@ErrorMessageNoTieneSaldoDisponible, @DiasDisponibles)

					raiserror(@ErrorMessageNoTieneSaldoDisponible, 16, 1)
					return
				end

			end

			INSERT INTO Intranet.tblSolicitudesEmpleado(IDEmpleado, IDTipoSolicitud,IDEstatusSolicitud,IDIncidencia, FechaIni, CantidadDias,FechaCreacion,ComentarioEmpleado, DiasDescanso, FechaFin, DiasDisponibles)
			VALUES(@IDEmpleado,@IDTipoSolicitud,@IDEstatusSolicitud,@IDIncidencia, @FechaIni, @CantidadDias,GETDATE(), @ComentarioEmpleado,@DiasDescanso, @FechaFinCalculo, @DiasDisponibles)

			set @IDSolicitud = @@IDENTITY
		END
		IF(@IDTipoSolicitud = 3)
		BEGIN
			INSERT INTO Intranet.tblSolicitudesEmpleado(IDEmpleado, IDTipoSolicitud,IDEstatusSolicitud,ComentarioEmpleado,FechaCreacion)
			VALUES(@IDEmpleado, @IDTipoSolicitud,@IDEstatusSolicitud,@ComentarioEmpleado,GETDATE())
				
			set @IDSolicitud = @@IDENTITY
		END
		IF(@IDTipoSolicitud = 4)
		BEGIN
			INSERT INTO Intranet.tblSolicitudesEmpleado(IDEmpleado, IDTipoSolicitud,IDEstatusSolicitud,ComentarioEmpleado,FechaCreacion,CantidadMonto)
			VALUES(@IDEmpleado, @IDTipoSolicitud,@IDEstatusSolicitud,@ComentarioEmpleado,GETDATE(),@CantidadMonto)

			set @IDSolicitud = @@IDENTITY
		END

		EXEC [App].[INotificacionSolicitudIntranet] @IDSolicitud = @IDSolicitud, @TipoCambio ='CREATE-SUPERVISOR'
		EXEC [App].[INotificacionSolicitudIntranet] @IDSolicitud = @IDSolicitud, @TipoCambio ='CREATE-USUARIO'
	END
	ELSE
	BEGIN
		IF(@IDTipoSolicitud = 1 OR @IDTipoSolicitud = 2)
		BEGIN
			UPDATE Intranet.tblSolicitudesEmpleado
				SET IDEstatusSolicitud = @IDEstatusSolicitud
					,FechaIni = @FechaIni
					,CantidadDias = @CantidadDias
					,DiasDescanso = @DiasDescanso
					,ComentarioEmpleado = @ComentarioEmpleado
					,ComentarioSupervisor = @ComentarioSupervisor
			WHERE IDSolicitud = @IDSolicitud and IDEmpleado = @IDEmpleado
		END
		IF(@IDTipoSolicitud = 3)
		BEGIN
			UPDATE Intranet.tblSolicitudesEmpleado
				SET IDEstatusSolicitud = @IDEstatusSolicitud
					,ComentarioEmpleado = @ComentarioEmpleado
					,ComentarioSupervisor = @ComentarioSupervisor
			WHERE IDSolicitud = @IDSolicitud and IDEmpleado = @IDEmpleado
		END
		IF(@IDTipoSolicitud = 4)
		BEGIN
			UPDATE Intranet.tblSolicitudesEmpleado
				SET IDEstatusSolicitud = @IDEstatusSolicitud
					,CantidadMonto = @CantidadMonto
					,ComentarioEmpleado = @ComentarioEmpleado
					,ComentarioSupervisor = @ComentarioSupervisor
			WHERE IDSolicitud = @IDSolicitud and IDEmpleado = @IDEmpleado
		END	

		EXEC [App].[INotificacionSolicitudIntranet] @IDSolicitud = @IDSolicitud, @TipoCambio ='UPDATE-SUPERVISOR'
		EXEC [App].[INotificacionSolicitudIntranet] @IDSolicitud = @IDSolicitud, @TipoCambio ='UPDATE-USUARIO'
	END

	EXEC Intranet.spBuscarSolicitudesEmpleados @IDSolicitud = @IDSolicitud,@IDEmpleado = @IDEmpleado, @IDUsuario = @IDUsuario
END


select*from Intranet.tblCatTipoSolicitud
GO

USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp se usa solo para que el colaborador cree y/o actualice su solicitud.
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2021-03-09
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Intranet].[spIUSolicitudesPrestamos](
	@IDSolicitudPrestamo int = 0
	,@IDEmpleado int
	,@IDTipoPrestamo int
	,@MontoPrestamo decimal(18, 2)
	,@Cuotas decimal(18, 2)
	,@CantidadCuotas int
	,@FechaInicioPago date
	,@MotivoCancelacion varchar(max)
	,@Descripcion varchar(max)
	,@Intereses decimal(18, 2)
	,@IDEstatusSolicitudPrestamo int
	,@IDFondoAhorro int = null
	,@IDEstatusPrestamo int = null
	,@IDUsuario int
) as
begin

	declare 
		@IDEstatusSolicitudPrestamoActual int,
		@Cancelado bit,
		@FechaHoraCancelacion datetime,
		@Autorizado bit,
		@FechaHoraAutorizacion datetime,
		@IDPrestamo int,

		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Intranet].[spIUSolicitudesPrestamos]',
		@Tabla		varchar(max) = '[Intranet].[tblSolicitudesPrestamos]',
		@Accion		varchar(20)	= '',
		@EnviarNotificacion bit = 0
	;

	declare @tempPrestamo as table (
		[IDPrestamo]		int,
		[Codigo]			varchar(20),
		[IDEmpleado]		int,
		[ClaveEmpleado]		varchar(20),
		[Nombre]			varchar(150),
		[SegundoNombre]		varchar(150),
		[Paterno]			varchar(150),
		[Materno]			varchar(150),
		[NOMBRECOMPLETO]	varchar(500),
		[IDTipoPrestamo]	int,
		[TipoPrestamo]		varchar(100),
		[IDEstatusPrestamo]	int,
		[EstatusPrestamo]	varchar(20),
		[MontoPrestamo]		decimal(18, 2),
		[Cuotas]			decimal(18, 2),
		[CantidadCuotas]	int,
		[Descripcion]		varchar(max),
		[FechaCreacion]		date,
		[FechaInicioPago]	date,
		[Balance]			decimal(38, 4),
		[Intereses]			decimal(18, 2),
		[ROWNUMBER]			bigint
	)

	set @IDFondoAhorro		= case when @IDFondoAhorro		= 0 then null else @IDFondoAhorro end
	set @IDEstatusPrestamo	= case when @IDEstatusPrestamo	= 0 then null else @IDEstatusPrestamo end

	if (isnull(@IDSolicitudPrestamo,0) = 0)
	begin
		insert [Intranet].[tblSolicitudesPrestamos](IDEmpleado, IDTipoPrestamo, MontoPrestamo, Cuotas, CantidadCuotas, FechaInicioPago, IDEstatusSolicitudPrestamo, FechaCreacion, IDFondoAhorro, IDEstatusPrestamo)
		values(@IDEmpleado, @IDTipoPrestamo, @MontoPrestamo, @Cuotas, @CantidadCuotas, @FechaInicioPago, @IDEstatusSolicitudPrestamo, getdate(), @IDFondoAhorro, @IDEstatusPrestamo)

		set @IDSolicitudPrestamo = @@IDENTITY

		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from [Intranet].[tblSolicitudesPrestamos] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE b.IDSolicitudPrestamo = @IDSolicitudPrestamo

		set @EnviarNotificacion = 1
	end else 
	begin
		select @OldJSON = a.JSON
			,@Accion = 'UPDATE'
		from [Intranet].[tblSolicitudesPrestamos] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE b.IDSolicitudPrestamo = @IDSolicitudPrestamo

		select 
			@IDEstatusSolicitudPrestamoActual	= IDEstatusSolicitudPrestamo
			--@IDEstatusPrestamo					= IDEstatusPrestamo,
			--@FechaHoraCancelacion				= FechaHoraCancelacion,
			--@FechaHoraAutorizacion				= FechaHoraAutorizacion,
			--@IDPrestamo							= IDPrestamo
		from [Intranet].[tblSolicitudesPrestamos] with (nolock)
		where IDSolicitudPrestamo = @IDSolicitudPrestamo 

		set @EnviarNotificacion = case when @IDEstatusSolicitudPrestamoActual <> @IDEstatusSolicitudPrestamo then 1 else 0 end

		if (@IDEstatusSolicitudPrestamo = 1) 
		begin
			select @Cancelado = 0, @Autorizado = 0
		end

		-- SOLICITUD CANCELADA
		if(@IDEstatusSolicitudPrestamoActual = 1 and @IDEstatusSolicitudPrestamo = 2) 
		begin
			select 
				@Cancelado = 1, 
				@Autorizado = null,
				@FechaHoraCancelacion = getdate()
		end

		-- SOLICITUD AUTORIZADA
		if(@IDEstatusSolicitudPrestamoActual = 1 and @IDEstatusSolicitudPrestamo = 3) 
		begin
			select 
				@Cancelado = null, 
				@Autorizado = 1,
				@FechaHoraAutorizacion = getdate()

			insert @tempPrestamo
			exec [Nomina].[spUIPrestamos] 
					@IDPrestamo			= 0  
					,@Codigo			= ''
					,@IDEmpleado		= @IDEmpleado  
					,@IDTipoPrestamo	= @IDTipoPrestamo  
					,@IDEstatusPrestamo	= @IDEstatusPrestamo  
					,@MontoPrestamo		= @MontoPrestamo
					,@Cuotas			= @Cuotas
					,@CantidadCuotas	= @CantidadCuotas  
					,@Descripcion		= @Descripcion
					,@FechaInicioPago	= @FechaInicioPago 
					,@Intereses			= @Intereses
					,@IDUsuario			= @IDUsuario 
			
			select @IDPrestamo = IDPrestamo from @tempPrestamo

			if (@IDTipoPrestamo = 6) -- Préstamo de Fondo de ahorro
			begin
				exec [Nomina].[spIUPrestamoFondoAhorro]
					 @IDPrestamoFondoAhorro	= 0
					,@IDFondoAhorro			= @IDFondoAhorro
					,@IDEmpleado			= @IDEmpleado
					,@Monto					= @MontoPrestamo
					,@IDPrestamo			= @IDPrestamo
					,@IDUsuario				= @IDUsuario
			end
		end

		-- SOLICITUD NO AUTORIZADA
		if(@IDEstatusSolicitudPrestamoActual = 1 and @IDEstatusSolicitudPrestamo = 4) 
		begin
			select 
				@Cancelado = null, 
				@Autorizado = 0
		end

		update [Intranet].[tblSolicitudesPrestamos]
			set IDTipoPrestamo	= @IDTipoPrestamo, 
				MontoPrestamo	= @MontoPrestamo, 
				Cuotas			= @Cuotas,
				CantidadCuotas	= @CantidadCuotas, 
				FechaInicioPago	= @FechaInicioPago,
				Cancelado		= @Cancelado,
				FechaHoraCancelacion	= @FechaHoraCancelacion,
				Autorizado				= @Autorizado,
				FechaHoraAutorizacion	= @FechaHoraAutorizacion,
				MotivoCancelacion		= @MotivoCancelacion,
				Intereses				= @Intereses,
				IDEstatusSolicitudPrestamo	= @IDEstatusSolicitudPrestamo,
				IDEstatusPrestamo		= @IDEstatusPrestamo,
				IDPrestamo				= @IDPrestamo,
				Descripcion				= @Descripcion,
				IDFondoAhorro			= @IDFondoAhorro
		where IDSolicitudPrestamo = @IDSolicitudPrestamo

		select @NewJSON = a.JSON
			,@Accion = 'UPDATE'
		from [Intranet].[tblSolicitudesPrestamos] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE b.IDSolicitudPrestamo = @IDSolicitudPrestamo
	end

	if (@EnviarNotificacion = 1)
	begin
		exec [App].[spINotificacioSolicitudPrestamoIntranet] @IDSolicitudPrestamo
	end

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON
end
GO

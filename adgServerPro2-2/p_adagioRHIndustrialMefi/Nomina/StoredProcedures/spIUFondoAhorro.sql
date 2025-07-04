USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Nomina].[spIUFondoAhorro](
	 @IDFondoAhorro		int 
	,@IDTipoNomina		int 
	,@Ejercicio			int 
	,@IDPeriodoInicial	int 
	,@IDPeriodoFinal	int 
	,@IDPeriodoPago	int 
	,@IDUsuario int
) as
	declare 
		 @FechaFinPeriodoInicial date
		,@FechaFinPeriodoFinal date
		,@FechaFinPeriodoPago date
		,@PeriodoDePagoCerrado bit = 0
	;

	declare 
		@OldJSON Varchar(Max) = '',
		@NewJSON Varchar(Max),
		@NombreSP	varchar(max) = '[Nomina].[spIUFondoAhorro]',
		@Tabla		varchar(max) = '[Nomina].[tblCatFondosAhorro]',
		@Accion		varchar(20)	= ''
	;

	select
		@IDPeriodoPago = case when @IDPeriodoPago = 0 then null else @IDPeriodoPago end
		,@IDPeriodoFinal = case when @IDPeriodoFinal = 0 then null else @IDPeriodoFinal end

	select @FechaFinPeriodoInicial	= FechaFinPago from Nomina.tblCatPeriodos with(nolock) where IDPeriodo = @IDPeriodoInicial
	select @FechaFinPeriodoFinal	= FechaFinPago from Nomina.tblCatPeriodos with(nolock) where IDPeriodo = @IDPeriodoFinal
	select @FechaFinPeriodoPago		= FechaFinPago,@PeriodoDePagoCerrado = Cerrado from Nomina.tblCatPeriodos with(nolock) where IDPeriodo = @IDPeriodoPago


	-- Validaciones de periodos
	if (@IDPeriodoFinal is not null)
	begin
		if (isnull(@FechaFinPeriodoFinal,'1900-01-01') <= isnull(@FechaFinPeriodoInicial,'1900-01-01'))
		begin
			exec App.spObtenerError @IDUsuario=@IDUsuario,@CodigoError='0410006'
			return;
		end;
	end;

	if (@IDPeriodoPago is not null)
	begin	
		if (isnull(@FechaFinPeriodoPago,'1900-01-01') <= isnull(@FechaFinPeriodoFinal,'1900-01-01'))
		begin
			exec App.spObtenerError @IDUsuario=@IDUsuario,@CodigoError='0410007'
			return;
		end;
	
		if (isnull(@PeriodoDePagoCerrado,0) = 1)
		begin
			exec App.spObtenerError @IDUsuario=@IDUsuario,@CodigoError='0410008'
			return;
		end;
	end;


	if (@IDFondoAhorro = 0)
	begin
		if exists (select top 1 1 
					from Nomina.tblCatFondosAhorro with (nolock)
					where IDTipoNomina = @IDTipoNomina and Ejercicio = @Ejercicio)
		begin
			exec App.spObtenerError @IDUsuario=@IDUsuario,@CodigoError='0410003'
			return;
		end;

		insert into Nomina.tblCatFondosAhorro(IDTipoNomina,Ejercicio,IDPeriodoInicial,IDPeriodoFinal,IDPeriodoPago,IDUsuario)
		select @IDTipoNomina,@Ejercicio,@IDPeriodoInicial,@IDPeriodoFinal,@IDPeriodoPago,@IDUsuario

		set @IDFondoAhorro = @@IDENTITY

		select @NewJSON = a.JSON
			,@Accion = 'INSERT'
		from [Nomina].tblCatFondosAhorro b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDFondoAhorro = @IDFondoAhorro
	end else 
	begin
		select @OldJSON = a.JSON
			,@Accion = 'UPDATE'
		from [Nomina].tblCatFondosAhorro b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDFondoAhorro = @IDFondoAhorro

		update Nomina.tblCatFondosAhorro
			set  IDTipoNomina	  = @IDTipoNomina
				,Ejercicio		  = @Ejercicio
				,IDPeriodoInicial = @IDPeriodoInicial
				,IDPeriodoFinal	  = @IDPeriodoFinal
				,IDPeriodoPago	  = @IDPeriodoPago
		where IDFondoAhorro = @IDFondoAhorro

		select @NewJSON = a.JSON
		from [Nomina].tblCatFondosAhorro b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select b.* For XML Raw)) ) a
		WHERE IDFondoAhorro = @IDFondoAhorro
	end;

	EXEC [Auditoria].[spIAuditoria]
		@IDUsuario		= @IDUsuario
		,@Tabla			= @Tabla
		,@Procedimiento	= @NombreSP
		,@Accion		= @Accion
		,@NewData		= @NewJSON
		,@OldData		= @OldJSON

	exec Nomina.spBuscarFondosAhorro @IDFondoAhorro = @IDFondoAhorro, @IDUsuario = @IDUsuario
GO

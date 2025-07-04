USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spIUProyecto](
	 @IDProyecto int
	,@Nombre varchar(255) 
	,@Descripcion nvarchar(max)	
	,@AutoEvaluacion bit = 0	
	,@IDUsuario int
	,@Introduccion nvarchar(max)
	,@Indicacion nvarchar(max)	
	,@IDTipoProyecto int
	,@Privacidad bit = 0
) AS
	declare 
		@IDEscalaValoracion int
		,@Min int = 0
		,@Max int = 0
		,@Row int = 0
		,@ConfigAutoevaluacionRequerida nvarchar(max)
		,@ConfiguracionTipoProyecto varchar(max)
		,@ID_TIPO_PROYECTO_CLIMA_LABORAL int = 3
		,@ID_TIPO_PROYECTO_DESEMPENIO int = 2
		,@ID_TIPO_RELACION_JEFE_DIRECTO int = 1
	;

	select @ConfiguracionTipoProyecto = Configuracion
	from [Evaluacion360].[tblCatTiposProyectos]
	where IDTipoProyecto = @IDTipoProyecto

	declare @tempEscalaProyecto as table (
		IDEscalaValoracion int, 
		Total int,
		Row int
	);
 
	select
		@Nombre = UPPER(@Nombre)
		,@Descripcion = UPPER(@Descripcion)
	;

	if (@Nombre is null)
	begin
		raiserror('Ingrese el nombre del proyecto antes de continuar.',16,1);
		return;
	end;

	IF(@IDTipoProyecto = @ID_TIPO_PROYECTO_CLIMA_LABORAL)
		BEGIN
			SET @Privacidad = 1
		END

	if (isnull(@IDProyecto, 0) = 0)
	begin
		insert into [Evaluacion360].[tblCatProyectos](Nombre, Descripcion, FechaCreacion, IDUsuario, Introduccion, Indicacion, IDTipoProyecto, Privacidad)
		select @Nombre, @Descripcion, getdate(), @IDUsuario, @Introduccion, @Indicacion, @IDTipoProyecto, @Privacidad

		set @IDProyecto = @@IDENTITY

		INSERT [Evaluacion360].[tblEstatusProyectos] ([IDProyecto],[IDEstatus],[IDUsuario])
		values(@IDProyecto,1,@IDUsuario)

		insert Evaluacion360.tblAdministradoresProyecto(IDProyecto, IDUsuario, CreadoPorIDUsuario)
		values(@IDProyecto, @IDUsuario, @IDUsuario)

		exec [Evaluacion360].[spActualizarTotalEvaluacionesPorEstatus]

		insert @tempEscalaProyecto
		select 
			IDEscalaValoracion, 
			Total,
			ROW_NUMBER()over(order By Total asc) as [Row]
		from (
			select ev.IDEscalaValoracion,Sum(dev.Valor)  as Total
			from Evaluacion360.tblCatEscalaValoracion ev with (nolock)
				join Evaluacion360.tblDetalleEscalaValoracion dev with (nolock) on ev.IDEscalaValoracion = dev.IDEscalaValoracion
			Group by ev.IDEscalaValoracion ) escalas

		if exists (select top 1 1 from @tempEscalaProyecto)
		begin
			select @Min = min(Row)
				 , @Max = max(row) from @tempEscalaProyecto

			set @Row = @Max / 2;

			select top 1 @IDEscalaValoracion = IDEscalaValoracion
			from @tempEscalaProyecto
			where [Row] = @Row		
			
			insert Evaluacion360.tblEscalasValoracionesProyectos (IDProyecto,Nombre,Valor)
			select @IDProyecto,Nombre, Valor
			from Evaluacion360.tblDetalleEscalaValoracion with (nolock)
			where IDEscalaValoracion = @IDEscalaValoracion
		end;

		if (@IDTipoProyecto = @ID_TIPO_PROYECTO_CLIMA_LABORAL)
		begin
			insert [Evaluacion360].[tblEscalaSatisfaccionGeneral](Nombre, Descripcion, [Min], [Max], Color, IndiceSatisfaccion, IDProyecto)
			SELECT 
				Nombre,
				Descripcion,
				[Min],
				[Max],
				Color,
				IndiceSatisfaccion,
				@IDProyecto
			FROM OPENJSON(@ConfiguracionTipoProyecto, '$.Escalas.Satisfaccion') 
				with (
					IDEscalaSatisfaccion int,
					Nombre varchar(255),
					Descripcion varchar(255),
					[Min] float,
					[Max] float,
					Color varchar(255),
					IndiceSatisfaccion int
				)
			AS config


			insert Evaluacion360.tblEscalaRelevanciaIndicadores(Descripcion, [Min], [Max], IndiceRelevancia, IDProyecto)
			SELECT 
				Descripcion,
				[Min],
				[Max],
				IndiceRelevancia,
				@IDProyecto
			FROM OPENJSON(@ConfiguracionTipoProyecto, '$.Escalas.Relevancia') 
				with (
					Descripcion varchar(255),
					[Min] float,
					[Max] float,
					IndiceRelevancia int
				)
			AS config
		end

		IF (@IDTipoProyecto = @ID_TIPO_PROYECTO_DESEMPENIO)
		BEGIN
			INSERT INTO [Evaluacion360].[tblEvaluadoresRequeridos] VALUES (@IDProyecto, @ID_TIPO_RELACION_JEFE_DIRECTO, 1, 1)		
		END

		exec [Evaluacion360].[spIniciarWizardUsuario]
			@IDProyecto = @IDProyecto 
			,@IDUsuario = @IDUsuario
	end else
	BEGIN

		begin try
			EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto,@IDUsuario = @IDUsuario
		end try
		begin catch
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
			return 0;
		end catch

		update [Evaluacion360].[tblCatProyectos]
			set Nombre = @Nombre
			   ,Descripcion = @Descripcion
			   ,Introduccion = @Introduccion
			   ,Indicacion = @Indicacion
			   ,Privacidad = @Privacidad
		where IDProyecto = @IDProyecto
	end;
	
	IF ((@AutoEvaluacion = 1) AND NOT EXISTS (SELECT TOP 1 1 
											FROM [Evaluacion360].[tblEvaluadoresRequeridos] with (nolock)
											WHERE IDProyecto = @IDProyecto AND IDTipoRelacion = 4 ))
	BEGIN
		--INSERT #tempEvaluadoresReq(IDEvaluadorRequerido,IDProyecto,IDTipoRelacion,Relacion,Minimo,Maximo)

		select @ConfigAutoevaluacionRequerida = [Valor]
				from [Evaluacion360].[tblConfiguracionAvanzadaProyecto] with (nolock)
				where IDConfiguracionAvanzada = 9 and IDProyecto  = @IDProyecto

		set @Min = case when LOWER(@ConfigAutoevaluacionRequerida) = 'true' then 0 else 1 end;

		EXEC [Evaluacion360].[spIUEvaluadorRequerido] 
			 @IDEvaluadorRequerido = 0
			,@IDProyecto		   = @IDProyecto
			,@IDTipoRelacion	   = 4
			,@Minimo			   = @Min
			,@Maximo			   = 1
			,@IDUsuario			  = @IDUsuario
			,@WithResult = 0
	END ELSE 
	IF ((@AutoEvaluacion = 0) and EXISTS (SELECT TOP 1 1 
										FROM [Evaluacion360].[tblEvaluadoresRequeridos] with (nolock)
										WHERE IDProyecto = @IDProyecto AND IDTipoRelacion = 4 ))
	BEGIN
		DELETE [Evaluacion360].[tblEvaluadoresRequeridos] 
		WHERE IDProyecto = @IDProyecto AND IDTipoRelacion = 4 
	END;

	exec [Evaluacion360].[spBuscarProyectos] @IDProyecto = @IDProyecto,@IDUsuario= @IDUsuario
GO

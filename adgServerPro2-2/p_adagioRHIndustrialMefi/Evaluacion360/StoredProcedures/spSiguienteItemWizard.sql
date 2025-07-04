USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE proc [Evaluacion360].[spSiguienteItemWizard](
	@IDWizardUsuario int
	,@IDWizardItemActual int
	,@IDDetalleWizardUsuario int
	,@IDProyecto int  
	,@IDUsuario int  
) as 
	declare 
		--@IDWizardUsuario int = 0
		--@IDWizardItemActual int
		@OrderWizardItemActual int
		,@ItemActualCompleto bit
		,@UrlSiguiente varchar(max)
		--,@IDDetalleWizardUsuario int = 0
		,@dtEvaluadoresRequeridos [Evaluacion360].[dtEvaluadoresRequeridos]
		,@IDItemCompetencias int = 4
		,@TareaCompleta varchar(255) = 'Tarea a completada'
		,@ShowCantidadEvaluadoresRequeridos BIT = 0
		,@MinimoGruposRequeridos INT = 0
		,@MinimoPreguntasRequeridas INT = 0
		,@True BIT = 1
		,@False BIT = 0
		,@Proyecto INT = 1
		,@NoGrupos INT = 0
		,@NoPreguntas INT = 0
		,@NombreGrupo VARCHAR(255) = ''
	;
	
	declare @tempRespuesta as table (
		Avanzar bit not null
		,Mensaje varchar(255)
	--	,Redirect bit
		,[Url] varchar(max) 
		,IDWizardUsuario int
		,IDWizardItem int		
	);

	select @ItemActualCompleto = dwu.Completo
	from [Evaluacion360].[tblDetalleWizardUsuario] dwu with (nolock)
		join  [Evaluacion360].[tblCatWizardItem] cw  with (nolock) on dwu.IDWizardItem = cw.IDWizardItem
	where IDDetalleWizardUsuario = @IDDetalleWizardUsuario

	-- OBTENEMOS CONFIGURACION DEL PROYECTO
	SELECT @ShowCantidadEvaluadoresRequeridos = Conf.ShowCantidadEvaluadoresRequeridos,
		   @MinimoGruposRequeridos = Conf.MinimoGruposRequeridos,
		   @MinimoPreguntasRequeridas = Conf.MinimoPreguntasRequeridas
	FROM [Evaluacion360].[tblCatTiposProyectos] AS Tab
		CROSS APPLY OPENJSON (Tab.Configuracion, N'$')
	WITH (   
		ShowCantidadEvaluadoresRequeridos   BIT '$.General.ShowCantidadEvaluadoresRequeridos',  
		MinimoGruposRequeridos				INT '$.Grupos.MinimoGruposRequeridos',  
		MinimoPreguntasRequeridas			INT '$.Grupos.MinimoPreguntasRequeridas'
	) AS Conf
		JOIN [Evaluacion360].[tblCatProyectos] P ON Tab.IDTipoProyecto = p.IDTipoProyecto
	WHERE P.IDProyecto = @IDProyecto
	

	-- ItemSiguiente
	--select top 1 @UrlSiguiente = case when cw.IDWizardItem = @IDItemCompetencias then [Url]+N'?tiporeferencia=1&idreferencia='+cast(@IDProyecto as varchar(10))
	--		else [Url] end
	--from [Evaluacion360].[tblDetalleWizardUsuario] dwu with (nolock)
	--	join  [Evaluacion360].[tblCatWizardItem] cw  with (nolock) on dwu.IDWizardItem = cw.IDWizardItem
	--where IDWizardUsuario = @IDWizardUsuario and cw.Orden > @OrderWizardItemActual
	--ORDER BY cw.Orden asc

	if (@ItemActualCompleto = 1)
	begin
		insert @tempRespuesta(Avanzar,Mensaje,[Url],IDWizardUsuario,IDWizardItem)
		select 1,@TareaCompleta,@UrlSiguiente,@IDWizardUsuario,@IDWizardItemActual

		select * from @tempRespuesta; return;
	end;

	if (@IDWizardItemActual = 1) -- Crear proyecto
	begin
		insert @tempRespuesta(Avanzar,Mensaje,[Url],IDWizardUsuario,IDWizardItem)
		select 1,'Prueba actualizada satisfactoriamente',@UrlSiguiente,@IDWizardUsuario,@IDWizardItemActual
		
		update [Evaluacion360].[tblDetalleWizardUsuario]
		set Completo = 1
		where IDDetalleWizardUsuario = @IDDetalleWizardUsuario

		select * from @tempRespuesta; return;
	end;

	if (@IDWizardItemActual = 2) -- Configuraciones generales
	begin
		--print 'Configuraciones generales';
		
		if not exists (select top 1 1 
						from [Evaluacion360].[tblEvaluadoresRequeridos] with (nolock)
						where IDProyecto = @IDProyecto) AND @ShowCantidadEvaluadoresRequeridos = @True
		begin
			insert @tempRespuesta(Avanzar,Mensaje,IDWizardUsuario,IDWizardItem)
			select 0,'Es necesario indicar los evaluadores requeridos de la prueba antes de continuar.',@IDWizardUsuario,@IDWizardItemActual
			
			select * from @tempRespuesta; return;
		end;			

		if not exists (select top 1 1 
						from [Evaluacion360].[tblEncargadosProyectos] tep with (nolock)
						where IDProyecto = @IDProyecto AND tep.IDCatalogoGeneral = 1)
		begin
			insert @tempRespuesta(Avanzar,Mensaje,IDWizardUsuario,IDWizardItem)
			select 0,'Es necesario indicar un Adminsitrador de la prueba antes de continuar.',@IDWizardUsuario,@IDWizardItemActual
			
			select * from @tempRespuesta; return;
		end;

		if not exists (select top 1 1 
						from [Evaluacion360].[tblEncargadosProyectos] tep with (nolock)
						where IDProyecto = @IDProyecto AND tep.IDCatalogoGeneral = 3)
		begin
			insert @tempRespuesta(Avanzar,Mensaje,IDWizardUsuario,IDWizardItem)
			select 0,'Es necesario indicar un contacto de la prueba antes de continuar.',@IDWizardUsuario,@IDWizardItemActual
			
			select * from @tempRespuesta; return;
		end;

		insert @tempRespuesta(Avanzar,Mensaje,[Url],IDWizardUsuario,IDWizardItem)
		select 1,'Configuraciones generales completo satisfactoriamente',@UrlSiguiente,@IDWizardUsuario,@IDWizardItemActual
		
		update [Evaluacion360].[tblDetalleWizardUsuario]
		set Completo = 1
		where IDDetalleWizardUsuario = @IDDetalleWizardUsuario

		select * from @tempRespuesta; return;
	end;

	if (@IDWizardItemActual = 3) -- Escala de valoracion
	begin
		--print 'Escala de valoracion';
		if not exists (select top 1 1 
						from [Evaluacion360].[tblEscalasValoracionesProyectos] with (nolock)
						where IDProyecto = @IDProyecto)
		begin
			insert @tempRespuesta(Avanzar,Mensaje,IDWizardUsuario,IDWizardItem)
			select 0,'Es necesario definir la escala de valoración de la prueba antes de continuar.',@IDWizardUsuario,@IDWizardItemActual
			
			select * from @tempRespuesta; return;
		end;

		insert @tempRespuesta(Avanzar,Mensaje,[Url],IDWizardUsuario,IDWizardItem)
		select 1,'Escala de valoración completa satisfactoriamente',@UrlSiguiente,@IDWizardUsuario,@IDWizardItemActual
		
		update [Evaluacion360].[tblDetalleWizardUsuario]
		set Completo = 1
		where IDDetalleWizardUsuario = @IDDetalleWizardUsuario

		select * from @tempRespuesta; return;
	end;
	   	 

	IF (@IDWizardItemActual = 4) -- Competencias del proyecto
	BEGIN
		PRINT 'Competencias';

		SELECT CG.IDGrupo,
			   CG.Nombre,
			   COUNT(CP.IDPregunta) AS NoPreguntas
		INTO #tblGrupos FROM [Evaluacion360].[tblCatGrupos] CG
			LEFT JOIN [Evaluacion360].[tblCatPreguntas] CP ON CG.IDGrupo = CP.IDGrupo
		WHERE CG.TipoReferencia = @Proyecto AND
			  CG.IDReferencia = @IDProyecto
		GROUP BY CG.IDGrupo, CG.Nombre

		SELECT @NoGrupos = COUNT(IDGrupo) FROM #tblGrupos

		IF(@MinimoGruposRequeridos = @True)
			BEGIN								
				IF (@NoGrupos = 0)
					BEGIN
						INSERT @tempRespuesta(Avanzar, Mensaje, IDWizardUsuario, IDWizardItem)
						SELECT 0, 'Es necesario definir por lo menos un grupo de preguntas antes de continuar.', @IDWizardUsuario, @IDWizardItemActual			
						SELECT * FROM @tempRespuesta; RETURN;
					END
			END

		IF(@MinimoPreguntasRequeridas = @True)
			BEGIN
				IF (@NoGrupos > 0)
					BEGIN
						IF EXISTS(SELECT TOP 1 1 FROM #tblGrupos WHERE NoPreguntas = 0)
							BEGIN
								SELECT TOP 1 @NombreGrupo = Nombre 
								FROM #tblGrupos
								WHERE NoPreguntas = 0

								INSERT @tempRespuesta(Avanzar, Mensaje, IDWizardUsuario, IDWizardItem)
								SELECT 0, 'Es necesario definir por lo menos una pregunta en el grupo ' + @NombreGrupo + ' antes de continuar.', @IDWizardUsuario, @IDWizardItemActual
								SELECT * FROM @tempRespuesta; RETURN;
							END						
					END
				ELSE
					BEGIN
						INSERT @tempRespuesta(Avanzar, Mensaje, IDWizardUsuario, IDWizardItem)
						SELECT 0, 'Es necesario definir por lo menos un(a) funcion clave, objetivo KPI, competencia o valor para ingresar una pregunta.', @IDWizardUsuario, @IDWizardItemActual			
						SELECT * FROM @tempRespuesta; RETURN;
					END
			END

		INSERT @tempRespuesta(Avanzar, Mensaje, [Url], IDWizardUsuario, IDWizardItem)
		SELECT 1, 'Competencias de al prueba completa satisfactoriamente', @UrlSiguiente, @IDWizardUsuario, @IDWizardItemActual
		
		UPDATE [Evaluacion360].[tblDetalleWizardUsuario]
		SET Completo = 1
		WHERE IDDetalleWizardUsuario = @IDDetalleWizardUsuario

		SELECT * FROM @tempRespuesta; RETURN;
	END;
	   

	if (@IDWizardItemActual = 9) -- Configuraciones de evaluaciones
	begin
		print 'Configuraciones de evaluaciones';

		insert @tempRespuesta(Avanzar,Mensaje,[Url],IDWizardUsuario,IDWizardItem)
		select 1,'Configuraciones a completas satisfactoriamente',@UrlSiguiente,@IDWizardUsuario,@IDWizardItemActual
		
		update [Evaluacion360].[tblDetalleWizardUsuario]
		set Completo = 1
		where IDDetalleWizardUsuario = @IDDetalleWizardUsuario

		select * from @tempRespuesta; return;
	end;

	if (@IDWizardItemActual = 5) -- Seleccionar colaboradores
	begin
		print 'Seleccionar colaboradores';

		if not exists (select top 1 1 
						from [Evaluacion360].[tblEmpleadosProyectos] with (nolock)
						where IDProyecto = @IDProyecto)
		begin
			insert @tempRespuesta(Avanzar,Mensaje,IDWizardUsuario,IDWizardItem)
			select 0,'Es necesario asignar colaboradores a la prueba antes de continuar.',@IDWizardUsuario,@IDWizardItemActual
			
			select * from @tempRespuesta; return;
		end;

		insert @tempRespuesta(Avanzar,Mensaje,[Url],IDWizardUsuario,IDWizardItem)
		select 1,'La Seleccionar colaboradores a sido completada satisfactoriamente',@UrlSiguiente,@IDWizardUsuario,@IDWizardItemActual
		
		update [Evaluacion360].[tblDetalleWizardUsuario]
		set Completo = 1
		where IDDetalleWizardUsuario = @IDDetalleWizardUsuario

		select * from @tempRespuesta; return;
	end;

	if (@IDWizardItemActual = 10) --Enviar resultados a Colaboradores
	begin
		print 'Enviar resultados a Colaboradores';

		insert @tempRespuesta(Avanzar,Mensaje,[Url],IDWizardUsuario,IDWizardItem)
		select 1,'Enviar resultados a Colaboradores a completa satisfactoriamente',@UrlSiguiente,@IDWizardUsuario,@IDWizardItemActual
		
		update [Evaluacion360].[tblDetalleWizardUsuario]
		set Completo = 1
		where IDDetalleWizardUsuario = @IDDetalleWizardUsuario

		select * from @tempRespuesta; return;
	end;

	if (@IDWizardItemActual = 6 OR @IDWizardItemActual = 11) -- Asignar evaluadores de forma masiva
	begin
		
		print 'Asignar evaluadores de forma masiva';

		INSERT @dtEvaluadoresRequeridos
		EXEC [Evaluacion360].[spBuscarRelacionesProyecto] 
			@IDProyecto = @IDProyecto
			,@IDUsuario = @IDUsuario
	
		--SELECT * FROM @dtEvaluadoresRequeridos		

		if exists (select top 1 1 
						from @dtEvaluadoresRequeridos  
						where IDEvaluador = 0 and Requerido = 1)
		begin
			insert @tempRespuesta(Avanzar,Mensaje,IDWizardUsuario,IDWizardItem)
			select 0,'Es necesario asignar Evaluadores mínimos requeridos antes de continuar.  </br> Revisa las restricciones incompletas en la pestaña: Relaciones del proyecto la prueba',@IDWizardUsuario,@IDWizardItemActual
			
			select * from @tempRespuesta; return;
		end;

		insert @tempRespuesta(Avanzar,Mensaje,[Url],IDWizardUsuario,IDWizardItem)
		select 1,'La Seleccionar colaboradores a sido completada satisfactoriamente',@UrlSiguiente,@IDWizardUsuario,@IDWizardItemActual
		
			   

		update [Evaluacion360].[tblDetalleWizardUsuario]
		set Completo = 1
		where IDWizardUsuario = @IDProyecto and
			  IDWizardItem in (6, 11)		
		--IDDetalleWizardUsuario = @IDDetalleWizardUsuario

		select * from @tempRespuesta; return;	
	end;

	if (@IDWizardItemActual = 8) -- Fechas y Calendarización del proyecto
	begin
		print 'Fechas y Calendarización de la prueba';

		if exists (SELECT * 
					FROM Evaluacion360.tblCatProyectos tcp
					WHERE tcp.IDProyecto = @IDProyecto AND (FechaInicio IS NULL OR FechaFin IS null))
		begin
			insert @tempRespuesta(Avanzar,Mensaje,IDWizardUsuario,IDWizardItem)
			select 0,'Indique la fecha de inicio y fin de la prueba antes de continuar.',@IDWizardUsuario,@IDWizardItemActual
			
			select * from @tempRespuesta; return;
		end;

		insert @tempRespuesta(Avanzar,Mensaje,[Url],IDWizardUsuario,IDWizardItem)
		select 1,'Fechas de la prueba seleccionadas satisfactoriamente',@UrlSiguiente,@IDWizardUsuario,@IDWizardItemActual
		
		update [Evaluacion360].[tblDetalleWizardUsuario]
		set Completo = 1
		where IDDetalleWizardUsuario = @IDDetalleWizardUsuario

		select * from @tempRespuesta; return;
	end;

	IF (@IDWizardItemActual = 7) -- Autorizar la prueba
	BEGIN
		insert @tempRespuesta(Avanzar,Mensaje,[Url],IDWizardUsuario,IDWizardItem)
		select 1,'El wizard se ha completado satisfactoriamente.','#/',@IDWizardUsuario,@IDWizardItemActual
		
		BEGIN TRY
			EXEC [Evaluacion360].[spAutorizarProyecto] 
				 @IDProyecto = @IDProyecto
				 ,@IDUsuario = @IDUsuario

		END TRY
		BEGIN CATCH
			SELECT cast(0 as bit) as Avanzar,  ERROR_MESSAGE() AS Mensaje,'#/' as [Url],@IDWizardUsuario IDWizardUsuario,@IDWizardItemActual IDWizardItem; 
			return;
		END CATCH

		INSERT INTO [Evaluacion360].[tblEstatusProyectos](IDProyecto,IDEstatus,IDUsuario)
		VALUES(@IDProyecto,3,@IDUsuario)

		--SELECT * FROM Evaluacion360.tblCatEstatus tce	
		--	JOIN Evaluacion360.tblCatTiposEstatus tcte ON tce.IDTipoEstatus = tcte.IDTipoEstatus

		update [Evaluacion360].[tblDetalleWizardUsuario]
		set Completo = 1
		where IDDetalleWizardUsuario = @IDDetalleWizardUsuario

		update [Evaluacion360].[tblWizardsUsuarios]
		set Completo = 1
		where IDWizardUsuario = @IDWizardUsuario

		select * from @tempRespuesta; return;
	end;


	select * from @tempRespuesta return;
GO

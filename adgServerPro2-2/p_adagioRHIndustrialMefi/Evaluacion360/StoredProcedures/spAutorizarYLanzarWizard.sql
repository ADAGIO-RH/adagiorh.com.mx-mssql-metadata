USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
CREATE   proc [Evaluacion360].[spAutorizarYLanzarWizard](
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

	begin -- Configuraciones generales
		begin -- evaluadores requeridos
			set @IDWizardItemActual = 2
		
			if not exists (select top 1 1 
							from [Evaluacion360].[tblEvaluadoresRequeridos] with (nolock)
							where IDProyecto = @IDProyecto) AND @ShowCantidadEvaluadoresRequeridos = @True
			begin
				insert @tempRespuesta(Avanzar,Mensaje,IDWizardUsuario,IDWizardItem)
				select 0,'Es necesario indicar los evaluadores requeridos de la prueba antes de continuar.',@IDWizardUsuario,@IDWizardItemActual
			
				select * from @tempRespuesta; return;
			end;	
		end

		begin -- fecha de inicio y fin
			if exists (SELECT * 
					FROM Evaluacion360.tblCatProyectos tcp
					WHERE tcp.IDProyecto = @IDProyecto AND (FechaInicio IS NULL OR FechaFin IS null))
			begin
				set @IDWizardItemActual = 2

				insert @tempRespuesta(Avanzar,Mensaje,IDWizardUsuario,IDWizardItem)
				select 0,'Indique la fecha de inicio y fin de la prueba antes de continuar.',@IDWizardUsuario,@IDWizardItemActual
			
				select * from @tempRespuesta; return;
			end;
		end

		begin -- escala de valoración
			if not exists (select top 1 1 
						from [Evaluacion360].[tblEscalasValoracionesProyectos] with (nolock)
						where IDProyecto = @IDProyecto)
			begin
				set @IDWizardItemActual = 3

				insert @tempRespuesta(Avanzar,Mensaje,IDWizardUsuario,IDWizardItem)
				select 0,'Es necesario definir la escala de valoración de la prueba antes de continuar.',@IDWizardUsuario,@IDWizardItemActual
			
				select * from @tempRespuesta; return;
			end;
		end

		begin -- Evaluadores mínimos requeridos
			INSERT @dtEvaluadoresRequeridos
			EXEC [Evaluacion360].[spBuscarRelacionesProyecto] 
				@IDProyecto = @IDProyecto
				,@IDUsuario = @IDUsuario
	
			if exists (select top 1 1 
							from @dtEvaluadoresRequeridos  
							where IDEvaluador = 0 and Requerido = 1)
			begin
				set @IDWizardItemActual = 6

				insert @tempRespuesta(Avanzar,Mensaje,IDWizardUsuario,IDWizardItem)
				select 0,'Es necesario asignar Evaluadores mínimos requeridos antes de continuar.  </br> Revisa las restricciones incompletas en la pestaña: Relaciones del proyecto la prueba',@IDWizardUsuario,@IDWizardItemActual
			
				select * from @tempRespuesta; return;
			end;
		end

		begin -- contacto
			if not exists (select top 1 1 
						from [Evaluacion360].[tblEncargadosProyectos] tep with (nolock)
						where IDProyecto = @IDProyecto AND tep.IDCatalogoGeneral = 3)
			begin
				insert @tempRespuesta(Avanzar,Mensaje,IDWizardUsuario,IDWizardItem)
				select 0,'Es necesario indicar un contacto de la prueba antes de continuar.',@IDWizardUsuario,@IDWizardItemActual
			
				select * from @tempRespuesta; return;
			end;
		end
		
		begin --editores
			if not exists (select top 1 1 
						from [Evaluacion360].[tblAdministradoresProyecto] with (nolock)
						where IDProyecto = @IDProyecto)
			begin
				insert @tempRespuesta(Avanzar,Mensaje,IDWizardUsuario,IDWizardItem)
				select 0,'Agrega por lo menos un editor.',@IDWizardUsuario,@IDWizardItemActual
			
				select * from @tempRespuesta; return;
			end;	
		end
	end;
 
	begin -- Competencias del proyecto
		set @IDWizardItemActual = 4

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
	end;
	   
	begin -- Seleccionar colaboradores
		if not exists (select top 1 1 
						from [Evaluacion360].[tblEmpleadosProyectos] with (nolock)
						where IDProyecto = @IDProyecto)
		begin
			set @IDWizardItemActual = 5

			insert @tempRespuesta(Avanzar,Mensaje,IDWizardUsuario,IDWizardItem)
			select 0,'Es necesario asignar colaboradores a la prueba antes de continuar.',@IDWizardUsuario,@IDWizardItemActual
			
			select * from @tempRespuesta; return;
		end;
	end;

	begin -- Autorizar la prueba
		set @IDWizardItemActual = 7

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

		exec [Evaluacion360].[spActualizarTotalEvaluacionesPorEstatus]

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

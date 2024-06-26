USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Evaluacion360].[spCrearNotificacionesRecordatorioEvaluaciones] as
DECLARE @IDProyecto int = 0 
	,@IDUsuario int  
	,@FechaInicio date
	,@FechaFin date
	,@Today date = getdate()
	,@TotalDias int
	,@DiasRestantes int
	,@PorcetajeDiasRestantes int
	,@IDEvaluacionEmpleado int 
	,@dtProyectos  Evaluacion360.dtProyectos
	;

	select @IDUsuario = cast(isnull(valor, 0) as int) from App.tblConfiguracionesGenerales where IDConfiguracion = 'IDUsuarioAdmin'
	 
	if object_id('tempdb..##evaluacionPendientesRec') is not null drop table ##evaluacionPendientesRec;

	CREATE TABLE ##evaluacionPendientesRec(
		 IDEvaluacionEmpleado		   int
		,IDEmpleadoProyecto			   int
		,IDTipoRelacion				   int
		,Relacion					   varchar(max)
		,IDEvaluador				   int
		,ClaveEvaluador				   varchar(max)
		,Evaluador					   varchar(max)
		,IDProyecto					   int
		,Proyecto					   varchar(max)
		,IDEmpleado					   int
		,ClaveEmpleado 				   varchar(max)
		,Colaborador				   varchar(max)
		,IDEstatusEvaluacionEmpleado   int
		,IDEstatus					   int
		,Estatus					   varchar(max)
		,IDUsuario					   int
		,FechaCreacion				   datetime
		,Progreso 					   int
	);

	--IF object_id('tempdb..#tempProyectos') IS NOT NULL DROP TABLE #tempProyectos;  
  
	--CREATE TABLE #tempProyectos (  
	--	IDProyecto int  
	--	,Nombre varchar(max)  
	--	,Descripcion varchar(max)  
	--	,IDEstatus int  
	--	,Estatus varchar(max)  
	--	,FechaCreacion datetime  
	--	,IDUsuario int  
	--	,Usuario  varchar(max)  
	--	,AutoEvaluacion bit  
	--	,TotalPruebasARealizar int  
	--	,TotalPruebasRealizadas int  
	--	,Progreso int  
	--	,FechaInicio date  
	--	,FechaFin date  
	--	,Calendarizado bit  
	--	,IDTask int  
	--	,IDSchedule int  
	--);


	INSERT @dtProyectos
	EXEC Evaluacion360.spBuscarProyectos @IDUsuario=@IDUsuario

	delete @dtProyectos WHERE IDEstatus <> 3

	SELECT * FROM @dtProyectos
	SELECT @IDProyecto = min(IDProyecto) FROM @dtProyectos p

	WHILE EXISTS (SELECT TOP 1 1 FROM @dtProyectos tp WHERE tp.IDProyecto >= @IDProyecto)
	BEGIN
		DELETE ##evaluacionPendientesRec;
		--PRINT @IDProyecto;

		SELECT 
				@FechaInicio = tp.FechaInicio
				,@FechaFin = tp.FechaFin
		FROM @dtProyectos tp
		WHERE tp.IDProyecto = @IDProyecto

		IF (@Today BETWEEN @FechaInicio AND @FechaFin)
		BEGIN
			SELECT 
				@TotalDias=datediff(day,@FechaInicio,@FechaFin)

			SELECT 
				@DiasRestantes=datediff(day,@Today,@FechaFin)		
		
			SELECT @PorcetajeDiasRestantes = (@DiasRestantes * 100) / @TotalDias

			INSERT ##evaluacionPendientesRec
			EXEC [Evaluacion360].[spBuscarPruebasPorProyecto]
					@IDProyecto = @IDProyecto
					,@Tipo = 1
					,@IDUsuario = @IDUsuario

			IF ((@PorcetajeDiasRestantes BETWEEN 45 AND 55)
				AND exists(SELECT TOP 1 1 FROM ##evaluacionPendientesRec ep)
				AND NOT EXISTS (SELECT TOP 1 1 
								FROM  Evaluacion360.tblRecordarioEnviadosPorProyecto 
								WHERE IDProyecto = @IDProyecto AND IDTipoRecordatorio = 1)
			)
			BEGIN
				SELECT @IDEvaluacionEmpleado = min(IDEvaluacionEmpleado) FROM ##evaluacionPendientesRec ep

				WHILE EXISTS(SELECT TOP 1 1 FROM ##evaluacionPendientesRec ep WHERE ep.IDEvaluacionEmpleado >= @IDEvaluacionEmpleado)
				BEGIN
					EXEC [Evaluacion360].[spCrearNotificacionEvaluacionEmpleado] 
						@IDEvaluacionEmpleado = @IDEvaluacionEmpleado
						,@TipoAccion = 2 
						,@IDUsuario = @IDUsuario;
					
					SELECT @IDEvaluacionEmpleado = min(IDEvaluacionEmpleado) FROM ##evaluacionPendientesRec ep WHERE ep.IDEvaluacionEmpleado > @IDEvaluacionEmpleado

				end;

				INSERT INTO Evaluacion360.tblRecordarioEnviadosPorProyecto(IDProyecto,IDTipoRecordatorio)
				SELECT @IDProyecto,1
			end;

			IF ((@PorcetajeDiasRestantes BETWEEN 30 AND 35)
				AND exists(SELECT TOP 1 1 FROM ##evaluacionPendientesRec ep)
				AND NOT EXISTS (SELECT TOP 1 1 
								FROM  Evaluacion360.tblRecordarioEnviadosPorProyecto 
								WHERE IDProyecto = @IDProyecto AND IDTipoRecordatorio = 2)
			)
			BEGIN
				SELECT @IDEvaluacionEmpleado = min(IDEvaluacionEmpleado) FROM ##evaluacionPendientesRec ep

				WHILE EXISTS(SELECT TOP 1 1 FROM ##evaluacionPendientesRec ep WHERE ep.IDEvaluacionEmpleado >= @IDEvaluacionEmpleado)
				BEGIN
					EXEC [Evaluacion360].[spCrearNotificacionEvaluacionEmpleado] 
						@IDEvaluacionEmpleado = @IDEvaluacionEmpleado
						,@TipoAccion = 2 
						,@IDUsuario = @IDUsuario	;				

					SELECT @IDEvaluacionEmpleado = min(IDEvaluacionEmpleado) FROM ##evaluacionPendientesRec ep WHERE ep.IDEvaluacionEmpleado > @IDEvaluacionEmpleado
				end;

				INSERT INTO Evaluacion360.tblRecordarioEnviadosPorProyecto(IDProyecto,IDTipoRecordatorio)
				SELECT @IDProyecto,2
			end;

			select @IDProyecto as IDProyecto, @PorcetajeDiasRestantes as PorcetajeDiasRestantes
			IF ((@PorcetajeDiasRestantes BETWEEN 8 AND 12)
				AND exists(SELECT TOP 1 1 FROM ##evaluacionPendientesRec ep)
				AND NOT EXISTS (SELECT TOP 1 1 
								FROM  Evaluacion360.tblRecordarioEnviadosPorProyecto 
								WHERE IDProyecto = @IDProyecto AND IDTipoRecordatorio = 3)
			)
			BEGIN
				SELECT @IDEvaluacionEmpleado = min(IDEvaluacionEmpleado) FROM ##evaluacionPendientesRec ep

				WHILE EXISTS(SELECT TOP 1 1 FROM ##evaluacionPendientesRec ep WHERE ep.IDEvaluacionEmpleado >= @IDEvaluacionEmpleado)
				BEGIN
					EXEC [Evaluacion360].[spCrearNotificacionEvaluacionEmpleado] 
						@IDEvaluacionEmpleado = @IDEvaluacionEmpleado
						,@TipoAccion = 3 
						,@IDUsuario = @IDUsuario	;				

					SELECT @IDEvaluacionEmpleado = min(IDEvaluacionEmpleado) FROM ##evaluacionPendientesRec ep WHERE ep.IDEvaluacionEmpleado > @IDEvaluacionEmpleado
				end;

				INSERT INTO Evaluacion360.tblRecordarioEnviadosPorProyecto(IDProyecto,IDTipoRecordatorio)
				SELECT @IDProyecto,2
			end;
		end;

		SELECT @IDProyecto = min(IDProyecto) FROM @dtProyectos p WHERE p.IDProyecto > @IDProyecto
	end;
 

--SELECT * FROM Evaluacion360.tblCatEstatus tce
GO

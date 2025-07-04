USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Evaluacion360].[spBorrarFiltroProyecto](
	@IDFiltroProyecto INT,
	@IDUsuario INT,
	@IDProyecto INT,
	@TipoFiltro VARCHAR(250)
)
AS
	
	IF OBJECT_ID('tempdb..#tempFiltrosProyectos') IS NOT NULL
		DROP TABLE #tempFiltrosProyectos;


	DECLARE @OldJSON VARCHAR(MAX) = '',
			@NewJSON VARCHAR(MAX),
			@NombreSP VARCHAR(MAX) = '[Evaluacion360].[spBorrarFiltroProyecto]',
			@Tabla VARCHAR(MAX) = '[Evaluacion360].[tblFiltrosProyectos]',
			@Accion VARCHAR(20) = 'DELETE',
			@Mensaje VARCHAR(MAX),
			@InformacionExtra VARCHAR(MAX),			
			@NO INT = 0,
			@SI INT = 1;
		
	
	DECLARE @tempValidacion TABLE(
		IDAuto			 INT IDENTITY(1,1),
		IDFiltroProyecto INT,		
		IDEmpleado		 INT,
		TipoFiltro		 VARCHAR(MAX),
		Descripcion		 VARCHAR(MAX),
		IsEvaluado		 BIT
	)
	

	DECLARE @tempFiltrosProyectos TABLE(	
		IDAuto			 INT IDENTITY(1,1),
		IDFiltroProyecto INT,		
		IDEmpleado		 INT,
		TipoFiltro		 VARCHAR(MAX),
		Descripcion		 VARCHAR(MAX),
		IsEvaluado		 BIT
	)
	

	DECLARE @TblRespuestas TABLE(
		IDEvaluado INT,
		IDEvaluador	INT,
		IDEvaluacionEmpleado INT,
		IDEmpleadoProyecto INT,
		IDGrupo INT,
		TipoReferencia INT,
		NoPreguntas INT,
		NoRespuestas INT
	) 
	

	BEGIN TRY
		EXEC [Evaluacion360].[spSePuedoModificarElProyecto] @IDProyecto = @IDProyecto, @IDUsuario = @IDUsuario
	END TRY
	BEGIN CATCH
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003';
		RETURN 0;
	END CATCH


	IF(@IDFiltroProyecto = 0)
		BEGIN
			
			-- OBTENEMOS LOS PARTICIPANTES DEL FILTRO
			INSERT INTO @tempValidacion
			SELECT IDFiltroProyecto, ID, TipoFiltro, Descripcion, 0 IsEvaluado 
			FROM [Evaluacion360].[tblFiltrosProyectos] 
			WHERE IDProyecto = @IDProyecto AND
				  TipoFiltro = @TipoFiltro

		END
	ELSE
		BEGIN	
			
			-- OBTENEMOS PARTICIPANTES DEL FILTRO GENERAL			
			INSERT INTO @tempValidacion
			SELECT 0 AS IDFiltroProyecto
					, EP.IDEmpleado
					, SUBSTRING(EP.TipoFiltro, 1, CHARINDEX('|', EP.TipoFiltro) - 2) AS TipoFiltro					
					, EM.NOMBRECOMPLETO
					, 0 IsEvaluado 
			FROM [Evaluacion360].[tblEmpleadosProyectos] EP
				JOIN [RH].[tblEmpleadosMaster] EM ON EP.IDEmpleado = EM.IDEmpleado
			WHERE EP.IDProyecto = @IDProyecto AND
					EP.TipoFiltro = @TipoFiltro

		END
	--SELECT * FROM @tempValidacion



	-- REVISA SI LOS EVALUADOS YA CUENTAN CON EVALUACIONES REALIADAS
	DECLARE @Cont INT = 1
			, @Limite INT = 0
			, @ExistenEvaluaciones BIT = 0

	SELECT @Limite = COUNT(IDFiltroProyecto) FROM @tempValidacion		
	WHILE @Cont <= @Limite
		BEGIN		

			DECLARE @IDEmpleado INT = 0
					, @TieneEvaluaciones INT = 0

			DELETE @TblRespuestas;

			SELECT @IDEmpleado = IDEmpleado FROM @tempValidacion WHERE IDAuto = @Cont;										
			
			INSERT INTO @TblRespuestas
			EXEC [Evaluacion360].[spValidarExcluirColaborador] @IDProyecto = @IDProyecto, @IDEmpleado = @IDEmpleado, @IDUsuario	= @IDUsuario;
			SELECT @TieneEvaluaciones = COUNT(*) FROM @TblRespuestas WHERE NoRespuestas > 0;
						
			IF(@TieneEvaluaciones > 0)
				BEGIN
					UPDATE @tempValidacion SET IsEvaluado = @SI WHERE IDAuto = @Cont;	
					SET @ExistenEvaluaciones = @SI;
				END			
			
			SET @Cont = @Cont + 1
		END	
	--SELECT 'TIENE EVALUACIONES' AS ' ', * FROM @tempValidacion



	IF(@IDFiltroProyecto = 0)
		BEGIN
			-- CONSERVA CADA UNO DE LOS FILTROS ENCONTRADOS PARA POSTERIORMENTE TRABAJARLO DEPENDIENDO DE IsEvaluado (SI ESTA EVALUADO)
			INSERT INTO @tempFiltrosProyectos
			SELECT IDFiltroProyecto,
					IDEmpleado,
					TipoFiltro,
					Descripcion,
					IsEvaluado
			FROM @tempValidacion
		END
	ELSE
		BEGIN
			IF(@ExistenEvaluaciones = @SI)
				BEGIN	
					-- CONSERVAR FILTRO GENERAL
					INSERT INTO @tempFiltrosProyectos
					SELECT IDFiltroProyecto						
							, ID
							, TipoFiltro
							, Descripcion
							, @SI
					FROM [Evaluacion360].[tblFiltrosProyectos] 
					WHERE IDProyecto = @IDProyecto 
							AND IDFiltroProyecto = @IDFiltroProyecto

					-- PARTICIPANTES SIN EVALUACIONES SE PASAN AL FILTRO 'Excluir Empleado'
					INSERT INTO [Evaluacion360].[tblFiltrosProyectos] 
					SELECT @IDProyecto
							, 'Excluir Empleado' AS TipoFiltro
							, IDEmpleado
							, Descripcion
					FROM @tempValidacion
					WHERE IsEvaluado = @NO
				END
			ELSE
				BEGIN
					-- ELIMINAR FILTRO GENERAL
					INSERT INTO @tempFiltrosProyectos
					SELECT IDFiltroProyecto						
							, ID
							, TipoFiltro
							, Descripcion
							, @NO
					FROM [Evaluacion360].[tblFiltrosProyectos] 
					WHERE IDProyecto = @IDProyecto 
							AND IDFiltroProyecto = @IDFiltroProyecto
				END
		END
	--SELECT 'RESULTADO' AS ' ', * FROM @tempFiltrosProyectos
	


	

	-- ELIMINA FILTROS
	DECLARE @Cont2 INT = 1
			, @Limite2 INT = 0				

	SELECT @Limite2 = COUNT(IDFiltroProyecto) FROM @tempFiltrosProyectos;
	WHILE @Cont2 <= @Limite2
		BEGIN		
		
			DECLARE @IDFiltroProyectoAux INT = 0
					, @IsEvaluado BIT = 0;		

			SELECT @IDFiltroProyectoAux = IDFiltroProyecto,  @IsEvaluado = IsEvaluado FROM @tempFiltrosProyectos WHERE IDAuto = @Cont2;
			
			IF(@IsEvaluado = @NO)
				BEGIN
						
					SELECT @OldJSON = a.JSON 
					FROM [Evaluacion360].[tblFiltrosProyectos] b
						CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
					WHERE IDFiltroProyecto = @IDFiltroProyectoAux AND IDProyecto = @IDProyecto				
			
					DELETE FROM [Evaluacion360].[tblFiltrosProyectos]
					WHERE IDFiltroProyecto = @IDFiltroProyectoAux AND IDProyecto = @IDProyecto			

					EXEC [Auditoria].[spIAuditoria]
						@IDUsuario		   = @IDUsuario
						,@Tabla			   = @Tabla
						,@Procedimiento	   = @NombreSP
						,@Accion		   = @Accion
						,@NewData		   = @NewJSON
						,@OldData		   = @OldJSON
						,@Mensaje		   = @Mensaje
						,@InformacionExtra = @InformacionExtra


				END
			
			SET @Cont2 = @Cont2 + 1
		END
		

	-- REASIGNA EMPLEADOS AL PROYECTO
	EXEC [Evaluacion360].[spAsginarEmpleadosAProyecto] @IDProyecto = @IDProyecto, @IDUsuario = @IDUsuario
GO

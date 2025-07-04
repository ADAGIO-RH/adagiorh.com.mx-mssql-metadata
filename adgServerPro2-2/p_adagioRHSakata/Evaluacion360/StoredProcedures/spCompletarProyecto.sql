USE [p_adagioRHSakata]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Descripción		: Cambia de estatus el proyecto a "COMPLETO" siempre y cuando todas las evaluaciones estén listas. Se ejecuta cada vez que una evaluación este completa.
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-01-15
** Paremetros		: 

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2019-03-08			Aneudy Abreu		Se agregó la ejecución del SP [Evaluacion360].[spCalcularTotalesEvaluacionesEmpleadosPorProyecto]
2021-07-08			Aneudy Abreu		Se modificó el Subject de los correos
2025-01-08			Alejandro Paredes	Se actualizo el flujo del correo
***************************************************************************************************/
CREATE   PROC [Evaluacion360].[spCompletarProyecto](
	@IDProyecto		INT
	, @IDUsuario	INT
) AS

	DECLARE @IDUsuarioAdmin						INT
			, @NombreProyecto					VARCHAR(MAX)
			, @TotalPruebas						INT = 0
			, @TotalRealizadas					INT = 0
			, @NombreAdministradorProyecto		VARCHAR(MAX)
			, @EmailAdministradorProyecto		VARCHAR(MAX)
			, @HTMLListOut						VARCHAR(MAX)
			, @xmlParametros					VARCHAR(MAX)
			, @IDNotificacion					INT
			, @cols								NVARCHAR(MAX)
			, @query							NVARCHAR(MAX)
			, @LinkResultados					VARCHAR(MAX)		
			, @IDTipoProyecto					INT
			, @ID_TIPO_PROYECTO_CLIMA_LABORAL	INT = 3
			, @OldJSON							VARCHAR(MAX) = ''
			, @NewJSON							VARCHAR(MAX)
			, @NombreSP							VARCHAR(MAX) = '[Evaluacion360].[spCompletarProyecto]'
			, @Tabla							VARCHAR(MAX) = '[Evaluacion360].[tblCatProyectos]'
			, @Accion							VARCHAR(20)	 = 'UPDATE'
			, @Mensaje							VARCHAR(MAX)
			, @InformacionExtra					VARCHAR(MAX)
			, @IDIdioma							VARCHAR(MAX)
			;


	SELECT @IDUsuarioAdmin = CAST(Valor AS INT) 
	FROM [App].[tblConfiguracionesGenerales] WITH (NOLOCK)
	WHERE IDConfiguracion = 'IDUsuarioAdmin';

	   
    SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', @IDUsuario, 'esmx');
    

	SELECT TOP 1 @LinkResultados = valor 
	FROM [App].[tblConfiguracionesGenerales]
	WHERE IDConfiguracion = 'Url'


	SELECT @NombreProyecto = Nombre
			, @IDTipoProyecto = IDTipoProyecto
	FROM [Evaluacion360].[tblCatProyectos] TCP WITH (NOLOCK)
	WHERE TCP.IDProyecto = @IDProyecto


	IF OBJECT_ID('tempdb..#tempParams') IS NOT NULL DROP TABLE #tempParams;

	CREATE TABLE #tempParams(
		ID INT IDENTITY(1,1) NOT NULL
		, Variable VARCHAR(MAX)
		, Valor VARCHAR(MAX)
	);


	SELECT @NombreAdministradorProyecto = CASE WHEN TEP.IDCatalogoGeneral = 1 THEN COALESCE(TEP.Nombre,'') ELSE @NombreAdministradorProyecto END
			, @EmailAdministradorProyecto = CASE WHEN TEP.IDCatalogoGeneral = 1 THEN COALESCE(TEP.Email,'') ELSE @EmailAdministradorProyecto END
	FROM [Evaluacion360].[tblEncargadosProyectos] TEP WITH (NOLOCK)
	WHERE TEP.IDProyecto = @IDProyecto 


	IF OBJECT_ID('tempdb..#evaluacionPendientes') IS NOT NULL DROP TABLE #evaluacionPendientes;

	CREATE TABLE #evaluacionPendientes(
		IDEvaluacionEmpleado			INT
		, IDEmpleadoProyecto			INT
		, IDTipoRelacion				INT
		, Relacion						VARCHAR(MAX)
		, IDEvaluador					INT
		, ClaveEvaluador				VARCHAR(MAX)
		, Evaluador						VARCHAR(MAX)
		, IDProyecto					INT
		, Proyecto						VARCHAR(MAX)
		, IDEmpleado					INT
		, ClaveEmpleado 				VARCHAR(MAX)
		, Colaborador					VARCHAR(MAX)
		, IDEstatusEvaluacionEmpleado	INT
		, IDEstatus						INT
		, Estatus						VARCHAR(MAX)
		, IDUsuario						INT
		, FechaCreacion					DATETIME
		, Progreso 						INT
	);


	INSERT #evaluacionPendientes(
		IDEvaluacionEmpleado
		, IDEmpleadoProyecto
		, IDTipoRelacion
		, Relacion
		, IDEvaluador
		, ClaveEvaluador
		, Evaluador
		, IDProyecto
		, Proyecto
		, IDEmpleado
		, ClaveEmpleado
		, Colaborador
		, IDEstatusEvaluacionEmpleado
		, IDEstatus
		, Estatus
		, IDUsuario
		, FechaCreacion
		, Progreso
	)
	EXEC [Evaluacion360].[spBuscarPruebasPorProyecto] @IDProyecto = @IDProyecto, @Tipo = 3, @IDUsuario = @IDUsuarioAdmin


	-- TOTAL DE PRUEBAS
	SELECT @TotalPruebas = COUNT(*)
	FROM #evaluacionPendientes
	WHERE #evaluacionPendientes.IDEstatus <> 14 -- TODAS MENOS LAS EVALUACIONES CANCELADAS.
	
	-- PRUEBAS REALIZADAS
	SELECT @TotalRealizadas = COUNT(*)
	FROM #evaluacionPendientes
	WHERE #evaluacionPendientes.IDEstatus = 13

		
	-- FLUJO AUDITORIA E INSERSION DE TAREA (ENVIAR NOTIFICACION "EvaluacionFinalizada")
	IF (@TotalPruebas = @TotalRealizadas)
		BEGIN
		
			/* -------------------------------------------------------------------------------------------------------------------------------------------------------- */
		
			-- AUDITORIA
			SELECT @OldJSON = a.JSON 
			FROM (
					SELECT tep.IDProyecto
							, TCP.Nombre
							, TCP.Descripcion
							, TEP.IDEstatusProyecto
							, ISNULL(TEP.IDEstatus, 0) AS IDEstatus
							, ISNULL(JSON_VALUE(ESTATUS.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-', '')), 'Estatus')), 'Sin estatus') AS Estatus
							, TEP.IDUsuario
							, TEP.FechaCreacion 
					FROM [Evaluacion360].[tblCatProyectos] TCP WITH (NOLOCK)
						LEFT JOIN [Evaluacion360].[tblEstatusProyectos] TEP	WITH (NOLOCK) ON TEP.IDProyecto = TCP.IDProyecto
						LEFT JOIN (SELECT * FROM [Evaluacion360].[tblCatEstatus] WHERE IDTipoEstatus = 1) ESTATUS ON TEP.IDEstatus = ESTATUS.IDEstatus
					WHERE TCP.IDProyecto = @IDProyecto
			) b
				CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW))) a
			--SELECT @OldJSON
			

			INSERT INTO [Evaluacion360].[tblEstatusProyectos](IDProyecto, IDEstatus, IDUsuario)
			VALUES(@IDProyecto, 6 ,@IDUsuario)

			EXEC [Evaluacion360].[spActualizarTotalEvaluacionesPorEstatus]


			SELECT @NewJSON = a.JSON 
			FROM (
					SELECT TEP.IDProyecto
							, TCP.Nombre
							, TCP.Descripcion
							, TEP.IDEstatusProyecto
							, ISNULL(TEP.IDEstatus, 0) AS IDEstatus
							, ISNULL(JSON_VALUE(ESTATUS.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-', '')), 'Estatus')), 'Sin estatus') AS Estatus				
							, TEP.IDUsuario
							, TEP.FechaCreacion 
					FROM [Evaluacion360].[tblCatProyectos] TCP WITH (NOLOCK)
						LEFT JOIN [Evaluacion360].[tblEstatusProyectos] TEP	WITH (NOLOCK) ON TEP.IDProyecto = TCP.IDProyecto
						LEFT JOIN (SELECT * FROM [Evaluacion360].[tblCatEstatus] WHERE IDTipoEstatus = 1) ESTATUS ON TEP.IDEstatus = ESTATUS.IDEstatus
					WHERE TCP.IDProyecto = @IDProyecto
			) b
				CROSS APPLY(SELECT JSON = [Utilerias].[fnStrJSON](0, 0, (SELECT b.* FOR XML RAW)) ) a
			--SELECT @NewJSON


			EXEC [Auditoria].[spIAuditoria]
				@IDUsuario			= @IDUsuario
				, @Tabla			= @Tabla
				, @Procedimiento	= @NombreSP
				, @Accion			= @Accion
				, @NewData			= @NewJSON
				, @OldData			= @OldJSON
				, @Mensaje			= @Mensaje
				, @InformacionExtra	= @InformacionExtra

			/* -------------------------------------------------------------------------------------------------------------------------------------------------------- */

			-- INSERSION DE TAREA "EvaluacionFinalizada"
			EXEC [Evaluacion360].[spITareaDeProyectoFinalizado] @IDProyecto = @IDProyecto, @IDUsuario = @IDUsuario				

			-- FLUJO QUE YA ESTABA
			EXEC [Evaluacion360].[spCalcularTotalesEvaluacionesEmpleadosPorProyecto] @IDProyecto = @IDProyecto

		END;



	-- NORMALIZA INFORMACION DE EVALUACIONES "CLIMA LABORAL"
	IF(@IDTipoProyecto = @ID_TIPO_PROYECTO_CLIMA_LABORAL)
		BEGIN
			EXEC [InfoDir].[spSincronizarEvaluacionesClimaLaboral_V1] @IDProyecto = @IDProyecto
		END;
GO

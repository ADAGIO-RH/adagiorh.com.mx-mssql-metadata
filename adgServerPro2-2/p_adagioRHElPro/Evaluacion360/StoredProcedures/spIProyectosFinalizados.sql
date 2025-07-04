USE [p_adagioRHElPro]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Inserta los proyectos finalizados para revision de resultados.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2025-01-08
** Parametros		: @IDProyecto				Identificador del proyecto
**					: @IDUsuario				Identificador del usuario
** IDAzure			: #1323

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spIProyectosFinalizados](
	@IDProyecto		INT = 0
	, @IDUsuario	INT = 0
)
AS
	BEGIN

		-- VARIABLES
		DECLARE @IDUsuarioAdmin					INT
				, @LinkResultadoProyecto		VARCHAR(MAX)	
				, @ListaDeEvaluadores			VARCHAR(MAX) = NULL
				, @BtnResultadoProyecto_ESMX	VARCHAR(MAX)
				, @BtnResultadoProyecto_ENUS	VARCHAR(MAX)
				, @BtnResultadoProyecto			VARCHAR(MAX)
				, @CANCELADO					INT = 14
				, @TODOS_LOS_ESTATUS			INT = 3
				;


		-- ID DE USUARIO ADMINISTRADOR
		SELECT @IDUsuarioAdmin = CAST(Valor AS INT) 
		FROM [App].[tblConfiguracionesGenerales] WITH (NOLOCK)
		WHERE IDConfiguracion = 'IDUsuarioAdmin';


		-- LINK DEL SITIO
		SELECT TOP 1 @LinkResultadoProyecto = valor 
		FROM [App].[tblConfiguracionesGenerales]
		WHERE IDConfiguracion = 'Url'	
		
		
		-- TABLAS TEMPORALES
		DECLARE @TblEvaluadores TABLE
		(
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


		-- OBTENEMOS LOS EVALUADORES DE LA PRUEBA
		INSERT @TblEvaluadores(
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
		EXEC [Evaluacion360].[spBuscarPruebasPorProyecto] @IDProyecto = @IDProyecto, @Tipo = @TODOS_LOS_ESTATUS, @IDUsuario = @IDUsuarioAdmin


		-- CONVERTIMOS LOS EVALUADORES DE LA PRUEBA EN FORMATO LISTA HTML
		SELECT @ListaDeEvaluadores = (
			'<ul class=''leaders''>' +
			(
				SELECT TOP 3 '<li>' + SUB_QUERY.Evaluador + '</li>'
				FROM (
						SELECT DISTINCT E.Evaluador
						FROM @TblEvaluadores E
						WHERE E.IDEstatus <> @CANCELADO
				) AS SUB_QUERY
				ORDER BY SUB_QUERY.Evaluador
				FOR XML PATH(''), TYPE
			).value('.', 'NVARCHAR(MAX)') + '</ul>'
		);	


		-- OBTENEMOS BOTONES
		SET @BtnResultadoProyecto_ESMX = '<a href=' + @LinkResultadoProyecto + ' target="_blank" style="cursor: pointer;"><button style="background-color: #0073e6; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer;">Resultados del Proyecto</button></a>'
		SET @BtnResultadoProyecto_ENUS = '<a href=' + @LinkResultadoProyecto + ' target="_blank" style="cursor: pointer;"><button style="background-color: #0073e6; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer;">Project Results</button></a>'
		SET @BtnResultadoProyecto = '{"esmx": {"ValorDinamico": "' + REPLACE(REPLACE(@BtnResultadoProyecto_ESMX, '"', '\"'), '''', '\"') + '"},"enus": {"ValorDinamico": "' + REPLACE(REPLACE(@BtnResultadoProyecto_ENUS, '"', '\"'), '''', '\"') + '"}}'


		-- INSERTAR PROYECTOS FINALIZADOS
		INSERT INTO [Evaluacion360].[tblProyectosFinalizados]
		SELECT -- PROYECTO
				P.IDProyecto			
				, P.Nombre AS NombreProyecto
				, P.Descripcion AS DescripcionProyecto
				, P.FechaCreacion AS FechaCreacionProyecto
				, P.FechaInicio AS FechaInicioProyecto
				, P.FechaFin AS FechaFinProyecto
				-- ENCARGADOS PROYECTOS				
				, CASE WHEN EP.IDCatalogoGeneral = 3 THEN COALESCE(EP.Nombre, '') ELSE '' END NombreContactoProyecto
				, CASE WHEN EP.IDCatalogoGeneral = 3 THEN COALESCE(EP.Email, '') ELSE '' END EmailContactoProyecto
				-- EDITORES PROYECTO
				, E.IDEditor
				, E.Editor AS NombreEditor				
				, @BtnResultadoProyecto AS BotonResultadoEditor				
				-- LISTA EVALUADORES
				, @ListaDeEvaluadores AS ListaEvaluadores
				-- EMAILS
				, Email = ISNULL(E.EmailEditor, (SELECT CE.[Value] AS Email FROM [RH].[tblContactoEmpleado] CE WHERE CE.IDEmpleado = E.IDEmpleado))
				, EmailValid = [Utilerias].[fsValidarEmail](ISNULL(E.EmailEditor, (SELECT CE.[Value] AS Email FROM [RH].[tblContactoEmpleado] CE WHERE CE.IDEmpleado = E.IDEmpleado)))
		FROM [Evaluacion360].[tblCatProyectos] P
			LEFT JOIN [Evaluacion360].[tblEncargadosProyectos] EP WITH (NOLOCK) ON EP.IDProyecto = P.IDProyecto
			LEFT JOIN (
						SELECT AP.IDProyecto
								, U.IDUsuario AS IDEditor
								, (U.Nombre + ' ' + U.Apellido) AS Editor
								, U.Email AS EmailEditor
								, U.IDEmpleado AS IDEmpleado
						FROM [Evaluacion360].[tblAdministradoresProyecto] AP
							JOIN [Seguridad].[tblUsuarios] U ON U.IDUsuario = AP.IDUsuario
					  ) E ON P.IDProyecto = E.IDProyecto
		WHERE P.IDProyecto = @IDProyecto


	END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Inserta las evaluaciones autorizadas y lanzadas.
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-10-24
** Parametros		: @IDProyecto	Identificador del proyecto
**					: @IDUsuario	Identificador del usuario
** IDAzure			: #1209

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROC [Evaluacion360].[spIInvitacionesEvaluacionClimaLaboral](
	@IDProyecto		INT = 0	
	, @IDUsuario	INT = 0
)
AS
	BEGIN

		DECLARE @SiteURL				VARCHAR(MAX)
				, @ActiveAccountUrl		VARCHAR(MAX)
				, @IDUsuarioActivar		INT = 0
				, @Total				INT = 0
				, @Cont					INT = 1
				, @key					VARCHAR(MAX)
				, @EVALUADOR_ASIGNADO	INT = 4
				;
		

		-- TABLAS TEMPORALES
		DECLARE @Evaluaciones TABLE
		(
			IDEvaluacionEmpleado			INT
			, IDEmpleadoProyecto			INT
			, IDTipoRelacion				INT
			, Relacion						VARCHAR(255)
			, IDEvaluador					INT
			, ClaveEvaluador				VARCHAR(20)
			, Evaluador						VARCHAR(255)
			, IDProyecto					INT
			, Proyecto						[App].[MDName]
			, IDEmpleado					INT
			, ClaveEmpleado					VARCHAR(20)
			, Colaborador					VARCHAR(255)
			, IDEstatusEvaluacionEmpleado	INT
			, IDEstatus						INT
			, Estatus						VARCHAR(255)
			, IDUsuario						INT
			, FechaCreacion					DATETIME
			, Progreso						INT
		)

		DECLARE @Invitaciones TABLE
		(
			IDInvitacion			INT IDENTITY(1,1)
			, IDProyecto			INT
			, IDEvaluador			INT
			, IDEvaluacionEmpleado	INT
			, BotonContestar		VARCHAR(MAX) NULL
		)

		DECLARE @TblInvitacionesNuevas TABLE
		(
			IDProyecto				INT
			, IDEvaluador			INT
			, IDEvaluacionEmpleado	INT
			, BotonContestar		VARCHAR(MAX) NULL
		)

		
		-- OBTENEMOS LA URL DEL SITIO
		SELECT TOP 1 @SiteURL = Valor 
		FROM App.tblConfiguracionesGenerales WITH (NOLOCK)
		WHERE IDConfiguracion = 'Url';
		--SELECT @SiteURL


		-- OBTENEMOS LA LIGA DONDE PODREMOS ACTIVA LA CUENTA (ESTA VIENE SIN EL QUERY PARAMETERS)
		SELECT TOP 1 @ActiveAccountUrl = Valor 
		FROM [App].[tblConfiguracionesGenerales] WITH (NOLOCK)
		WHERE IDConfiguracion = 'ActiveAccountUrl';
		--SELECT @ActiveAccountUrl

		
		-- OBTENEMOS LAS EVALUACIONES QUE YA TIENEN ASIGNADO A UN EVALUADOR
		INSERT INTO @Evaluaciones
		EXEC [Evaluacion360].[spBuscarPruebasPorProyecto] 
			@IDProyecto = @IDProyecto
			, @Tipo = @EVALUADOR_ASIGNADO
			, @IDUsuario = @IDUsuario;
		--SELECT * FROM @Evaluaciones
		
				
		-- OBTENEMOS A LOS EVALUADORES
		INSERT INTO @Invitaciones
		SELECT EVALUADORES.IDProyecto
				, EVALUADORES.IDEvaluador
				, EVALUADORES.IDEvaluacionEmpleado
				, NULL AS BotonContestar
		FROM (SELECT EV.IDProyecto, EV.IDEvaluador, EV.IDEvaluacionEmpleado FROM @Evaluaciones EV GROUP BY EV.IDEvaluador, EV.IDProyecto, EV.IDEvaluacionEmpleado) EVALUADORES
		--SELECT * FROM @Invitaciones
	

		SELECT @Total = COUNT(IDInvitacion) FROM @Invitaciones;
		WHILE @Cont <= @Total
			BEGIN

				DECLARE @IDEvaluador				INT = 0
						, @BtnContestar_ESMX		VARCHAR(MAX)
						, @BtnContestar_ENUS		VARCHAR(MAX)
						;

				-- IDENTIFICACION EVALUADOR
				SELECT @IDEvaluador = IDEvaluador FROM @Invitaciones WHERE IDInvitacion = @Cont;

				-- SE VALIDA SI EL COLABORADOR ESTA ACTIVO Y SU USUARIO NO SE ENCUENTRA ACTIVO
				IF EXISTS(
					SELECT TOP 1 1
					FROM [Seguridad].[tblUsuarios] U WITH (NOLOCK)
						JOIN [RH].[tblEmpleadosMaster] E ON U.IDEmpleado = E.IDEmpleado
					WHERE U.IDEmpleado = @IDEvaluador AND ISNULL(U.Activo, CAST(0 AS BIT)) = 0 AND ISNULL(E.Vigente, CAST(0 AS BIT)) = 1
				)
 					BEGIN

						SET @key = REPLACE(NEWID(), '-', '') + '' + REPLACE(NEWID(), '-', '');
						
						SELECT TOP 1 @IDUsuarioActivar = IDUsuario
						FROM [Seguridad].[tblUsuarios] WITH (NOLOCK)
						WHERE IDEmpleado = @IDEvaluador;

						INSERT [Seguridad].TblUsuariosKeysActivacion(IDUsuario, ActivationKey, AvaibleUntil, Activo)
						SELECT @IDUsuarioActivar, @key, DATEADD(DAY, 30, GETDATE()), 1;

						SET @BtnContestar_ESMX = '<a href=' + @ActiveAccountUrl + @key + ' target="_blank" style="cursor: pointer;"><button style="background-color: #0073e6; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer;">Activa tu cuenta y realiza la evaluación</button></a>'
						SET @BtnContestar_ENUS = '<a href=' + @ActiveAccountUrl + @key + ' target="_blank" style="cursor: pointer;"><button style="background-color: #0073e6; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer;">Activate your account and take the assessment</button></a>'
						
					END
				ELSE
					BEGIN
						SET @BtnContestar_ESMX = '<a href=' + @SiteURL + ' target="_blank" style="cursor: pointer;"><button style="background-color: #0073e6; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer;">Realiza la evaluación</button></a>'
						SET @BtnContestar_ENUS = '<a href=' + @SiteURL + ' target="_blank" style="cursor: pointer;"><button style="background-color: #0073e6; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer;">Perform the assessment</button></a>'
					END;


				-- RECOLECCION DE (BtnContestar)
				UPDATE @Invitaciones 
					SET BotonContestar = '{"esmx": {"ValorDinamico": "' + REPLACE(REPLACE(@BtnContestar_ESMX, '"', '\"'), '''', '\"') + '"},"enus": {"ValorDinamico": "' + REPLACE(REPLACE(@BtnContestar_ENUS, '"', '\"'), '''', '\"') + '"}}'
				WHERE IDInvitacion = @Cont;
			
				SET @Cont = @Cont + 1;

			END;
		--SELECT * FROM @Invitaciones



		-- FILTRAMOS LAS INVITACIONES NUEVAS
		INSERT INTO @TblInvitacionesNuevas
		SELECT IDProyecto
				, IDEvaluador
				, IDEvaluacionEmpleado
				, BotonContestar
		FROM @Invitaciones INV
		WHERE 
		(
			SELECT TOP 1 INV2.IDEvaluacionEmpleado 
			FROM [Evaluacion360].[tblInvitacionesEvaluacionClimaLaboral] INV2
			WHERE INV2.IDEvaluador = INV.IDEvaluador
					AND INV2.IDProyecto = INV.IDProyecto
			ORDER BY INV2.IDInvitacion DESC
		) IS NULL -- NO EXISTE UN REGISTRO ANTERIOR
		OR 
		(
			SELECT TOP 1 INV3.IDEvaluacionEmpleado 
			FROM [Evaluacion360].[tblInvitacionesEvaluacionClimaLaboral] INV3
			WHERE INV3.IDEvaluador = INV.IDEvaluador
					AND INV3.IDProyecto = INV.IDProyecto
			ORDER BY INV3.IDInvitacion DESC
		) != INV.IDEvaluacionEmpleado -- EL REGISTRO ES DIFERENTE
		--AND INV.IDEvaluador = 26541;



		-- CREAR INVITACIONES NUEVAS
		INSERT INTO [Evaluacion360].[tblInvitacionesEvaluacionClimaLaboral]
		SELECT  -- PROYECTO
				P.IDProyecto
				, P.Nombre AS NombreProyecto
				, P.Descripcion AS DescripcionProyecto
				, P.FechaCreacion AS FechaCreacionProyecto
				, P.FechaInicio AS FechaInicioProyecto
				, P.FechaFin AS FechaFinProyecto
				-- ENCARGADOS PROYECTOS				
				, CASE WHEN EP.IDCatalogoGeneral = 3 THEN COALESCE(EP.Nombre, '') ELSE '' END NombreContactoProyecto
				, CASE WHEN EP.IDCatalogoGeneral = 3 THEN COALESCE(EP.Email, '') ELSE '' END EmailContactoProyecto
				-- EVALUADOR
				, EM1.IDEmpleado AS IDEvaluador
			    , EM1.ClaveEmpleado AS ClaveEvaluador
			    , EM1.RFC AS RFCEvaluador
			    , EM1.CURP AS CURPEvaluador
			    , EM1.IMSS AS IMSSEvaluador
			    , EM1.Nombre AS NombreEvaluador
			    , EM1.Paterno AS PaternoEvaluador
			    , EM1.Materno AS MaternoEvaluador
			    , EM1.NOMBRECOMPLETO AS NOMBRECOMPLETOEvaluador
			    , EM1.LocalidadNacimiento AS LocalidadNacimientoEvaluador
			    , EM1.MunicipioNacimiento AS MunicipioNacimientoEvaluador
			    , EM1.EstadoNacimiento AS EstadoNacimientoEvaluador
			    , EM1.PaisNacimiento AS PaisNacimientoEvaluador
			    , EM1.FechaNacimiento AS FechaNacimientoEvaluador
			    , EM1.EstadoCivil AS EstadoCivilEvaluador
			    , EM1.Sexo AS SexoEvaluador
			    , EM1.Escolaridad AS EscolaridadEvaluador
			    , EM1.DescripcionEscolaridad AS DescripcionEscolaridadEvaluador
			    , EM1.Institucion AS InstitucionEvaluador
			    , EM1.Probatorio AS ProbatorioEvaluador
			    , EM1.FechaIngreso AS FechaIngresoEvaluador
			    , EM1.FechaAntiguedad AS FechaAntiguedadEvaluador
			    , EM1.JornadaLaboral AS JornadaLaboralEvaluador
			    , EM1.TipoRegimen AS TipoRegimenEvaluador
			    , EM1.Departamento AS DepartamentoEvaluador
			    , EM1.Sucursal AS SucursalEvaluador
			    , EM1.Puesto AS PuestoEvaluador
			    , EM1.Cliente AS ClienteEvaluador
			    , EM1.Empresa AS EmpresaEvaluador
			    , EM1.CentroCosto AS CentroCostoEvaluador
			    , EM1.Area AS AreaEvaluador
			    , EM1.Division AS DivisionEvaluador
			    , EM1.Region AS RegionEvaluador
			    , EM1.ClasificacionCorporativa AS ClasificacionCorporativaEvaluador
			    , EM1.RegPatronal AS RegPatronalEvaluador
			    , EM1.TipoNomina AS TipoNominaEvaluador
			    , EM1.RazonSocial AS RazonSocialEvaluador
			    , EM1.Afore AS AforeEvaluador
			    , EM1.FechaIniContrato AS FechaIniContratoEvaluador
			    , EM1.FechaFinContrato AS FechaFinContratoEvaluador
			    , EM1.TiposPrestacion AS TiposPrestacionEvaluador
			    , EM1.tipoTrabajadorEmpleado AS TipoTrabajadorEmpleadoEvaluador				
				, INV.BotonContestar AS BotonContestarEvaluador
				-- EVALUADOS (AUTO-EVALUACION)				
				, INV.IDEvaluacionEmpleado				
		FROM @TblInvitacionesNuevas INV
			JOIN [Evaluacion360].[tblCatProyectos] P WITH (NOLOCK) ON INV.IDProyecto = P.IDProyecto
			LEFT JOIN [Evaluacion360].[tblEncargadosProyectos] EP WITH (NOLOCK) ON INV.IDProyecto = EP.IDProyecto
			LEFT JOIN [RH].[tblEmpleadosMaster] EM1 WITH (NOLOCK) ON INV.IDEvaluador = EM1.IDEmpleado


	END
GO

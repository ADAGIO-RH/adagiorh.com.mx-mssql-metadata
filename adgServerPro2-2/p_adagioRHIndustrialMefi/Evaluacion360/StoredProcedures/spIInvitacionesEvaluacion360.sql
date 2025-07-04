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
** FechaCreacion	: 2024-10-15
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

CREATE   PROC [Evaluacion360].[spIInvitacionesEvaluacion360](
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
			, BotonContestar		VARCHAR(MAX) NULL
			, IDsEvaluacionEmpleado	VARCHAR(MAX) NULL
			, ListaAEvaluar			VARCHAR(MAX) NULL			
		)

		DECLARE @TblInvitacionesNuevas TABLE
		(
			IDProyecto				INT
			, IDEvaluador			INT
			, BotonContestar		VARCHAR(MAX) NULL
			, IDsEvaluacionEmpleado	VARCHAR(MAX) NULL
			, ListaAEvaluar			VARCHAR(MAX) NULL			
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
				, NULL AS BotonContestar
				, NULL AS IDsEvaluacionEmpleado
				, NULL AS ListaAEvaluar
		FROM (SELECT EV.IDEvaluador, EV.IDProyecto FROM @Evaluaciones EV GROUP BY EV.IDEvaluador, EV.IDProyecto) EVALUADORES
		--SELECT * FROM @Invitaciones
	

		SELECT @Total = COUNT(IDInvitacion) FROM @Invitaciones;
		WHILE @Cont <= @Total
			BEGIN

				DECLARE @IDEvaluador				INT = 0
						, @NoEvaluaciones			INT = 0
						, @IDsEvaluacionEmpleado	VARCHAR(MAX)
						, @ListaAEvaluar_ESMX		VARCHAR(MAX)
						, @ListaAEvaluar_ENUS		VARCHAR(MAX)
						, @BtnContestar_ESMX		VARCHAR(MAX)
						, @BtnContestar_ENUS		VARCHAR(MAX)
						;

				-- IDENTIFICACION EVALUADOR
				SELECT @IDEvaluador = IDEvaluador FROM @Invitaciones WHERE IDInvitacion = @Cont;

				-- OBTENERMOS EL NUMERO DE EVALUACIONES A REALIZAR
				SELECT @NoEvaluaciones = COUNT(EV1.IDEvaluacionEmpleado)
				FROM @Evaluaciones EV1
				WHERE EV1.IDEvaluador = @IDEvaluador	
				

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

						SET @BtnContestar_ESMX = '<a href=' + @ActiveAccountUrl + @key + ' target="_blank" style="cursor: pointer;"><button style="background-color: #0073e6; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer;">' + CASE WHEN @NoEvaluaciones = 1 THEN 'Activa tu cuenta y realiza la evaluación' ELSE 'Activa tu cuenta y realiza las evaluaciones' END + '</button></a>'
						SET @BtnContestar_ENUS = '<a href=' + @ActiveAccountUrl + @key + ' target="_blank" style="cursor: pointer;"><button style="background-color: #0073e6; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer;">' + CASE WHEN @NoEvaluaciones = 1 THEN 'Activate your account and take the assessment' ELSE 'Activate your account and take the assessments' END + '</button></a>'
						
					END
				ELSE
					BEGIN
						SET @BtnContestar_ESMX = '<a href=' + @SiteURL + ' target="_blank" style="cursor: pointer;"><button style="background-color: #0073e6; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer;">' + CASE WHEN @NoEvaluaciones = 1 THEN 'Realiza la evaluación' ELSE 'Realiza las evaluaciones' END + '</button></a>'
						SET @BtnContestar_ENUS = '<a href=' + @SiteURL + ' target="_blank" style="cursor: pointer;"><button style="background-color: #0073e6; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer;">' + CASE WHEN @NoEvaluaciones = 1 THEN 'Perform the assessment' ELSE 'Perform the assessments' END + '</button></a>'
					END;


				-- OBTENEMOS LA LISTA DE LOS "IDsEvaluacionEmpleado" QUE SE VAN A EVALUAR
				SELECT @IDsEvaluacionEmpleado = (
					SELECT EV1.IDEvaluacionEmpleado
					FROM @Evaluaciones EV1
					WHERE EV1.IDEvaluador = @IDEvaluador
					ORDER BY EV1.IDTipoRelacion
					FOR JSON AUTO
				);


				-- OBTENEMOS LA LISTA DE LOS COLABORADORES QUE SE VAN A EVALUAR (Relacion y Colaborador)
				SELECT @ListaAEvaluar_ESMX = (
					'<ul class=''leaders''>' + 
					(
						SELECT TOP 3
							'<li><b>' + ISNULL(JSON_VALUE(TR.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE('esmx', '-', '')) + '', 'Relacion')), '') + ':</b> ' + EV2.ClaveEmpleado + ' - ' + EV2.Colaborador + '</li>'
						FROM @Evaluaciones EV2
							JOIN [Evaluacion360].[tblCatTiposRelaciones] TR ON EV2.IDTipoRelacion = TR.IDTipoRelacion
						WHERE EV2.IDEvaluador = @IDEvaluador
						ORDER BY EV2.IDTipoRelacion
						FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') + '</ul>'
				);
				SELECT @ListaAEvaluar_ENUS = (
					'<ul class=''leaders''>' + 
					(
						SELECT TOP 3
							'<li><b>' + ISNULL(JSON_VALUE(TR.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE('enus', '-', '')) + '', 'Relacion')), '') + ':</b> ' + EV2.ClaveEmpleado + ' - ' + EV2.Colaborador + '</li>'
						FROM @Evaluaciones EV2
							JOIN [Evaluacion360].[tblCatTiposRelaciones] TR ON EV2.IDTipoRelacion = TR.IDTipoRelacion
						WHERE EV2.IDEvaluador = @IDEvaluador
						ORDER BY EV2.IDTipoRelacion
						FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') + '</ul>'
				);
				 
				  
				-- RECOLECCION DE (IDsEvaluacionEmpleado, ListaAEvaluar, BtnContestar)
				UPDATE @Invitaciones 
					SET BotonContestar = '{"esmx": {"ValorDinamico": "' + REPLACE(REPLACE(@BtnContestar_ESMX, '"', '\"'), '''', '\"') + '"},"enus": {"ValorDinamico": "' + REPLACE(REPLACE(@BtnContestar_ENUS, '"', '\"'), '''', '\"') + '"}}' 
						, ListaAEvaluar = '{"esmx": {"ValorDinamico": "' + REPLACE(REPLACE(@ListaAEvaluar_ESMX, '"', '\"'), '''', '\"')  + '"},"enus": {"ValorDinamico": "' + REPLACE(REPLACE(@ListaAEvaluar_ENUS, '"', '\"'), '''', '\"') + '"}}'						
						, IDsEvaluacionEmpleado =  @IDsEvaluacionEmpleado
				WHERE IDInvitacion = @Cont;
			
				SET @Cont = @Cont + 1;

			END;
		--SELECT * FROM @Invitaciones



		-- FILTRAMOS LAS INVITACIONES NUEVAS
		INSERT INTO @TblInvitacionesNuevas
		SELECT IDProyecto
				, IDEvaluador
				, BotonContestar
				, IDsEvaluacionEmpleado
				, ListaAEvaluar
		FROM @Invitaciones INV			
		WHERE 
		(
			SELECT TOP 1 INV2.IDsEvaluacionEmpleado 
			FROM [Evaluacion360].[tblInvitacionesEvaluacion360] INV2
			WHERE INV2.IDEvaluador = INV.IDEvaluador
					AND INV2.IDProyecto = INV.IDProyecto
			ORDER BY INV2.IDInvitacion DESC
		) IS NULL -- NO EXISTE UN REGISTRO ANTERIOR
		OR 
		(
			SELECT TOP 1 INV3.IDsEvaluacionEmpleado 
			FROM [Evaluacion360].[tblInvitacionesEvaluacion360] INV3
			WHERE INV3.IDEvaluador = INV.IDEvaluador
					AND INV3.IDProyecto = INV.IDProyecto
			ORDER BY INV3.IDInvitacion DESC
		) != INV.IDsEvaluacionEmpleado -- EL REGISTRO ES DIFERENTE
		--AND INV.IDEvaluador = 26541;





		-- CREAR INVITACIONES NUEVAS
		INSERT INTO [Evaluacion360].[tblInvitacionesEvaluacion360]
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
				-- EVALUADOS				
				, INV.IDsEvaluacionEmpleado
				, INV.ListaAEvaluar
		FROM @TblInvitacionesNuevas INV
			JOIN [Evaluacion360].[tblCatProyectos] P WITH (NOLOCK) ON INV.IDProyecto = P.IDProyecto
			LEFT JOIN [Evaluacion360].[tblEncargadosProyectos] EP WITH (NOLOCK) ON INV.IDProyecto = EP.IDProyecto
			LEFT JOIN [RH].[tblEmpleadosMaster] EM1 WITH (NOLOCK) ON INV.IDEvaluador = EM1.IDEmpleado


	END
GO

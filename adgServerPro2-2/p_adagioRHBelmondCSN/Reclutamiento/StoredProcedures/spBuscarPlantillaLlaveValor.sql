USE [p_adagioRHBelmondCSN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2022-05-19
-- Description:	procedimiento para obtener los campos que irán
--				en las plantillas del proceso de selección
-- [Reclutamiento].[spBuscarPlantillaLlaveValor] 10,1279, 'Plaza','Prestaciones'
-- =============================================
CREATE PROCEDURE [Reclutamiento].[spBuscarPlantillaLlaveValor] (
	@IDCandidatoPlaza INT = 0
	,@IDReclutador INT = 0
	,@Tabla VARCHAR(100) = NULL
	,@Campo VARCHAR(100) = NULL
	)
AS
BEGIN
	SET @Tabla = REPLACE(REPLACE(@Tabla, '{', ''), '}', '')
	SET @Campo = REPLACE(REPLACE(@Campo, '{', ''), '}', '')

	DECLARE @tblPlantillaCampos TABLE (
		[KEY] VARCHAR(max)
		,[VALUE] VARCHAR(max)
		)
	DECLARE @IDPlaza INT = 0
		,@Puesto VARCHAR(max) = ''

	-- Candidato
	INSERT INTO @tblPlantillaCampos
	SELECT CONCAT (
			'Candidato'
			,isnull(B.[Key], '')
			)
		,B.[Value]
	FROM (
		SELECT tblCandidato.IDCandidato
			,tblCandidato.Nombre
			,isnull(tblCandidato.SegundoNombre, '') SegundoNombre
			,tblCandidato.Paterno
			,tblCandidato.Materno
			,tblCandidato.Sexo
			,tblCandidato.FechaNacimiento
			,isnull(pais.Descripcion, '') Pais
			,isnull(estados.NombreEstado, '') Estado
			,isnull(municipio.Descripcion, '') Municipio
			,isnull(localidad.Descripcion, '') Localidad
			,isnull(tblCandidato.RFC, '') RFC
			,isnull(tblCandidato.CURP, 'N/A') CURP
			,isnull(tblCandidato.NSS, 'N/A') NSS
			,isnull(tblCandidato.IDEstadoCivil, 0) IDEstadoCivil
			,isnull(tblCandidato.Estatura, 0) Estatura
			,isnull(tblCandidato.Peso, 0) Peso
			,isnull(tblCandidato.TipoSangre, 'N/A') TipoSangre
			,tblCandidato.Extranjero
			,isnull(afores.Descripcion, 'N/A') AFORE
			,isnull(tblCandProc.IDPlaza, 0) IDPlaza
			,isnull(tblCandProc.IDEstatusProceso, 0) IDEstatusProceso
			,isnull(tblStProceso.Descripcion, 'N/A') Descripcion
			,tblStProceso.MostrarEnProcesoSeleccion
			,isnull(tblStProceso.Orden, 0) Orden
			,isnull(tblStProceso.Color, 'N/A') Color
		FROM Reclutamiento.tblCandidatoPlaza AS CandidatoPlaza
		LEFT JOIN Reclutamiento.tblCandidatos AS tblCandidato ON CandidatoPlaza.IDCandidato = tblCandidato.IDCandidato
		LEFT JOIN Reclutamiento.tblCandidatosProceso AS tblCandProc ON tblCandidato.IDCandidato = tblCandProc.IDCandidato
		LEFT JOIN Reclutamiento.tblCatEstatusProceso AS tblStProceso ON tblCandProc.IDEstatusProceso = tblStProceso.IDEstatusProceso
		LEFT JOIN Reclutamiento.tblCurriculumDigitalCandidato AS tblCurriculum ON tblCandidato.IDCandidato = tblCurriculum.IDCandidato
		LEFT JOIN SAT.tblCatPaises pais ON tblCandidato.IDPaisNacimiento = pais.IDPais
		LEFT JOIN SAT.tblCatEstados estados ON tblCandidato.IDEstadoNacimiento = estados.IDEstado
		LEFT JOIN SAT.tblCatMunicipios municipio ON tblCandidato.IDMunicipioNacimiento = municipio.IDMunicipio
		LEFT JOIN SAT.tblCatLocalidades localidad ON tblCandidato.IDLocalidadNacimiento = localidad.IDLocalidad
		LEFT JOIN [RH].[tblCatAfores] afores ON tblCandidato.IDAFORE = afores.IDAfore
		LEFT JOIN RH.tblCatPlazas plazas ON tblCandProc.IDPlaza = plazas.IDPlaza
		LEFT JOIN RH.tblCatPuestos puesto ON plazas.IDPuesto = puesto.IDPuesto
		WHERE CandidatoPlaza.IDCandidatoPlaza = @IDCandidatoPlaza
		) A
	CROSS APPLY OpenJSON((
				SELECT A.*
				FOR JSON Path
					,Without_Array_Wrapper
				)) B

	SELECT @IDPlaza = tblCandidatoPlaza.IDPlaza
		,@Puesto =JSON_VALUE(tblCatPuestos.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) 
	FROM Reclutamiento.tblCandidatoPlaza
	LEFT JOIN RH.tblCatPlazas ON tblCandidatoPlaza.IDPlaza = tblCatPlazas.IDPlaza
	LEFT JOIN RH.tblCatPuestos ON tblCatPlazas.IDPuesto = tblCatPuestos.IDPuesto
	WHERE IDCandidatoPlaza = @IDCandidatoPlaza

	-- Reclutador
	INSERT INTO @tblPlantillaCampos
	SELECT CONCAT (
			'Reclutador'
			,isnull(B.[Key], '')
			)
		,B.[Value]
	FROM (
		SELECT e.IDEmpleado
			,e.ClaveEmpleado
			,e.NOMBRECOMPLETO AS NombreColaborador
			,j.IDJefe
			,eJefe.NOMBRECOMPLETO AS NombreJefe
			,isnull(e.FechaNacimiento, '1900-01-01') AS FechaNacimiento
			,Utilerias.fnDateToStringByFormat(e.FechaNacimiento, 'FL', 'Spanish') AS FL_FechaNacimiento
			,Utilerias.fnDateToStringByFormat(e.FechaNacimiento, 'FM', 'Spanish') AS FM_FechaNacimiento
			,isnull(ejefe.FechaNacimiento, '1900-01-01') AS FechaNacimientoJefe
			,Utilerias.fnDateToStringByFormat(ejefe.FechaNacimiento, 'FL', 'Spanish') AS FL_FechaNacimientoJefe
			,Utilerias.fnDateToStringByFormat(ejefe.FechaNacimiento, 'FM', 'Spanish') AS FM_FechaNacimientoJefe
		FROM RH.tblEmpleadosMaster e
		JOIN RH.tblJefesEmpleados j ON j.IDEmpleado = e.IDEmpleado
			AND j.IDJefe = 72
		JOIN RH.tblEmpleadosMaster ejefe ON ejefe.IDEmpleado = j.IDJefe
		LEFT JOIN [Seguridad].[tblUsuarios] u ON e.IDEmpleado = u.IDEmpleado
		WHERE u.IDUsuario = @IDReclutador
		) A
	CROSS APPLY OpenJSON((
				SELECT A.*
				FOR JSON Path
					,Without_Array_Wrapper
				)) B

	--Plaza
	DECLARE @DatosPlaza TABLE (
		IDTipoConfiguracionPlaza VARCHAR(max)
		,TipoConfiguracionPlaza VARCHAR(max)
		,Configuracion VARCHAR(max)
		,Valor INT
		,descripcion VARCHAR(max)
		,Orden INT
		)

	DROP TABLE

	IF EXISTS #tmpDatosPlaza
		CREATE TABLE #tmpDatosPlaza (
			IDTipoConfiguracionPlaza VARCHAR(max)
			,TipoConfiguracionPlaza VARCHAR(max)
			,Configuracion VARCHAR(max)
			,Valor INT
			,descripcion VARCHAR(max)
			,Orden INT
			)

	DECLARE @CandidatoIDPlaza INT = 0
		,@PlazaPuesto VARCHAR(max) = ''

	SELECT @CandidatoIDPlaza = [VALUE]
	FROM @tblPlantillaCampos
	WHERE [KEY] = 'CandidatoIDPlaza'

	SELECT @PlazaPuesto = Descripcion
	FROM RH.tblCatPuestos

	-- Generamos la tabla temporal para Plaza
	DECLARE @ConfiguracionesPlaza TABLE (
		IDTipoConfiguracionPlaza VARCHAR(max)
		,TipoConfiguracionPlaza VARCHAR(max)
		,Configuracion VARCHAR(max)
		,Valor INT
		,descripcion VARCHAR(max) DEFAULT('N/A')
		,Orden INT
		)

	-- Obtenemos los valores de las plazas y los insertamos 
	INSERT INTO @ConfiguracionesPlaza
	EXEC [RH].[spBuscarConfiguracionesPlazaByID] @IDPlaza
		,1
		,@WithDescripcion = 1

	INSERT INTO @tblPlantillaCampos
	SELECT CONCAT (
			'Plaza'
			,IDTipoConfiguracionPlaza
			)
		,isnull(descripcion, 'N/A')
	FROM @ConfiguracionesPlaza
	
	UNION ALL
	
	SELECT 'PlazaPuesto'
		,@Puesto

	IF (
			@Campo IS NOT NULL
			AND @Tabla IS NOT NULL
			)
	BEGIN
		SELECT [KEY]
			,[VALUE]
		FROM @tblPlantillaCampos
		WHERE [KEY] = CONCAT (
				@Tabla
				,@Campo
				)
	END
	ELSE
		SELECT [KEY]
			,[VALUE]
		FROM @tblPlantillaCampos
END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Procedimiento para obtener los campos que irán en las plantillas del proceso de selección
** Autor			: Emmanuel Contreras
** Email			: econtreras@adagio.com.mx
** FechaCreacion	: 2022-05-19
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2023-08-11			Emmanuel Contreras	Se agrego el default en función de la configuración
										Se agrego la función para obtener el mail a partir de si existe 
											algo en tblCatPosiciones en el campo de IDReclutador
2024-03-27			ANEUDY ABREU		Agrega campo traducción al select para la tabla Reclutamiento.tblCatEstatusProces
***************************************************************************************************/
CREATE PROCEDURE [Reclutamiento].[spBuscarPlantillaLlaveValor] (
	@IDCandidatoPlaza INT
	,@Tabla VARCHAR(100) = NULL
	,@Campo VARCHAR(100) = NULL
	,@IDUsuario int
)
AS
BEGIN
	DECLARE 
		@IDPlaza INT = 0
		, @IDReclutador int
		, @IDCliente int = 0
		, @Puesto VARCHAR(max) = ''
		, @IDReclutadorCatPosiciones INT
		, @IDIdiomaCandidato varchar(20)
	;

	-- TODO: Agrega idioma a candidato
	select @IDIdiomaCandidato= 'esmx'

	SET @Tabla = REPLACE(REPLACE(@Tabla, '{', ''), '}', '')
	SET @Campo = REPLACE(REPLACE(@Campo, '{', ''), '}', '')
	
	-- Generamos la tabla temporal para Plaza
	DECLARE @ConfiguracionesPlaza TABLE (
		IDTipoConfiguracionPlaza VARCHAR(max)
		,TipoConfiguracionPlaza VARCHAR(max)
		,Configuracion VARCHAR(max)
		,Valor INT
		,descripcion VARCHAR(max) DEFAULT('N/A')
		,Orden INT
	)

	DECLARE @tblPlantillaCampos TABLE (
		[KEY] VARCHAR(max)
		,[VALUE] VARCHAR(max)
	)

	DECLARE @DatosPlaza TABLE (
		IDTipoConfiguracionPlaza VARCHAR(max)
		,TipoConfiguracionPlaza VARCHAR(max)
		,Configuracion VARCHAR(max)
		,Valor INT
		,descripcion VARCHAR(max)
		,Orden INT
	)

	DROP TABLE IF EXISTS #tmpDatosPlaza;
	CREATE TABLE #tmpDatosPlaza (
		IDTipoConfiguracionPlaza VARCHAR(max)
		,TipoConfiguracionPlaza VARCHAR(max)
		,Configuracion VARCHAR(max)
		,Valor INT
		,descripcion VARCHAR(max)
		,Orden INT
	);
	
	SELECT 
		@IDPlaza = cp.IDPlaza
		,@Puesto =JSON_VALUE(puesto.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdiomaCandidato, '-','')), 'Descripcion')) 
		,@IDReclutador =
			case 
				when isnull(cp.IDReclutador, 0) != 0 then cp.IDReclutador
				when isnull(reclutador.IDReclutador, 0) != 0 then reclutador.IDReclutador
			else 0 end
	FROM Reclutamiento.tblCandidatoPlaza cp
		LEFT JOIN RH.tblCatPlazas plaza ON cp.IDPlaza = plaza.IDPlaza
		left join (
			select top 1 *
			from RH.tblCatPosiciones p
			where isnull(p.IDReclutador, 0) != 0
		) reclutador on reclutador.IDPlaza = cp.IDPlaza 
		LEFT JOIN RH.tblCatPuestos puesto ON plaza.IDPuesto = puesto.IDPuesto
	WHERE IDCandidatoPlaza = @IDCandidatoPlaza

	BEGIN -- Candidato
		INSERT INTO @tblPlantillaCampos
		SELECT CONCAT (
				'Candidato'
				,isnull(B.[Key], '')
				)
			,B.[Value]
		FROM (
			SELECT 
				tblCandidato.Nombre
				,isnull(tblCandidato.SegundoNombre, '') SegundoNombre
				,tblCandidato.Paterno
				,tblCandidato.Materno
				,tblCandidato.Sexo
				,tblCandidato.FechaNacimiento
				,tblCandidato.Email
				,isnull(pais.Descripcion, '') Pais
				,isnull(estados.NombreEstado, '') Estado
				,isnull(municipio.Descripcion, '') Municipio
				,isnull(localidad.Descripcion, '') Localidad
				,isnull(tblCandidato.RFC, '') RFC
				,isnull(tblCandidato.CURP, 'N/A') CURP
				,isnull(tblCandidato.NSS, 'N/A') NSS
				,JSON_VALUE(estadosCiviles.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdiomaCandidato, '-','')), 'Descripcion')) as EstadoCivil
				,isnull(tblCandidato.Estatura, 0) Estatura
				,isnull(tblCandidato.Peso, 0) Peso
				,isnull(tblCandidato.TipoSangre, 'N/A') TipoSangre
				,case when isnull(tblCandidato.Extranjero, 0) = 0 then 'NO' else 'SI' end as Extranjero
				,isnull(afores.Descripcion, 'N/A') AFORE
				,isnull(tblCandProc.IDPlaza, 0) IDPlaza
				,isnull(tblCandProc.IDEstatusProceso, 0) IDEstatusProceso
				,JSON_VALUE(tblStProceso.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdiomaCandidato, '-','')), 'Descripcion')) as EstatusProceso
			FROM Reclutamiento.tblCandidatoPlaza AS CandidatoPlaza
				LEFT JOIN Reclutamiento.tblCandidatos AS tblCandidato		ON CandidatoPlaza.IDCandidato = tblCandidato.IDCandidato
				LEFT JOIN Reclutamiento.tblCandidatosProceso AS tblCandProc ON tblCandidato.IDCandidato = tblCandProc.IDCandidato
				LEFT JOIN Reclutamiento.tblCatEstatusProceso AS tblStProceso ON tblCandProc.IDEstatusProceso = tblStProceso.IDEstatusProceso
				LEFT JOIN Reclutamiento.tblCurriculumDigitalCandidato AS tblCurriculum ON tblCandidato.IDCandidato = tblCurriculum.IDCandidato
				LEFT JOIN SAT.tblCatPaises pais				ON tblCandidato.IDPaisNacimiento = pais.IDPais
				LEFT JOIN SAT.tblCatEstados estados			ON tblCandidato.IDEstadoNacimiento = estados.IDEstado
				LEFT JOIN SAT.tblCatMunicipios municipio	ON tblCandidato.IDMunicipioNacimiento = municipio.IDMunicipio
				LEFT JOIN SAT.tblCatLocalidades localidad	ON tblCandidato.IDLocalidadNacimiento = localidad.IDLocalidad
				LEFT JOIN [RH].[tblCatAfores] afores		ON tblCandidato.IDAFORE = afores.IDAfore
				LEFT JOIN RH.tblCatPlazas plazas	ON tblCandProc.IDPlaza = plazas.IDPlaza
				LEFT JOIN RH.tblCatPuestos puesto	ON plazas.IDPuesto = puesto.IDPuesto
				LEFT JOIN RH.tblCatEstadosCiviles estadosCiviles on estadosCiviles.IDEstadoCivil = tblCandidato.IDEstadoCivil
			WHERE CandidatoPlaza.IDCandidatoPlaza = @IDCandidatoPlaza
		) A
		CROSS APPLY OpenJSON((
					SELECT A.*
					FOR JSON Path
						,Without_Array_Wrapper
					)) B
	END

	BEGIN -- Plaza
		-- Obtenemos los valores de la configuración de la plaza
		INSERT INTO @ConfiguracionesPlaza
		EXEC [RH].[spBuscarConfiguracionesPlazaByID] 
			@IDPlaza=@IDPlaza
			,@IDUsuario=@IDUsuario
			,@WithDescripcion = 1

		INSERT INTO @tblPlantillaCampos
		SELECT CONCAT (
				'Plaza'
				,IDTipoConfiguracionPlaza
				)
			,isnull(descripcion, 'N/A')
		FROM @ConfiguracionesPlaza
		UNION ALL	
		SELECT 
			'PlazaPuesto'
			,@Puesto
	END
	
	BEGIN -- Reclutador
		IF (isnull(@IDReclutador, 0) = 0)
		BEGIN 

			SELECT @IDCliente = p.IDCliente
			FROM Reclutamiento.tblCandidatoPlaza cp
			LEFT JOIN [RH].[tblCatPlazas] p ON p.IDPlaza = cp.IDPlaza
			WHERE IDCandidatoPlaza = @IDCandidatoPlaza;

			-- Combinar los resultados
			INSERT @tblPlantillaCampos
			SELECT 
				[Key],
				[Value]
			FROM RH.fnBuscaReclutadorDefaultPorCliente(@IDCliente)
		END
		ELSE
		BEGIN
			INSERT INTO @tblPlantillaCampos
				SELECT CONCAT (
						'Reclutador'
						,isnull(B.[Key], '')
						)
					,B.[Value]
				FROM (
					SELECT 
						e.NOMBRECOMPLETO AS NombreColaborador
						,[Utilerias].[fnGetCorreoEmpleado](e.IDEmpleado, u.IDUsuario, null) as Email
					FROM RH.tblEmpleadosMaster e
					LEFT JOIN [Seguridad].[tblUsuarios] u ON e.IDEmpleado = u.IDEmpleado
					WHERE e.IDEmpleado = @IDReclutador
				) A
				CROSS APPLY OpenJSON((
							SELECT A.*
							FOR JSON Path
								,Without_Array_Wrapper
							)) B

		END
	END

	;WITH cteDeleteDuplicate AS (
		SELECT 
			[KEY],
			ROW_NUMBER() OVER (
				PARTITION BY 
					[KEY]
				ORDER BY 
					[KEY], [VALUE]
			) row_num
		 FROM 
			@tblPlantillaCampos
	)
	DELETE FROM cteDeleteDuplicate
	WHERE row_num > 1;


	SELECT 
		[KEY]
		,[VALUE]
	FROM @tblPlantillaCampos
	WHERE (
		[KEY] = CONCAT (
			@Tabla
			,@Campo
		)
			or
			(isnull(@Campo, '') = '' and isnull(@Tabla, '') = '')
	)
END
GO

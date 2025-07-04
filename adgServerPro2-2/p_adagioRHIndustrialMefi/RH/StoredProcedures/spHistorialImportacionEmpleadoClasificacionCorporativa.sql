USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2023-02-10
-- Description:	SP para validar Historial Importacion Empleado Clasificacion Corporativa
-- =============================================
CREATE PROCEDURE [RH].[spHistorialImportacionEmpleadoClasificacionCorporativa](
	@dtHistorialEmpleado [RH].[dtHistorialEmpleado] READONLY
	, @IDUsuario INT = NULL
)
AS
BEGIN
	DECLARE @tempMessages AS TABLE (
		ID INT
		,[Message] VARCHAR(500)
		,Valid BIT
		);

	INSERT INTO @tempMessages (
		ID
		,[Message]
		,Valid
		)
	SELECT [IDMensajeTipo]
		,[Mensaje]
		,[Valid]
	FROM [RH].[tblMensajesMap]
	WHERE [MensajeTipo] = 'ImportacionHistorialEmpleadosClasificacionCorporativaMap'
	ORDER BY [IDMensajeTipo];

	DECLARE @dtDatosValidados TABLE(
		IDClasificacionCorporativaEmpleado int
		,IDEmpleado int
		,ClaveEmpleado varchar(255)
		,NombreCompleto varchar(255)
		,IDClasificacionCorporativa int
		,Codigo varchar(255)
		,Descripcion varchar(255)
		,FechaIni date
		,FechaFin date
		,Vigencia bit
	)

	DECLARE @dtDuplicados TABLE (
		IDEmpleado VARCHAR(255)
		,Codigo VARCHAR(255)
		,FechaIni Date
		,qty INT
		)

	DECLARE @dtVigencias TABLE (
		IDEmpleado VARCHAR(255)
		,Fecha DATE
		,Vigente BIT
		);

	DECLARE @Fechas [App].[dtFechas]
		,@dtEmpleados [RH].[dtEmpleados]
		,@DiasPeriodo INT
		,@FechaInicio date
		,@FechaFin date

	DECLARE @tempFechas [App].[dtFechas]

	--
	DECLARE @IDIdioma VARCHAR(MAX);
    select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx'), '-',''))   

	SELECT 
		@FechaInicio = min(FechaIni),
		@FechaFin = isnull(max(FechaFin), GETDATE()) 
	FROM @dtHistorialEmpleado 
	--GROUP BY FechaIni, FechaFin

	
		/* -- CODIGO PREVIO
	INSERT @tempFechas
	EXEC [App].[spListaFechas] @FechaInicio
		,@FechaFin
	*/

	-- MEJORA REALIZADA 2024-03-11 - JOSE ROMAN

	INSERT INTO @tempFechas (FECHA)
	SELECT DISTINCT FechaIni 
	FROM @dtHistorialEmpleado

	-- MEJORA REALIZADA 2024-03-11 - JOSE ROMAN

	SELECT @DiasPeriodo = count(*)
		FROM @tempFechas

	INSERT INTO @dtEmpleados
	SELECT IDEmpleado
		,DI.ClaveEmpleado
		,RFC
		,CURP
		,IMSS
		,Nombre
		,SegundoNombre
		,Paterno
		,Materno
		,NOMBRECOMPLETO
		,IDLocalidadNacimiento
		,LocalidadNacimiento
		,IDMunicipioNacimiento
		,MunicipioNacimiento
		,IDEstadoNacimiento
		,EstadoNacimiento
		,IDPaisNacimiento
		,PaisNacimiento
		,FechaNacimiento
		,IDEstadoCiviL
		,EstadoCivil
		,Sexo
		,IDEscolaridad
		,Escolaridad
		,DescripcionEscolaridad
		,IDInstitucion
		,Institucion
		,IDProbatorio
		,Probatorio
		,FechaPrimerIngreso
		,FechaIngreso
		,FechaAntiguedad
		,Sindicalizado
		,IDJornadaLaboral
		,JornadaLaboral
		,UMF
		,CuentaContable
		,IDTipoRegimen
		,TipoRegimen
		,IDPreferencia
		,IDDepartamento
		,Departamento
		,IDSucursal
		,Sucursal
		,IDPuesto
		,Puesto
		,IDCliente
		,Cliente
		,IDEmpresa
		,Empresa
		,IDCentroCosto
		,CentroCosto
		,IDArea
		,Area
		,IDDivision
		,Division
		,IDRegion
		,Region
		,IDClasificacionCorporativa
		,ClasificacionCorporativa
		,IDRegPatronal
		,RegPatronal
		,IDTipoNomina
		,TipoNomina
		,SalarioDiario
		,SalarioDiarioReal
		,SalarioIntegrado
		,SalarioVariable
		,IDTipoPrestacion
		,IDRazonSocial
		,RazonSocial
		,IDAfore
		,Afore
		,Vigente
		,RowNumber
		,ClaveNombreCompleto
		,PermiteChecar
		,RequiereChecar
		,PagarTiempoExtra
		,PagarPrimaDominical
		,PagarDescansoLaborado
		,PagarFestivoLaborado
		,IDDocumento
		,Documento
		,IDTipoContrato
		,TipoContrato
		,FechaIniContrato
		,FechaFinContrato
		,TiposPrestacion
		,tipoTrabajadorEmpleado
	FROM @dtHistorialEmpleado DI
	LEFT JOIN RH.tblEmpleadosMaster EM ON DI.ClaveEmpleado = EM.ClaveEmpleado

	INSERT @dtVigencias
	EXEC RH.spBuscarListaFechasVigenciaEmpleado @dtEmpleados = @dtEmpleados
		,@Fechas = @tempFechas
		,@IDUsuario = @IDUsuario


	INSERT INTO @dtDatosValidados(
		IDClasificacionCorporativaEmpleado
		,IDEmpleado
		,ClaveEmpleado
		,NombreCompleto
		,IDClasificacionCorporativa
		,Codigo
		,Descripcion
		,Vigencia
		,FechaIni
		,FechaFin
		)
	SELECT 
		isnull((SELECT TOP 1  ee.IDClasificacionCorporativaEmpleado 
					FROM [RH].[tblClasificacionCorporativaEmpleado] ee with(nolock) 
					WHERE ee.IDEmpleado = eM.IDEmpleado 
						and ee.IDClasificacionCorporativa = isnull((SELECT TOP 1 IDClasificacionCorporativa FROM RH.tblCatClasificacionesCorporativas with(nolock) where Codigo = hE.Descripcion),0)
						and ee.FechaIni = he.FechaIni
					),0) IDClasificacionCorporativaEmpleado
		,isnull(eM.IDEmpleado,0) IDEmpleado
		,hE.ClaveEmpleado
		,eM.NOMBRECOMPLETO
		,isnull((SELECT TOP 1 IDClasificacionCorporativa FROM RH.tblCatClasificacionesCorporativas with(nolock) where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) = hE.Descripcion OR Codigo = he.Descripcion),0) IDClasificacionCorporativa
		,isnull((SELECT TOP 1 Codigo FROM RH.tblCatClasificacionesCorporativas with(nolock) where JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) = hE.Descripcion OR Codigo = he.Descripcion),0) Codigo
		,isnull((SELECT TOP 1 ISNULL(JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') FROM RH.tblCatClasificacionesCorporativas with(nolock) WHERE ISNULL(JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') = hE.Descripcion OR Codigo = he.Descripcion),'') Descripcion
	    ,ISNULL((Select top 1 Vigente from @dtVigencias where IDEmpleado = em.IDEmpleado and Fecha = he.FechaIni),0)  Vigente
		,isnull(hE.FechaIni, (SELECT TOP 1 h.FechaIni FROM RH.[tblClasificacionCorporativaEmpleado] h WHERE h.IDEmpleado = eM.IDEmpleado)) FechaIni
		,isnull(hE.FechaFin,'9999-12-31') FechaFin
	FROM @dtHistorialEmpleado hE LEFT JOIN 
			[RH].[tblEmpleadosMaster] eM ON hE.ClaveEmpleado = eM.ClaveEmpleado
	ORDER BY hE.ClaveEmpleado, hE.FechaIni
	
	INSERT @dtDuplicados (
		IDEmpleado
		,Codigo
		,FechaIni
		,qty
		)
	SELECT t.*
	FROM @dtDatosValidados dv
	JOIN (
		SELECT 
			CAST(IDEmpleado as int) IDEmpleado
			,Codigo
			,FechaIni
			,count(*) AS qty
		FROM @dtDatosValidados
		GROUP BY IDEmpleado
			,Codigo
			,FechaIni
		HAVING count(*) > 1
		) t ON dv.IDEmpleado = t.IDEmpleado
		AND dv.Codigo = t.Codigo
		AND dv.FechaIni = t.FechaIni

	SELECT info.*
		,(
			SELECT m.[Message] AS Message
				,CAST(m.Valid AS BIT) AS Valid
			FROM @tempMessages m
			WHERE ID IN (
					SELECT ITEM
					FROM app.split(info.IDMensaje, ',')
					)
			FOR JSON PATH
			) AS Msg
		,CAST(CASE 
				WHEN EXISTS (
						(
							SELECT m.[Valid] AS Message
							FROM @tempMessages m
							WHERE ID IN (
									SELECT ITEM
									FROM app.split(info.IDMensaje, ',')
									)
								AND Valid = 0
							)
						)
					THEN 0
				ELSE 1
				END AS BIT) AS Valid
	FROM (
		SELECT 
			IDClasificacionCorporativaEmpleado
			,IDEmpleado
			,ClaveEmpleado
			,NombreCompleto
			,IDClasificacionCorporativa
			,Codigo
			,Descripcion
			,FechaIni
			,FechaFin
			,IDMensaje = 
			CASE WHEN IDEmpleado IS NULL OR IDEmpleado = 0 THEN '2,' ELSE '' END +
			CASE WHEN FechaIni IS NULL THEN '3,' ELSE '' END+
			CASE WHEN Vigencia = 0 THEN '4,' ELSE '' END+
			CASE WHEN (
					SELECT COUNT(*)
					FROM @dtDuplicados dtD
					WHERE dtD.IDEmpleado = dtV.IDEmpleado
						AND dtD.Codigo = dtV.Codigo
					) > 0 THEN '5,' ELSE '' END+
			CASE WHEN 
					NOT EXISTS (
					SELECT TOP 1 1
					FROM Seguridad.tblDetalleFiltrosEmpleadosUsuarios sE
					WHERE sE.IDEmpleado = dtV.IDEmpleado
						AND sE.IDusuario = @IDUsuario
					) THEN '6,' ELSE '' END+
			CASE WHEN IDClasificacionCorporativa = 0 THEN '7,' ELSE '' END+
			CASE WHEN IDClasificacionCorporativaEmpleado <> 0 THEN '8,' ELSE '' END
		FROM @dtDatosValidados dtV
		WHERE isnull(Codigo, '') <> ''
		) info
	ORDER BY info.IDEmpleado

END
GO

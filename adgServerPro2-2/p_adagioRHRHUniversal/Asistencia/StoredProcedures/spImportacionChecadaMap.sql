USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2023-02-14
-- Description:	Sp para realizar el Map de la importación másiva de los lectores ZK
-- =============================================
CREATE PROCEDURE [Asistencia].[spImportacionChecadaMap] (
	@dtChecadas [Asistencia].[dtZkChecadas] READONLY
	, @IDUsuario INT = NULL
	)
AS
BEGIN
	DECLARE @tempMessages AS TABLE (
		ID INT
		, [Message] VARCHAR(500)
		, Valid BIT
		);

	DECLARE @PermiteEntradasSinHorario BIT;
	DECLARE @tempTblEmpleados AS TABLE (IDEmpleado int);

	SET @PermiteEntradasSinHorario = isnull((SELECT TOP 1 [Valor] 
													FROM  [App].[tblConfiguracionesGenerales] 
													WHERE IDConfiguracion = 'ChecadaSinHorario'),0);
	
	INSERT INTO @tempMessages (
		ID
		, [Message]
		, Valid
		)
	SELECT [IDMensajeTipo]
		, [Mensaje]
		, [Valid]
	FROM [RH].[tblMensajesMap] WITH (NOLOCK)
	WHERE [MensajeTipo] = 'ImportacionLectoresZkMap'
	ORDER BY [IDMensajeTipo];

	DECLARE @dtDatosValidados TABLE (
		IDLector INT
		, IDEmpleado INT
		, ClaveEmpleado VARCHAR(255)
		, Fecha DATETIME
		, ExisteLector BIT
		, ExisteEmpleado BIT
		, ExisteLectorEmpleado BIT
		, Vigente BIT
		, Duplicado BIT
		, PermiteChecadasSinHorario BIT
		);

	DECLARE @dtChecadasTrabajo TABLE (
		IDLector INT
		, IDEmpleado INT
		, ClaveEmpleado VARCHAR(255)
		, Fecha DATETIME
		, FechaOrigen DATE
		, TipoChecada VARCHAR(10)
		, PermiteChecadasSinHorario BIT
		, LectorEmpleado BIT
		);

	INSERT INTO @dtChecadasTrabajo
	SELECT c.IDLector
		, isnull(m.IDEmpleado, 0)
		, isnull(m.ClaveEmpleado,'')
		, c.Fecha
		, v.FechaOrigen
		, v.TipoChecada
		, @PermiteEntradasSinHorario
		, (
			CASE 
				WHEN lE.IDLectorEmpleado IS NOT NULL
					THEN 1
				ELSE 0
				END
			)
	FROM @dtChecadas c
	CROSS APPLY [Asistencia].[fnValidaDiaOrigen](c.IDEmpleado, c.Fecha) v
	LEFT JOIN RH.tblEmpleadosMaster m WITH (NOLOCK) ON m.IDEmpleado = c.IDEmpleado
	LEFT JOIN [Asistencia].[tblLectoresEmpleados] lE ON lE.IDLector = c.IDLector
		AND lE.IDEmpleado = m.IDEmpleado
			   
	DECLARE @dtVigencias TABLE (
		IDEmpleado VARCHAR(255)
		, Fecha DATE
		, Vigente BIT
		);
	DECLARE @Fechas [App].[dtFechas]
		, @dtEmpleados [RH].[dtEmpleados]
		, @DiasPeriodo INT
		, @FechaInicio DATE
		, @FechaFin DATE
	DECLARE @tempFechas [App].[dtFechas]
	DECLARE @IDIdioma VARCHAR(225)
		
	SELECT @FechaInicio = MIN(FechaOrigen)
		, @FechaFin = MAX(FechaOrigen)
	FROM @dtChecadasTrabajo
	GROUP BY Fecha;
	
	INSERT @tempFechas
	EXEC [App].[spListaFechas] @FechaInicio
		, @FechaFin
		
		
	INSERT INTO @tempTblEmpleados (IDEmpleado)
	SELECT DISTINCT IDEmpleado FROM @dtChecadas;

	INSERT INTO @dtEmpleados
	SELECT DI.IDEmpleado
		,ClaveEmpleado
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
	FROM @tempTblEmpleados DI
	LEFT JOIN RH.tblEmpleadosMaster EM ON DI.IDEmpleado = EM.IDEmpleado
	
	INSERT @dtVigencias
	EXEC RH.spBuscarListaFechasVigenciaEmpleado @dtEmpleados = @dtEmpleados
		, @Fechas = @tempFechas
		, @IDUsuario = @IDUsuario
		
	INSERT INTO @dtDatosValidados (
		IDLector
		, IDEmpleado
		, ClaveEmpleado
		, Fecha
		, ExisteEmpleado
		, ExisteLectorEmpleado
		, Vigente
		, Duplicado
		, PermiteChecadasSinHorario
		)
	SELECT ctC.IDLector
		, ctC.IDEmpleado
		, ctC.ClaveEmpleado
		, ctC.Fecha
		, CASE 
			WHEN isnull(ctC.IDEmpleado, 0) > 0
				THEN 1
			ELSE 0
			END AS ExisteEmpleado
		, ISNULL(ctC.LectorEmpleado, 0) AS ExisteLectorEmpleado
		, ISNULL(v.Vigente, 0) AS Vigente
		, CASE 
			WHEN (
					ROW_NUMBER() OVER (
						PARTITION BY ctC.IDLector
						, ctC.IDEmpleado
						, ctC.Fecha ORDER BY ctC.Fecha ASC
						)
					) > 1
				THEN 1
			ELSE 0
			END AS Duplicado
		, CASE WHEN @PermiteEntradasSinHorario = 0  THEN 
			CASE WHEN ctC.TipoChecada = 'SH' THEN 0 ELSE 1 END
				ELSE 1 END
	FROM @dtChecadasTrabajo ctC
	LEFT JOIN @dtVigencias v ON ctC.IDEmpleado = v.IDEmpleado
		AND ctC.FechaOrigen = v.Fecha

	SELECT info.*
		, (
			SELECT m.[Message] AS Message
				, CAST(m.Valid AS BIT) AS Valid
			FROM @tempMessages m
			WHERE ID IN (
					SELECT ITEM
					FROM app.split(info.IDMensaje, ',')
					)
			FOR JSON PATH
			) AS Msg
		, CAST(CASE 
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
		SELECT dtV.IDLector
			, dtV.IDEmpleado
			, dtV.ClaveEmpleado
			, dtV.Fecha
			, @IDUsuario IDUsuario
			, IDMensaje = CONCAT (
				CASE 
					WHEN dtV.ExisteEmpleado = 0
						THEN '2,'
					ELSE ''
					END
				, CASE 
					WHEN dtV.Vigente = 0
						THEN '3,'
					ELSE ''
					END
				, CASE 
					WHEN dtV.IDLector = 0
						THEN '4,'
					ELSE ''
					END
				, CASE 
					WHEN dtV.Duplicado = 1
						THEN '5,'
					ELSE ''
					END
				, CASE 
					WHEN dtV.Fecha IS NULL
						THEN '6,'
					ELSE ''
					END
				, CASE
					WHEN dtV.PermiteChecadasSinHorario = 1 THEN '' ELSE ',7' END
				)
		FROM @dtDatosValidados dtV
		) info
	ORDER BY info.IDLector
		, info.IDEmpleado
END
GO

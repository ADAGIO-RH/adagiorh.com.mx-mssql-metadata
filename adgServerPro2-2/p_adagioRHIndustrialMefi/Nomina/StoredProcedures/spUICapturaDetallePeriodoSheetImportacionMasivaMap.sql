USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: SP para mapeo de importación masiva de nómina
** Autor			: Emmanuel Contreras
** Email			: econtreras@adagio.com.mx
** FechaCreacion	: 2023-01-25
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2023-11-01			ANEUDY ABREU		Corrige bug cambiando Campo Código de INT a VARCHAR 
										en las tablas @dtDatosValidados, @dtDuplicados y @TablaVariable
***************************************************************************************************/
CREATE PROCEDURE [Nomina].[spUICapturaDetallePeriodoSheetImportacionMasivaMap] 
	@DetallePeriodoCapturaImportacion [Nomina].[dtDetallePeriodoCapturaImportacionMap] READONLY
	, @IDPeriodo INT
	, @PermitirNoVigentes BIT
	, @IDUsuario INT
AS
BEGIN
	DECLARE 
		@Fechas [App].[dtFechas]
		, @dtEmpleados [RH].[dtEmpleados]
		, @DiasPeriodo INT
		, @tempFechas [App].[dtFechas]
		, @IDIdioma VARCHAR(225)
		, @FechaInicioPago DATE
		, @FechaFinPago DATE
		, @IDTipoNomina INT
	;

	DECLARE @tempMessages AS TABLE (
		ID INT
		, [Message] VARCHAR(500)
		, Valid BIT
	);
	DECLARE @dtVigencias TABLE (
		IDEmpleado VARCHAR(255)
		, Fecha DATE
		, Vigente BIT
	);
	DECLARE @dtDatosValidados TABLE (
		IDEmpleado INT
		, ClaveEmpleado VARCHAR(255)
		, NombreCompleto VARCHAR(255)
		, IDConcepto INT
		, Codigo varchar(20)
		, Descripcion VARCHAR(255)
		, CantidadMonto DECIMAL
		, CantidadDias DECIMAL
		, CantidadVeces DECIMAL
		, CantidadOtro1 DECIMAL
		, CantidadOtro2 DECIMAL
		, ImporteGravado DECIMAL
		, ImporteExcento DECIMAL
		, ImporteOtro DECIMAL
		, ImporteTotal1 DECIMAL
		, ImporteTotal2 DECIMAL
		, Vigencia BIT
	)
	DECLARE @dtDuplicados TABLE (
		ClaveEmpleado VARCHAR(255)
		, Codigo  varchar(20)
		, qty INT
	)
	
	DECLARE @TablaVariable TABLE (
		ID INT
		, IDEmpleado INT
		, ClaveEmpleado VARCHAR(255)
		, NombreCompleto VARCHAR(255)
		, Vigente BIT
		, IDConcepto  INT
		, Codigo VARCHAR(255)
		, Concepto VARCHAR(255)
		, CantidadMonto DECIMAL(18, 2)
		, CantidadDias DECIMAL(18, 2)
		, CantidadVeces DECIMAL(18, 2)
		, CantidadOtro1 DECIMAL(18, 2)
		, CantidadOtro2 DECIMAL(18, 2)
		, ImporteGravado DECIMAL(18, 2)
		, ImporteExcento DECIMAL(18, 2)
		, ImporteOtro DECIMAL(18, 2)
		, ImporteTotal1 DECIMAL(18, 2)
		, ImporteTotal2 DECIMAL(18, 2)
		, CantidadMontoValido BIT
		, CantidadDiasValido BIT
		, CantidadVecesValido BIT
		, CantidadOtro1Valido BIT
		, CantidadOtro2Valido BIT
		, TipoNominaValido BIT
	);

	SELECT top 1 
		@IDTipoNomina = IDTipoNomina
		,@FechaInicioPago = FechaInicioPago
		,@FechaFinPago = FechaFinPago
	FROM [Nomina].[tblCatPeriodos] WITH (NOLOCK)
	WHERE IDPeriodo = @IDPeriodo

	INSERT INTO @dtDuplicados (ClaveEmpleado, Codigo, qty)
	SELECT ClaveEmpleado, Codigo, COUNT(*)
	FROM @DetallePeriodoCapturaImportacion
	GROUP BY ClaveEmpleado, Codigo
	HAVING COUNT(*) > 1
	
	INSERT INTO @dtEmpleados
	SELECT DISTINCT EM.IDEmpleado
		, DI.ClaveEmpleado
		, RFC
		, CURP
		, IMSS
		, Nombre
		, SegundoNombre
		, Paterno
		, Materno
		, NOMBRECOMPLETO
		, IDLocalidadNacimiento
		, LocalidadNacimiento
		, IDMunicipioNacimiento
		, MunicipioNacimiento
		, IDEstadoNacimiento
		, EstadoNacimiento
		, IDPaisNacimiento
		, PaisNacimiento
		, FechaNacimiento
		, IDEstadoCiviL
		, EstadoCivil
		, Sexo
		, IDEscolaridad
		, Escolaridad
		, DescripcionEscolaridad
		, IDInstitucion
		, Institucion
		, IDProbatorio
		, Probatorio
		, FechaPrimerIngreso
		, FechaIngreso
		, FechaAntiguedad
		, Sindicalizado
		, IDJornadaLaboral
		, JornadaLaboral
		, UMF
		, CuentaContable
		, IDTipoRegimen
		, TipoRegimen
		, IDPreferencia
		, IDDepartamento
		, Departamento
		, IDSucursal
		, Sucursal
		, IDPuesto
		, Puesto
		, EM.IDCliente
		, Cliente
		, IDEmpresa
		, Empresa
		, IDCentroCosto
		, CentroCosto
		, IDArea
		, Area
		, IDDivision
		, Division
		, IDRegion
		, Region
		, IDClasificacionCorporativa
		, ClasificacionCorporativa
		, IDRegPatronal
		, RegPatronal
		, TipoNominaEmpleado.IDTipoNomina
		,UPPER(isnull(TN.Descripcion,'SIN TIPO DE NÓMINA')) as TipoNomina
		--, TipoNomina
		, SalarioDiario
		, SalarioDiarioReal
		, SalarioIntegrado
		, SalarioVariable
		, IDTipoPrestacion
		, IDRazonSocial
		, RazonSocial
		, IDAfore
		, Afore
		, Vigente
		, RowNumber
		, ClaveNombreCompleto
		, PermiteChecar
		, RequiereChecar
		, PagarTiempoExtra
		, PagarPrimaDominical
		, PagarDescansoLaborado
		, PagarFestivoLaborado
		, IDDocumento
		, Documento
		, IDTipoContrato
		, TipoContrato
		, FechaIniContrato
		, FechaFinContrato
		, TiposPrestacion
		, tipoTrabajadorEmpleado
	FROM @DetallePeriodoCapturaImportacion DI
		LEFT JOIN RH.tblEmpleadosMaster EM ON DI.ClaveEmpleado = EM.ClaveEmpleado
		LEFT JOIN [RH].[tblTipoNominaEmpleado] TipoNominaEmpleado WITH(NOLOCK) on EM.IDEmpleado = TipoNominaEmpleado.IDEmpleado 
			and TipoNominaEmpleado.FechaIni<= @FechaInicioPago and TipoNominaEmpleado.FechaFin >= @FechaFinPago
		LEFT JOIN Nomina.tblCatTipoNomina TN on TN.IDTipoNomina = TipoNominaEmpleado.IDTipoNomina 
	WHERE DI.ClaveEmpleado NOT IN (
		SELECT ClaveEmpleado
		FROM @dtEmpleados
	)

	INSERT @Fechas
	EXEC [App].[spListaFechas] @FechaInicioPago
		, @FechaFinPago

	INSERT @dtVigencias
	EXEC RH.spBuscarListaFechasVigenciaEmpleado @dtEmpleados
		, @Fechas
		, @IDUsuario;

	INSERT INTO @TablaVariable (
		ID
		, IDEmpleado
		, IDConcepto
		, ClaveEmpleado
		, NombreCompleto
		, Vigente
		, Codigo
		, Concepto
		, CantidadMonto
		, CantidadDias
		, CantidadVeces
		, CantidadOtro1
		, CantidadOtro2
		, ImporteGravado
		, ImporteExcento
		, ImporteOtro
		, ImporteTotal1
		, ImporteTotal2
		, CantidadMontoValido
		, CantidadDiasValido
		, CantidadVecesValido
		, CantidadOtro1Valido
		, CantidadOtro2Valido
		, TipoNominaValido
	)
	SELECT ROW_NUMBER() OVER (
			ORDER BY dtE.ClaveEmpleado
				, dPC.Codigo
			) AS ID
		, ISNULL(dtE.IDEmpleado, 0) IDEmpleado
		, ISNULL(cC.IDConcepto, 0) IDConcepto
		, dPC.ClaveEmpleado
		, dtE.NOMBRECOMPLETO
		, CASE 
			WHEN @PermitirNoVigentes = 1 
				THEN 1
				ELSE 
					(SELECT  CASE 
				WHEN SUM(CAST(Vigente as int)) > 0 -- para que si almenos un dia estuvo vigente si pase 
					THEN 1
					ELSE 0
				END
					FROM @dtVigencias
					WHERE IDEmpleado = dtE.IDEmpleado	
				)
			END
		, dPC.Codigo
		, cC.Descripcion
		, ISNULL(dPC.CantidadMonto, 0)
		, ISNULL(dPC.CantidadDias, 0)
		, ISNULL(dPC.CantidadVeces, 0)
		, ISNULL(dPC.CantidadOtro1, 0)
		, ISNULL(dPC.CantidadOtro2, 0)
		, ISNULL(dPC.ImporteGravado, 0)
		, ISNULL(dPC.ImporteExcento, 0)
		, ISNULL(dPC.ImporteOtro, 0)
		, ISNULL(dPC.ImporteTotal1, 0)
		, ISNULL(dPC.ImporteTotal2, 0)
		, CASE 
			WHEN cC.bCantidadMonto = 1
				THEN 0
			ELSE CASE 
					WHEN ISNULL(dPC.CantidadMonto, 0) > 0
						THEN 1
					ELSE 0
					END
			END AS CantidadMontoValido
		, CASE 
			WHEN cC.bCantidadDias = 1
				THEN 0
			ELSE CASE 
					WHEN ISNULL(dPC.CantidadDias, 0) > 0
						THEN 1
					ELSE 0
					END
			END AS CantidadDiasValido
		, CASE 
			WHEN cC.bCantidadVeces = 1
				THEN 0
			ELSE CASE 
					WHEN ISNULL(dPC.CantidadVeces, 0) > 0
						THEN 1
					ELSE 0
					END
			END AS CantidadVecesValido
		, CASE 
			WHEN cC.bCantidadOtro1 = 1
				THEN 0
			ELSE CASE 
					WHEN ISNULL(dPC.CantidadOtro1, 0) > 0
						THEN 1
					ELSE 0
					END
			END AS CantidadOtro1Valido
		, CASE 
			WHEN cC.bCantidadOtro2 = 1
				THEN 0
			ELSE CASE 
					WHEN ISNULL(dPC.CantidadOtro2, 0) > 0
						THEN 1
					ELSE 0
					END
			END AS CantidadOtro2Valido
		, CASE 
			WHEN @IDTipoNomina <> dtE.IDTipoNomina
				THEN 0
			ELSE 1
			END AS TipoNominaValido
	FROM @DetallePeriodoCapturaImportacion dPC
	LEFT JOIN @dtEmpleados dtE ON dPC.ClaveEmpleado = dtE.ClaveEmpleado
	LEFT JOIN Nomina.tblCatConceptos cC WITH (NOLOCK) ON dPC.Codigo = cC.Codigo;

	INSERT @tempMessages (
		ID
		, [Message]
		, Valid
		)
	SELECT [IDMensajeTipo]
		, [Mensaje]
		, [Valid]
	FROM [RH].[tblMensajesMap] WITH (NOLOCK)
	WHERE [MensajeTipo] = 'CapturaDetallePeriodoMap'
	ORDER BY [IDMensajeTipo];

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
		SELECT IDEmpleado
			, ClaveEmpleado
			, NombreCompleto
			, IDConcepto
			, Codigo
			, Concepto
			, CantidadMonto
			, CantidadDias
			, CantidadVeces
			, CantidadOtro1
			, CantidadOtro2
			, ImporteGravado
			, ImporteExcento
			, ImporteOtro
			, ImporteTotal1
			, ImporteTotal2
			, IDMensaje = 
				  CASE WHEN CantidadMontoValido = 1 THEN '2,' ELSE '' END 
				+ CASE WHEN CantidadDiasValido = 1 THEN '3,' ELSE '' END 
				+ CASE WHEN CantidadVecesValido = 1 THEN '4,' ELSE '' END 
				+ CASE WHEN CantidadOtro1Valido = 1 THEN '5,' ELSE '' END 
				+ CASE WHEN CantidadOtro2Valido = 1 THEN '6,' ELSE '' END 
				+ CASE WHEN ISNULL(ImporteGravado, 0) > 0 THEN '7,' ELSE '' END 
				+ CASE WHEN ISNULL(ImporteExcento, 0) > 0 THEN '8,' ELSE ''	END 
				+ CASE WHEN ISNULL(ImporteOtro, 0) > 0 THEN '9,' ELSE '' END 
				+ CASE WHEN ISNULL(ImporteTotal1, 0) > 0 THEN '10,' ELSE '' END 
				+ CASE WHEN ISNULL(ImporteTotal2, 0) > 0 THEN '11,' ELSE '' END 
				+ CASE WHEN IDEmpleado = 0 THEN '12,' ELSE '' END 
				+ CASE WHEN 
					EXISTS(SELECT qty FROM @dtDuplicados WHERE ClaveEmpleado = dtV.ClaveEmpleado AND Codigo = dtV.Codigo)
					THEN '13,' ELSE '' END
				+ CASE WHEN Vigente = 0 THEN '14,' ELSE '' END 
				+ IIF(EXISTS (
					SELECT TOP 1 1
					FROM Seguridad.tblDetalleFiltrosEmpleadosUsuarios sE
					WHERE sE.IDEmpleado = dtV.IDEmpleado
						AND sE.IDusuario = @IDUsuario
					), '', '15,')
				+ CASE WHEN IDConcepto = 0 THEN '16,' ELSE '' END
				+ CASE WHEN TipoNominaValido = 0 THEN '17,' ELSE '' END
		FROM @TablaVariable dtV
		WHERE ISNULL(ClaveEmpleado, '') <> ''
		) info
	ORDER BY info.ClaveEmpleado
END
GO

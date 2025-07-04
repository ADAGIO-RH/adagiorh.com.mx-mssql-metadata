USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2023-02-22
-- Description:	Sp para validar la importación de Movimientos 
--				Afiliatorios Map
-- =============================================
CREATE PROCEDURE [Nomina].[spMovimientosAfiliatoriosMap] (
							@dtMovimientosAfiliatorios [RH].[dtHistorialMovAfiliatorios] READONLY
							,@IDUsuario int
	)
AS
BEGIN
	DECLARE @dtMovimientosAfiliatoriosMap [RH].[dtHistorialMovAfiliatoriosMap];
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
	DECLARE @Fechas [App].[dtFechas]
		, @dtEmpleados [RH].[dtEmpleados]
		, @dtEmpleadosVigentes [RH].[dtEmpleados]
		, @DiasPeriodo INT
	DECLARE @tempFechas [App].[dtFechas]

	INSERT INTO @tempMessages (
		ID
		, [Message]
		, Valid
		)
	SELECT [IDMensajeTipo]
		, [Mensaje]
		, [Valid]
	FROM [RH].[tblMensajesMap]
	WHERE [MensajeTipo] = 'MovimientosAfiliatoriosMap'
	ORDER BY [IDMensajeTipo];

	DECLARE @dtHistorialMovimientosAfiliatoriosMap [RH].[dtHistorialMovAfiliatoriosMap];
	DECLARE @FechaIni DATE, @FechaFin DATE

	SET @FechaIni= (SELECT TOP 1 MAX(f.Fecha) FROM @dtMovimientosAfiliatorios f)
	SET @FechaFin = (SELECT TOP 1 MIN(f.Fecha) FROM @dtMovimientosAfiliatorios f)
		

	INSERT INTO @dtEmpleadosVigentes 
		EXEC [RH].[spBuscarEmpleados]
			 @IDUsuario=1
			,@FechaIni = @FechaIni
			,@Fechafin  = @FechaFin
			
	INSERT INTO @dtEmpleados
	SELECT 
		DISTINCT isnull(IDEmpleado, 0)
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
		, IDCliente
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
		, EM.RegPatronal
		, IDTipoNomina
		, TipoNomina
		, EM.SalarioDiario
		, EM.SalarioDiarioReal
		, EM.SalarioIntegrado
		, EM.SalarioVariable
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
	FROM @dtMovimientosAfiliatorios DI
	LEFT JOIN RH.tblEmpleadosMaster EM ON DI.ClaveEmpleado = EM.ClaveEmpleado
	   
	INSERT INTO @dtHistorialMovimientosAfiliatoriosMap(
			IDMovAfiliatorio 
			,Fecha 
			,IDEmpleado 
			,ClaveEmpleado 
			,IDTipoMovimiento 
			,Codigo 
			,Descripcion 
			,IDRazonMovimiento 
			,CodigoRazon
			,Razon 
			,SalarioDiario 
			,SalarioIntegrado 
			,SalarioVariable 
			,SalarioDiarioReal 
			,IDRegPatronal
			,RegPatronal
			,FechaIMSS
			,FechaIDSE
		)
	SELECT
		isnull(mov.IDMovAfiliatorio,0) IDMovimientoAfiliatorio 
		, MA.Fecha Fecha 
		, isnull(dE.IDEmpleado,0) IDEmpleado 
		, MA.ClaveEmpleado ClaveEmpleado 
		
		, isnull(CTM.IDTipoMovimiento, 0) IDTipoMovimiento 
		, CTM.Codigo Codigo 
		, CTM.Descripcion Descripcion 
		
		, isnull(RMA.IDRazonMovimiento, 0) IDRazonMovimiento 
		, RMA.Codigo CodigoRazon 
		, RMA.Descripcion Razon 
		
		, MA.SalarioDiario 
		, MA.SalarioIntegrado 
		, MA.SalarioVariable 
		, MA.SalarioDiarioReal 
		
		, isnull(cPE.IDRegPatronal, 0) IDRegPatronal
		, MA.RegPatronal

		, MA.FechaIMSS
		, MA.FechaIDSE
	FROM
		@dtMovimientosAfiliatorios MA 
		LEFT JOIN @dtEmpleados dE ON MA.ClaveEmpleado = dE.ClaveEmpleado
		LEFT JOIN IMSS.tblCatRazonesMovAfiliatorios RMA ON RMA.Codigo = MA.CodigoRazon
		LEFT JOIN IMSS.tblCatTipoMovimientos CTM ON CTM.Codigo = MA.Codigo
		LEFT JOIN RH.tblCatRegPatronal cPE ON cPE.RegistroPatronal = MA.RegPatronal
		left join IMSS.tblMovAfiliatorios mov with(nolock) 
			on mov.IDEmpleado = de.IDEmpleado
				and mov.Fecha = ma.Fecha
	

	--- Validación
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
		SELECT 
			  IDMovAfiliatorio
			, Fecha
			, dtV.IDEmpleado
			, dtV.ClaveEmpleado
			, IDTipoMovimiento
			, Codigo
			, Descripcion
			, IDRazonMovimiento
			, CodigoRazon
			, Razon
			, dtV.SalarioDiario
			, dtV.SalarioIntegrado
			, dtV.SalarioVariable
			, dtV.SalarioDiarioReal
			, dtV.IDRegPatronal
			, dtV.RegPatronal
			, FechaIMSS
			, FechaIDSE
			, IDMensaje = 
				CASE WHEN dtV.IDEmpleado = 0 THEN '2,' ELSE '' END  -- Error No existe el empleado
				+ CASE WHEN dtV.IDRegPatronal = 0 THEN '3,' ELSE '' END  -- Error No existe el registro patronal
				+ CASE WHEN dtV.IDTipoMovimiento = 0 THEN '4,' ELSE '' END -- Error No existe el tipo de movimiento
				+ CASE WHEN dtV.IDRazonMovimiento = 0 THEN '5,' ELSE '' END -- Error No existe la razón del movimiento
				+ CASE WHEN dtV.SalarioDiario is null THEN '6,' ELSE '' END  -- Warning se utilizará el SD anterior
				+ CASE WHEN dtV.SalarioIntegrado is null THEN '7,' ELSE '' END -- Warning se utilizará el SI anterior
				+ CASE WHEN dtV.SalarioVariable is null THEN '8,' ELSE ''	END -- Warning se utilizará el SV anterior
				+ CASE WHEN dtV.SalarioDiarioReal is null THEN '9,' ELSE '' END -- Warning se utilizará el SDR anterior
				+ CASE WHEN FechaIMSS is null THEN '10,' ELSE '' END -- Warning La FechaIMSS no puede quedar vacia
				+ CASE WHEN FechaIDSE is null THEN '11,' ELSE '' END -- Warning La FechaIDSE no puede quedar vacia
				+ CASE WHEN dtV.SalarioDiario = 0 THEN '12,' ELSE '' END -- Warning el SD quedará en 0.00
				+ CASE WHEN dtV.SalarioIntegrado = 0 THEN '13,' ELSE '' END -- Warning el SI quedará en 0.00
				+ CASE WHEN dtV.SalarioVariable = 0 THEN '14,' ELSE '' END --  Warning el SV quedará en 0.00
				+ CASE WHEN dtV.SalarioDiarioReal = 0 THEN '15,' ELSE '' END -- Warning el SDR quedará en 0.00
				+ CASE WHEN dtV.Fecha is null THEN '16,' ELSE '' END -- Error la fecha es requerida.
				+ CASE WHEN dtV.IDMovAfiliatorio <> 0 THEN '17,' ELSE '' END -- Error la fecha es requerida.
		FROM @dtHistorialMovimientosAfiliatoriosMap dtV
		LEFT JOIN @dtEmpleadosVigentes eV ON dtV.IDEmpleado = eV.IDEmpleado 
		WHERE ISNULL(dtV.ClaveEmpleado, '') <> ''
		) info
	ORDER BY info.ClaveEmpleado
END
GO

USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [RH].[spIUImportacionEmpleadosMap] (
	@dtEmpleados [RH].[dtEmpleadosImportacionMap] READONLY
	,@IDUsuario INT
	)
AS
BEGIN
	--DECLARE @dtEmpleados [RH].[dtEmpleadosImportacionMap]
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
	WHERE [MensajeTipo] = 'ImportacionEmpleadosMap'
	ORDER BY [IDMensajeTipo];

	--insert @tempMessages(ID, [Message], Valid)
	--values
	--	(1, 'Datos correctos', 1),
	--	(2, 'El Nombre del Cliente no Existe', 0),
	--	(3, 'El Tipo de nomina del Cliente no Existe', 0),
	--	(4, 'El Primer Nombre del colaboradore es necesario', 0),
	--	(5, 'El Apellido Paterno del colaboradore es necesario', 0),
	--	(6, 'El Pais de Nacimiento no Existe', 0),
	--	(7, 'El Estado de Nacimiento no Existe', 0),
	--	(8, 'El Municipio de Nacimiento no Existe', 0),
	--	(9, 'La Fecha de Nacimiento es necesaria', 0),
	--	(10, 'La Fecha de Nacimiento es necesaria', 0),
	--	(11, 'El Sexo del colaborador es necesaria', 0),
	--	(12, 'El Estado Civil del colaborador es necesaria', 0),
	--	(13, 'La Fecha de Antiguedad del colaborador es necesaria', 0),
	--	(14, 'La Fecha de Ingreso del colaborador es necesaria', 0),
	--	(15, 'El tipo de Prestación del colaborador es necesaria', 0),
	--	(16, 'La Razón Social del colaborador es necesaria', 0),
	--	(17, 'El Registro Patronal del colaborador es necesaria', 0),
	--	(18, 'El Salario Diario del colaborador es necesaria', 0),
	--	(19, 'El Salario Integrado del colaborador es necesaria', 0),
	--	(20, 'El Email del colaborador es necesaria', 1),
	--	(21, 'El Departamento del colaborador no coincide', 1),
	--	(22, 'La Sucursal del colaborador no coincide', 1),
	--	(23, 'El Puesto del colaborador no coincide', 1),
	--	(24, 'El Centro de Costo del colaborador no coincide', 1),
	--	(25, 'El Area del colaborador no coincide', 1),
	--	(26, 'La Región del colaborador no coincide', 1),
	--	(27, 'La División del colaborador no coincide', 1),
	--	(28, 'La Clasificación Corporativa del colaborador no coincide', 1),
	--	(29, 'La Dirección del colaborador no coincide', 1),
	--	(30, 'La Escolaridad del colaborador no coincide', 1),
	--	(31, 'La Institución del colaborador no coincide', 1),
	--	(32, 'El Tipo de Regimen Fiscal del colaborador no coincide', 1),
	--	(33, 'La Clave del Colaborador Existe', 0)
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
		SELECT isnull((
					SELECT TOP 1 IDEmpleado
					FROM RH.tblEmpleados
					WHERE ClaveEmpleado = E.[ClaveEmpleado]
					), 0) AS [IDEmpleado]
			,E.[ClaveEmpleado]
			,(
				SELECT TOP 1 IDCliente
					,JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-', '')), 'NombreComercial')) AS Descripcion
				FROM RH.tblCatClientes c WITH (NOLOCK)
				WHERE c.NombreComercial = E.[Cliente]
				FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER
				) AS [clienteEmpleado]
			,(
				SELECT TOP 1 tn.IDTipoNomina
					,tn.Descripcion AS Descripcion
				FROM RH.tblCatClientes c WITH (NOLOCK)
				INNER JOIN Nomina.tblCatTipoNomina tn WITH (NOLOCK) ON c.IDCliente = tn.IDCliente
				WHERE c.NombreComercial = E.[Cliente]
					AND tn.Descripcion = E.[TipoNomina]
				FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER
				) AS [tipoNominaEmpleado]
			,E.[Nombre]
			,E.[SegundoNombre]
			,E.[Paterno]
			,E.[Materno]
			,E.[RFC]
			,E.[CURP]
			,E.[IMSS]
			,isnull((
					SELECT TOP 1 IDPais
					FROM SAT.tblCatPaises
					WHERE Descripcion LIKE '%' + E.[PaisNacimiento] + '%'
					), 0) AS [IDPaisNacimiento]
			,isnull((
					SELECT TOP 1 IDEstado
					FROM SAT.tblCatEstados
					WHERE NombreEstado LIKE '%' + E.[EstadoNacimiento] + '%'
					), 0) AS [IDEstadoNacimiento]
			,isnull((
					SELECT TOP 1 IDMunicipio
					FROM SAT.tblCatMunicipios
					WHERE Descripcion LIKE '%' + E.[MunicipioNacimiento] + '%'
					), 0) AS [IDMunicipioNacimiento]
			,cast(isnull(E.[FechaNacimiento], '9999-12-31') AS DATE) AS [FechaNacimiento]
			,E.[Sexo]
			,isnull((
					SELECT TOP 1 IDEstadoCivil
					FROM RH.tblCatEstadosCiviles
					WHERE Descripcion LIKE '%' + E.[EstadoCivil] + '%'
					), 0) AS [IDEstadoCivil]
			,cast(E.[FechaAntiguedad] AS DATE) AS [FechaAntiguedad]
			,cast(E.[FechaIngreso] AS DATE) AS [FechaIngreso]
			,(
				SELECT TOP 1 IDTipoPrestacion
					,Descripcion
				FROM RH.tblCatTiposPrestaciones WITH (NOLOCK)
				WHERE Descripcion = E.[TipoPrestacion]
				FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER
				) AS [prestacionEmpleado]
			,(
				SELECT TOP 1 IDEmpresa
					,NombreComercial
				FROM RH.tblEmpresa WITH (NOLOCK)
				WHERE NombreComercial = E.[RazonSocial]
				FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER
				) AS [empresaEmpleado]
			,(
				SELECT TOP 1 IDRegPatronal
					,RazonSocial
				FROM RH.tblCatRegPatronal WITH (NOLOCK)
				WHERE RegistroPatronal = E.[RegistroPatronal]
				FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER
				) AS [registroPatronalEmpleado]
			,(
				SELECT TOP 1 IDDepartamento
					,Descripcion
				FROM RH.tblCatDepartamentos WITH (NOLOCK)
				WHERE Descripcion = E.[Departamento]
				FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER
				) AS [departamentoEmpleado]
			,(
				SELECT TOP 1 IDSucursal
					,Descripcion
				FROM RH.tblCatSucursales WITH (NOLOCK)
				WHERE Descripcion = E.[Sucursal]
				FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER
				) AS [sucursalEmpleado]
			,(
				SELECT TOP 1 IDPuesto
					,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-', '')), 'Descripcion')) AS Descripcion
				FROM RH.tblCatPuestos WITH (NOLOCK)
				WHERE JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-', '')), 'Descripcion')) = e.[Puesto]
				FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER
				) AS [puestoEmpleado]
			,(
				SELECT TOP 1 IDCentroCosto
					,Descripcion
				FROM RH.tblCatCentroCosto WITH (NOLOCK)
				WHERE Descripcion = E.[CentroCosto]
				FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER
				) AS [centroCostoEmpleado]
			,(
				SELECT TOP 1 IDArea
					,Descripcion
				FROM RH.tblCatArea WITH (NOLOCK)
				WHERE Descripcion = E.[Area]
				FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER
				) AS [areaEmpleado]
			,(
				SELECT TOP 1 IDRegion
					,Descripcion
				FROM RH.tblCatRegiones WITH (NOLOCK)
				WHERE Descripcion = E.[Region]
				FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER
				) AS [regionEmpleado]
			,(
				SELECT TOP 1 IDDivision
					,Descripcion
				FROM RH.tblCatDivisiones WITH (NOLOCK)
				WHERE Descripcion = E.[Division]
				FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER
				) AS [divisionEmpleado]
			,(
				SELECT TOP 1 IDClasificacionCorporativa
					,Descripcion
				FROM RH.tblCatClasificacionesCorporativas WITH (NOLOCK)
				WHERE Descripcion = E.[ClasificacionCorporativa]
				FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER
				) AS [clasificacionCorporativaEmpleado]
			,(
				SELECT TOP 1 IDTipoJornada AS IDJornada
					,Descripcion
				FROM SAT.tblCatTiposJornada WITH (NOLOCK)
				WHERE Descripcion = E.[JornadaLaboral]
				FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER
				) AS [jornadaEmpleado]
			,(
				SELECT isnull((
							SELECT TOP 1 IDTipoTrabajador
							FROM IMSS.tblCatTipoTrabajador
							WHERE Descripcion = E.[TipoTrabajadorSua]
							), 0) AS IDTipoTrabajador
					,ISNULL((
							SELECT TOP 1 IDTipoContrato
							FROM sat.tblCatTiposContrato
							WHERE Descripcion = E.TipoContratoSat
							), 0) AS IDTipoContrato
				FOR json PATH
					,WITHOUT_ARRAY_WRAPPER
				) AS [tipoTrabajadorEmpleado]
			,(
				SELECT isnull((
							SELECT TOP 1 IDLayoutPago
							FROM nomina.tbllayoutpago
							WHERE Descripcion = E.[LayoutPago]
							), 0) AS IDLayoutPago
					,isnull((
							SELECT TOP 1 IDBanco
							FROM SAT.tblCatBancos
							WHERE Descripcion = E.[Banco]
							), 0) AS IDBanco
					,e.[Banco]
					,e.[ClaveInterbancaria] AS [Interbancaria]
					,e.[NumeroCuenta] AS [Cuenta]
					,e.[NumeroTarjeta] AS [Tarjeta]
					,e.[IDBancario] AS [IDBancario]
					,e.[SucursalBancaria] AS [Sucursal]
				FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER
				) AS [pagoEmpleado]
			,(
				SELECT E.[FechaAntiguedad] AS Fecha
					,1 AS IDTipoMovimiento
					,E.[SalarioDiario]
					,E.[SalarioVariable]
					,E.[SalarioIntegrado]
					,E.[SalarioDiarioReal]
				FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER
				) AS [movAfiliatorio]
			,(
				SELECT TOP 1 isnull(cp.IDCodigoPostal, 0) IDCodigoPostal
					,ISNULL(cp.CodigoPostal, E.[DireccionCodigoPostal]) AS CodigoPostal
					,isnull(est.IDEstado, 0) IDEstado
					,isnull(est.NombreEstado, E.[DireccionEstado]) AS Estado
					,isnull(muni.IDMunicipio, 0) IDMunicipio
					,isnull(muni.Descripcion, E.[DireccionMunicipio]) Municipio
					,isnull(c.IDColonia, 0) IDColonia
					,isnull(c.NombreAsentamiento, E.DireccionColonia) Colonia
					,isnull(p.IDPais, 0) IDPais
					,isnull(p.Descripcion, '') Pais
					,e.[DireccionCalle] AS Calle
					,e.[DireccionInt] AS Interior
					,e.[DireccionExt] AS Exterior
				FROM SAT.tblCatPaises p WITH (NOLOCK)
				INNER JOIN Sat.tblCatEstados est WITH (NOLOCK) ON p.IDPais = est.IDPais
					AND est.NombreEstado = E.[DireccionEstado]
				LEFT JOIN Sat.tblcatMunicipios muni WITH (NOLOCK) ON muni.IDEstado = est.IDEstado
					AND muni.Descripcion = E.[DireccionMunicipio]
				LEFT JOIN SAT.tblcatLocalidades l WITH (NOLOCK) ON l.IDEstado = est.IDEstado
				LEFT JOIN Sat.tblcatCodigosPostales cp ON cp.IDEstado = est.IDEstado
					AND cp.IDMunicipio = muni.IDMunicipio
					AND cp.CodigoPostal = E.[DireccionCodigoPostal]
				LEFT JOIN Sat.tblcatColonias c ON c.IDCodigoPostal = cp.IDCodigoPostal
					AND c.NombreAsentamiento = E.DireccionColonia
				FOR JSON PATH
					,WITHOUT_ARRAY_WRAPPER
				) AS [direccionEmpleado]
			,isnull((
					SELECT TOP 1 IDEstudio
					FROM STPS.tblCatEstudios
					WHERE Descripcion LIKE '%' + E.[Escolaridad] + '%'
					), 0) AS [IDEscolaridad]
			,E.[DescripcionEscolaridad]
			,isnull((
					SELECT TOP 1 IDInstitucion
					FROM STPS.tblCatInstituciones
					WHERE Descripcion LIKE '%' + E.[InstitucionEscolaridad] + '%'
					), 0) AS [IDInstitucion]
			,isnull((
					SELECT TOP 1 IDProbatorio
					FROM STPS.tblCatProbatorios
					WHERE Descripcion LIKE '%' + E.[DocumentoProbatorioEscolaridad] + '%'
					), 0) AS [IDProbatorio]
			,CAST(CASE 
					WHEN E.[Sindicalizado] = 'SI'
						THEN 1
					ELSE 0
					END AS BIT) AS [Sindicalizado]
			,E.[UMF]
			,E.[CuentaContable]
			,isnull((
					SELECT TOP 1 IDTipoRegimen
					FROM SAT.tblCatTiposRegimen
					WHERE Descripcion = E.[TipoRegimenFiscal]
					), 0) AS [IDTipoRegimen]
			,isnull((
					SELECT TOP 1 IDRegimenFiscal
					FROM SAT.tblCatRegimenesFiscales
					WHERE Descripcion = E.[RegimenFiscal]
					), 0) AS [IDRegimenFiscal]
			,(
				SELECT cc.IDTipoContactoEmpleado
					,cc.value
				FROM (
					SELECT TOP 1 IDTipoContacto AS IDTipoContactoEmpleado
						,E.[Email] AS [Value]
					FROM RH.tblCatTipoContactoEmpleado WITH (NOLOCK)
					WHERE JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-', '')), 'Descripcion')) = 'EMAIL'
					
					UNION
					
					SELECT TOP 1 IDTipoContacto AS IDTipoContactoEmpleado
						,E.[TelefonoFijo] AS [Value]
					FROM RH.tblCatTipoContactoEmpleado WITH (NOLOCK)
					WHERE JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-', '')), 'Descripcion')) = 'TELEFONO CASA'
					
					UNION
					
					SELECT TOP 1 IDTipoContacto AS IDTipoContactoEmpleado
						,E.[Celular] AS [Value]
					FROM RH.tblCatTipoContactoEmpleado WITH (NOLOCK)
					WHERE JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-', '')), 'Descripcion')) = 'TELÉFONO MOVIL'
					) cc
				FOR JSON PATH
				) AS [contactoEmpleado]
			,E.Email
			,IDMensaje = CASE 
				WHEN isnull((
							SELECT TOP 1 IDEmpleado
							FROM RH.tblEmpleados
							WHERE ClaveEmpleado = E.[ClaveEmpleado]
							), 0) <> 0
					THEN '33,'
				ELSE ''
				END + CASE 
				WHEN isnull((
							SELECT IDCliente
							FROM RH.tblCatClientes WITH (NOLOCK)
							WHERE NombreComercial = E.[Cliente]
							), 0) = 0
					THEN '2,'
				ELSE ''
				END + CASE 
				WHEN isnull((
							SELECT tn.IDTipoNomina
							FROM RH.tblCatClientes c WITH (NOLOCK)
							INNER JOIN Nomina.tblCatTipoNomina tn WITH (NOLOCK) ON c.IDCliente = tn.IDCliente
							WHERE c.NombreComercial = E.[Cliente]
								AND tn.Descripcion = E.[TipoNomina]
							), 0) = 0
					THEN '3,'
				ELSE ''
				END + CASE 
				WHEN isnull(E.[Nombre], '') = ''
					THEN '4,'
				ELSE ''
				END + CASE 
				WHEN isnull(E.[Paterno], '') = ''
					THEN '5,'
				ELSE ''
				END + CASE 
				WHEN isnull((
							SELECT TOP 1 IDPais
							FROM SAT.tblCatPaises
							WHERE Descripcion LIKE '%' + E.[PaisNacimiento] + '%'
							), 0) = 0
					THEN '6,'
				ELSE ''
				END + CASE 
				WHEN isnull((
							SELECT TOP 1 IDEstado
							FROM SAT.tblCatEstados
							WHERE NombreEstado LIKE '%' + E.[EstadoNacimiento] + '%'
							), 0) = 0
					THEN '7,'
				ELSE ''
				END + CASE 
				WHEN isnull((
							SELECT TOP 1 IDMunicipio
							FROM SAT.tblCatMunicipios
							WHERE Descripcion LIKE '%' + E.[MunicipioNacimiento] + '%'
							), 0) = 0
					THEN '8,'
				ELSE ''
				END + CASE 
				WHEN isnull(E.[FechaNacimiento], '9999-12-31') = '9999-12-31'
					THEN '9,'
				ELSE ''
				END + CASE 
				WHEN isnull(E.[Sexo], '') = ''
					THEN '11,'
				ELSE ''
				END + CASE 
				WHEN isnull((
							SELECT TOP 1 IDEstadoCivil
							FROM RH.tblCatEstadosCiviles
							WHERE Descripcion LIKE '%' + E.[EstadoCivil] + '%'
							), 0) = 0
					THEN '12,'
				ELSE ''
				END + CASE 
				WHEN isnull(E.[FechaAntiguedad], '9999-12-31') = '9999-12-31'
					THEN '13,'
				ELSE ''
				END + CASE 
				WHEN isnull(E.[FechaIngreso], '9999-12-31') = '9999-12-31'
					THEN '14,'
				ELSE ''
				END + CASE 
				WHEN isnull((
							SELECT TOP 1 IDTipoPrestacion
							FROM RH.tblCatTiposPrestaciones WITH (NOLOCK)
							WHERE Descripcion = E.[TipoPrestacion]
							), 0) = 0
					THEN '15,'
				ELSE ''
				END + CASE 
				WHEN isnull((
							SELECT TOP 1 IDEmpresa
							FROM RH.tblEmpresa WITH (NOLOCK)
							WHERE NombreComercial = E.[RazonSocial]
							), 0) = 0
					THEN '16,'
				ELSE ''
				END + CASE 
				WHEN isnull((
							SELECT TOP 1 IDRegPatronal
							FROM RH.tblCatRegPatronal WITH (NOLOCK)
							WHERE RegistroPatronal = E.[RegistroPatronal]
							), 0) = 0
					THEN '17,'
				ELSE ''
				END + CASE 
				WHEN isnull((
							SELECT TOP 1 IDDepartamento
							FROM RH.tblCatDepartamentos WITH (NOLOCK)
							WHERE Descripcion = E.[Departamento]
							), 0) = 0
					THEN '21,'
				ELSE ''
				END + CASE 
				WHEN isnull(E.[SalarioDiario], 0) = 0
					THEN '18,'
				ELSE ''
				END + CASE 
				WHEN isnull(E.[SalarioIntegrado], 0) = 0
					THEN '19,'
				ELSE ''
				END + CASE 
				WHEN isnull(E.[Email], '') = ''
					THEN '20,'
				ELSE ''
				END + CASE 
				WHEN isnull((
							SELECT TOP 1 IDSucursal
							FROM RH.tblCatSucursales WITH (NOLOCK)
							WHERE Descripcion = E.[Sucursal]
							), 0) = 0
					THEN '22,'
				ELSE ''
				END + CASE 
				WHEN isnull((
							SELECT TOP 1 IDPuesto
							FROM RH.tblCatPuestos WITH (NOLOCK)
							WHERE JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-', '')), 'Descripcion')) = E.[Puesto]
							), 0) = 0
					THEN '23,'
				ELSE ''
				END + CASE 
				WHEN isnull((
							SELECT TOP 1 IDCentroCosto
							FROM RH.tblCatCentroCosto WITH (NOLOCK)
							WHERE Descripcion = E.[CentroCosto]
							), 0) = 0
					THEN '24,'
				ELSE ''
				END + CASE 
				WHEN isnull((
							SELECT TOP 1 IDArea
							FROM RH.tblCatArea WITH (NOLOCK)
							WHERE Descripcion = E.[Area]
							), 0) = 0
					THEN '25,'
				ELSE ''
				END + CASE 
				WHEN isnull((
							SELECT TOP 1 IDRegion
							FROM RH.tblCatRegiones WITH (NOLOCK)
							WHERE Descripcion = E.[Region]
							), 0) = 0
					THEN '26,'
				ELSE ''
				END + CASE 
				WHEN isnull((
							SELECT TOP 1 IDDivision
							FROM RH.tblCatDivisiones WITH (NOLOCK)
							WHERE Descripcion = E.[Division]
							), 0) = 0
					THEN '27,'
				ELSE ''
				END + CASE 
				WHEN isnull((
							SELECT TOP 1 IDClasificacionCorporativa
							FROM RH.tblCatClasificacionesCorporativas WITH (NOLOCK)
							WHERE Descripcion = E.[ClasificacionCorporativa]
							), 0) = 0
					THEN '28,'
				ELSE ''
				END
		FROM @dtEmpleados E
		WHERE isnull(E.Nombre, '') <> ''
		) info
	ORDER BY info.ClaveEmpleado
END
GO

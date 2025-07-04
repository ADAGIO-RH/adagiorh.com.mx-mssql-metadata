USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Descripción		: Valida importación masiva sobre sucursales
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-08-09
** Paremetros		: @dtSucursales		Lista de sucursales.
					: @IDUsuario		Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [RH].[spValidarImportacionSucursales]
(
	@dtSucursales [RH].[dtImportacionSucursales] READONLY
	, @IDUsuario INT
)
AS
	BEGIN
		
		-- VARIABLES
		DECLARE @IDIdioma VARCHAR(225)
				, @NO	  BIT = 0
				;
		
		DECLARE @tempMessages AS TABLE(
			ID INT
			, [Message] VARCHAR(500)
			, Valid BIT
		)

		DECLARE @dtSucursalesAux AS TABLE(
			[IDSucursal] [int] NULL,
			[Codigo] [varchar](20) NULL,
			[Descripcion] [varchar](50) NULL,
			[CodigoPostal] [varchar](50) NULL,
			[Colonia] [varchar](MAX) NULL,
			[Calle] [varchar](100) NULL,
			[Exterior] [varchar](20) NULL,
			[Interior] [varchar](20) NULL,
			[IDMunicipio] [int] NULL,
			[IDEstado] [int] NULL,
			[IDPais] [int] NULL,
			[CuentaContable] [varchar](20) NULL,
			[Telefono] [varchar](20) NULL,
			[Responsable] [varchar](100) NULL,
			[Email] [varchar](100) NULL,
			[ClaveEstablecimiento] [varchar](50) NULL,
			[CodigoEstadoSTPS] [varchar](5) NULL,
			[CodigoMunicipioSTPS] [varchar](5) NULL,
			[Latitud] [float] NULL,
			[Longitud] [float] NULL,
			[Fronterizo] [bit] NULL,
			[IDItem] [int]
		)
		
		-- DETECCION DE IDIOMA
		SELECT @IDIdioma = LOWER(REPLACE([APP].[fnGetPreferencia]('Idioma', @IDUsuario, 'esmx'), '-', ''))
		
		
		-- OBTENEMOS MSJs QUE PERTENECEN A SUCURSALES
		INSERT @tempMessages(ID, [Message], Valid)
		SELECT [IDMensajeTipo]
				, [Mensaje]
				, [Valid]
        FROM [RH].[tblMensajesMap]
        WHERE [MensajeTipo] = 'ImportacionSucursalesMap'
        ORDER BY [IDMensajeTipo];


		/* -------------------------------------------------------------------------------------------------------------------------- */


		-- AGREGAMOS LA COLUMNA DE IDItem
		INSERT INTO @dtSucursalesAux
		SELECT *
				, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS IDItem
		FROM @dtSucursales
		--SELECT * FROM @dtSucursalesAux

		
		/* -------------------------------------------------------------------------------------------------------------------------- */


		/*
			OBTENEMOS PRE-RESULTADO PARA SUCURSALES "CON COLONIA"
			Validaciones:
				1.- Obtenemos el IDSucursal si no existe regresamos '0'.

				** CodigoPostal **
				2.- Si CodigoPostal, Colonia, CodigoEstadoSTPS y CodigoMunicipioSTPS viene vacio o null regresamos '-1'.
				3.- Obtenemos el IDCodigoPostal, IDColonia, IDEstadoSTPS y IDMunicipioSTPS si no existe regresamos '0'.
				4.- Valida que la colonia tenga el CodigoPostal '-2'
		*/
		SELECT -- VALIDACION 1
				ISNULL((
					SELECT S.IDSucursal
					FROM [RH].[tblCatSucursales] S
					WHERE S.Codigo = TD.Codigo
				), 0) AS IDSucursal
				, TD.Codigo
				, TD.Descripcion
				
				, CASE
					/* VALIDACION 2 */ WHEN ISNULL(TD.CodigoPostal, '') = '' THEN -1
					/* VALIDACION 3 */ ELSE ISNULL(CP.IDCodigoPostal, 0) END
				  AS IDCodigoPostal
				, TD.CodigoPostal

				, ISNULL(ES.IDEstado, -1) AS IDEstado
				, ES.NombreEstado AS Estado
				, ISNULL(MU.IDMunicipio, -1) AS IDMunicipio
				, MU.Descripcion AS Municipio
				
				, CASE
					/* VALIDACION 2 */ WHEN ISNULL(TD.Colonia, '') = '' THEN -1
					/* VALIDACION 4 */ WHEN ISNULL(TD.CodigoPostal, '') = '' AND ISNULL(TD.Colonia, '') <> '' THEN -2
					/* VALIDACION 3 */ ELSE ISNULL(CO.IDColonia, 0) END
				  AS IDColonia
				
				, CO.NombreAsentamiento AS Colonia
				, ISNULL(PA.IDPais, -1) AS IDPais
				, PA.Descripcion AS Pais
				, TD.Calle
				, TD.Exterior
				, TD.Interior
				, TD.CuentaContable
				, TD.Telefono
				, TD.Responsable
				, TD.Email
				, TD.ClaveEstablecimiento

				, CASE
					/* VALIDACION 2 */ WHEN ISNULL(TD.CodigoEstadoSTPS, '') = '' THEN -1
					/* VALIDACION 3 */ ELSE ISNULL(STPS.IDEstadoSTPS, 0) END
				  AS IDEstadoSTPS
				, STPS.CodigoEstadoSTPS
				, STPS.EstadoSTPS

				, CASE
					/* VALIDACION 2 */ WHEN ISNULL(TD.CodigoMunicipioSTPS, '') = '' THEN -1
					/* VALIDACION 3 */ ELSE ISNULL(STPS.IDMunicipioSTPS, 0) END
				  AS IDMunicipioSTPS
				, STPS.CodigoMunicipioSTPS
				, STPS.MunicipioSTPS

				, TD.Latitud
				, TD.Longitud
				, TD.Fronterizo
				, TD.IDItem
				, ROW_NUMBER() OVER (ORDER BY (SELECT TD.IDItem)) AS IDTemp
		INTO #dtInformacionRecolectada
		FROM @dtSucursalesAux TD
			LEFT JOIN SAT.tblCatCodigosPostales CP ON TD.CodigoPostal = CP.CodigoPostal
			LEFT JOIN SAT.tblCatEstados ES ON CP.IDEstado = ES.IDEstado
			LEFT JOIN SAT.tblCatMunicipios MU ON CP.IDMunicipio = MU.IDMunicipio
			LEFT JOIN SAT.tblCatColonias CO ON CP.IDCodigoPostal = CO.IDCodigoPostal
			LEFT JOIN SAT.tblCatPaises PA ON ES.IDPais = PA.IDPais
			LEFT JOIN (SELECT E.IDEstado AS IDEstadoSTPS
								, E.Codigo AS CodigoEstadoSTPS
								, E.Descripcion AS EstadoSTPS
								, M.IDMunicipio as IDMunicipioSTPS
								, M.Codigo AS CodigoMunicipioSTPS
								, M.Descripcion AS MunicipioSTPS
						FROM STPS.tblCatEstados E
							JOIN STPS.TblCatMunicipios M ON E.IDEstado = M.IDEstado) STPS ON TD.CodigoEstadoSTPS = STPS.CodigoEstadoSTPS AND TD.CodigoMunicipioSTPS = STPS.CodigoMunicipioSTPS
		--SELECT * FROM #dtInformacionRecolectada ORDER BY IDTemp
		

		/* -------------------------------------------------------------------------------------------------------------------------- */


		-- IDENTIFICAMOS LOS POSIBLES CASOS
		--**
		-- CASO 1: NO SE COLOCO CODIGO POSTAL NI COLONIA
		SELECT *
		INTO #dtAdvertencias
		FROM #dtInformacionRecolectada
		WHERE IDCodigoPostal = -1
				AND IDColonia = -1

				

		-- CASO 2: SE COLOCO CODIGO POSTAL Y COLONIA
		--**			
		-- UNIFICAMOS LAS COLONIAS QUE INGRESO EL USUARIO, ESTO PORQUE HAY CODIGOS POSTALES QUE TIENEN 2 O MAS DESCRIPCIONES DE COLONIAS IGUALES EJE. 01130
		SELECT *
		INTO #dtRevisionAux
		FROM (
				SELECT IR.*
						, SA.CodigoPostal AS CodigoPostalConf
						, SA.Colonia AS ColoniaConf
						, SA.Codigo AS CodigoConf
						, SA.IDItem AS IDItemConf
						, ROW_NUMBER() OVER (PARTITION BY SA.Codigo, SA.CodigoPostal, SA.Colonia, SA.IDItem ORDER BY IDTemp) RN
				FROM @dtSucursalesAux SA
					LEFT JOIN #dtInformacionRecolectada IR ON SA.Codigo = IR.Codigo AND SA.Descripcion = IR.Descripcion AND SA.CodigoPostal = IR.CodigoPostal AND REPLACE(SA.Colonia, ' ', '') = REPLACE(IR.Colonia, ' ', '') AND SA.IDItem = IR.IDItem
				WHERE ISNULL(SA.CodigoPostal, '') <> ''
						AND REPLACE(ISNULL(SA.Colonia, ''), ' ', '') <> ''
			 ) INFO
		WHERE INFO.RN = 1
		--SELECT * FROM #dtRevisionAux
		--RETURN
		

		--** RESULTADO DE CONSULTAS ANIDADAS
		-- IDENTIFICAMOS LAS COLONIAS QUE SI EXISTEN
		SELECT * 
		INTO #dtRevision
		FROM (
		SELECT INFO.IDSucursal
				, INFO.Codigo
				, INFO.Descripcion
				, INFO.IDCodigoPostal
				, INFO.CodigoPostal
				, INFO.IDEstado
				, INFO.Estado
				, INFO.IDMunicipio
				, INFO.Municipio
				, INFO.IDColonia
				, INFO.Colonia
				, INFO.IDPais
				, INFO.Pais
				, INFO.Calle
				, INFO.Exterior
				, INFO.Interior
				, INFO.CuentaContable
				, INFO.Telefono
				, INFO.Responsable
				, INFO.Email
				, INFO.ClaveEstablecimiento
				, INFO.IDEstadoSTPS
				, INFO.CodigoEstadoSTPS
				, INFO.EstadoSTPS
				, INFO.IDMunicipioSTPS
				, INFO.CodigoMunicipioSTPS
				, INFO.MunicipioSTPS
				, INFO.Latitud
				, INFO.Longitud
				, INFO.Fronterizo
				, INFO.IDItem
				, INFO.IDTemp 
		FROM #dtRevisionAux INFO
		WHERE ISNULL(IDCodigoPostal, 0) > 0
				AND ISNULL(IDColonia, 0) > 0

		UNION ALL
		
		-- IDENTIFICAMOS LAS COLONIAS QUE NO EXISTEN
		SELECT INFO.IDSucursal
				, INFO.Codigo
				, INFO.Descripcion
				, INFO.IDCodigoPostal
				, INFO.CodigoPostal
				, INFO.IDEstado
				, INFO.Estado
				, INFO.IDMunicipio
				, INFO.Municipio
				, 0 AS IDColonia				
				, NULL AS Colonia				
				, INFO.IDPais
				, INFO.Pais
				, INFO.Calle
				, INFO.Exterior
				, INFO.Interior
				, INFO.CuentaContable
				, INFO.Telefono
				, INFO.Responsable
				, INFO.Email
				, INFO.ClaveEstablecimiento
				, INFO.IDEstadoSTPS
				, INFO.CodigoEstadoSTPS
				, INFO.EstadoSTPS
				, INFO.IDMunicipioSTPS
				, INFO.CodigoMunicipioSTPS
				, INFO.MunicipioSTPS
				, INFO.Latitud
				, INFO.Longitud
				, INFO.Fronterizo
				, INFO.IDItem
				, INFO.IDTemp
		FROM (
				SELECT IR.*				
						, ROW_NUMBER() OVER (PARTITION BY IR.Codigo, IR.CodigoPostal ORDER BY IR.IDTemp) RN
				FROM #dtInformacionRecolectada IR
					JOIN (SELECT * FROM #dtRevisionAux WHERE ISNULL(IDCodigoPostal, 0) = 0 AND ISNULL(IDColonia, 0) = 0) RA ON IR.Codigo = RA.CodigoConf AND IR.CodigoPostal = RA.CodigoPostalConf AND IR.IDItem = RA.IDItemConf
		) INFO		
		WHERE INFO.RN = 1
		) INFO_FINAL

		

		-- CASO 3: SE COLOCO CODIGO POSTAL PERO NO COLONIA
		SELECT * 
		INTO #dtSugerencias
		FROM #dtInformacionRecolectada
		WHERE IDCodigoPostal > 0
				AND IDColonia = -1


		-- CASO 4: SE COLOCO COLONIA PERO NO CODIGO POSTAL
		SELECT * 
		INTO #dtMalConfigurada
		FROM #dtInformacionRecolectada
		WHERE IDCodigoPostal = -1
				AND IDColonia = -2

				
		-- CASO 5: EL CODIGO POSTAL NO EXISTE
		SELECT R.* 
		INTO #dtCodigoPostalInexistente
		FROM #dtInformacionRecolectada R
		WHERE R.IDCodigoPostal = 0
				AND (R.IDColonia = 0 OR R.IDColonia = -1)
				AND NOT EXISTS (SELECT R2.IDTemp FROM #dtRevision R2 WHERE R2.IDTemp = R.IDTemp)
		
		--SELECT * FROM #dtAdvertencias
		--SELECT * FROM #dtRevision
		--SELECT * FROM #dtSugerencias
		--SELECT * FROM #dtMalConfigurada
		--SELECT * FROM #dtCodigoPostalInexistente
		--RETURN
		
		/* -------------------------------------------------------------------------------------------------------------------------- */

				
		-- NORMALIZAMOS INFORMACION
		SELECT * 
		INTO #dtSucursalesIDsNormalizadas
		FROM (
				SELECT *, 0 AS IsSugerencia FROM #dtAdvertencias
		
				UNION ALL

				-- REVISION DE ITEMS BIEN CONFIGURADOS
				SELECT R.IDSucursal
						, R.Codigo
						, R.Descripcion
						, R.IDCodigoPostal
						, R.CodigoPostal
						, R.IDEstado
						, R.Estado
						, R.IDMunicipio
						, R.Municipio				
						, CASE 
							WHEN R.Colonia = S.Colonia
								THEN R.IDColonia
								ELSE 0
							END AS IDColonia	
						, CASE 
							WHEN R.Colonia = S.Colonia
								THEN R.Colonia
								ELSE S.Colonia
							END AS Colonia				
						, R.IDPais
						, R.Pais
						, R.Calle
						, R.Exterior
						, R.Interior
						, R.CuentaContable
						, R.Telefono
						, R.Responsable
						, R.Email
						, R.ClaveEstablecimiento
						, R.IDEstadoSTPS
						, R.CodigoEstadoSTPS
						, R.EstadoSTPS
						, R.IDMunicipioSTPS
						, R.CodigoMunicipioSTPS
						, R.MunicipioSTPS
						, R.Latitud
						, R.Longitud
						, R.Fronterizo
						, R.IDItem
						, R.IDTemp
						, 0 AS IsSugerencia	 						
				FROM #dtRevision  R
					LEFT JOIN @dtSucursalesAux S ON R.Codigo = S.Codigo AND R.CodigoPostal = S.CodigoPostal AND R.IDItem = S.IDItem				

				UNION ALL
		
				SELECT *, 1 AS IsSugerencia FROM #dtSugerencias

				UNION ALL

				SELECT * , 0 AS IsSugerencia FROM #dtMalConfigurada

				UNION ALL

				SELECT * , 0 AS IsSugerencia FROM #dtCodigoPostalInexistente
		) INFO
		--SELECT * FROM #dtSucursalesIDsNormalizadas ORDER BY IDTemp
		--RETURN
		

		/* -------------------------------------------------------------------------------------------------------------------------- */


		-- REULTADO FINAL
		SELECT INFO.*,
				-- SUB-CONSULTA QUE OBTIENE MENSAJE
				(SELECT '<b>*</b> ' + M.[Message] AS [Message],
						CAST(M.Valid AS BIT) AS Valid
				FROM @tempMessages M
				WHERE ID IN (SELECT ITEM FROM app.split(INFO.IDMensaje, ',') ) FOR JSON PATH ) AS Msg,
				-- SUB-CONSULTA QUE OBTIENE VALIDACION DEL MENSAJE
				CAST(CASE
						WHEN EXISTS((SELECT M.Valid AS [Message] FROM @tempMessages M WHERE ID IN(SELECT ITEM FROM APP.SPLIT(INFO.IDMensaje, ',')) AND Valid = 0))
							THEN 0
							ELSE 1
					END AS BIT) AS Valid
		FROM (SELECT D.IDSucursal
					, D.Codigo
					, D.Descripcion
					
					, CASE 
						WHEN D.IDCodigoPostal < 0
							THEN NULL
							ELSE D.IDCodigoPostal
						END AS IDCodigoPostal

					, CASE 
						WHEN D.IDEstado < 0
							THEN NULL
							ELSE D.IDEstado
						END AS IDEstado	

					, CASE 
						WHEN D.IDMunicipio < 0
							THEN NULL
							ELSE D.IDMunicipio
						END AS IDMunicipio

					, CASE 
						WHEN D.IDColonia < 0
							THEN 
								CASE WHEN D.IsSugerencia = @NO 
									THEN NULL 
									ELSE (SELECT TOP 1 C.IDColonia FROM [SAT].[tblCatColonias] C WHERE C.IDCodigoPostal = D.IDCodigoPostal AND C.NombreAsentamiento = D.Colonia) 
								END
							ELSE D.IDColonia
						END AS IDColonia
						
					, CASE 
						WHEN D.IDPais < 0
							THEN NULL
							ELSE D.IDPais
						END AS IDPais

					, CASE 
						WHEN D.IDEstadoSTPS < 0
							THEN NULL
							ELSE D.IDEstadoSTPS
						END AS IDEstadoSTPS

					, CASE 
						WHEN D.IDMunicipioSTPS < 0
							THEN NULL
							ELSE D.IDMunicipioSTPS
						END AS IDMunicipioSTPS
					
					, D.CodigoPostal	
					, D.Estado
					, D.Municipio
					, D.Colonia					
					, D.Pais
					, D.Calle
					, D.Exterior
					, D.Interior
					, D.CuentaContable
					, D.Telefono
					, D.Responsable
					, D.Email
					, D.ClaveEstablecimiento					
					, D.CodigoEstadoSTPS
					, D.EstadoSTPS					
					, D.CodigoMunicipioSTPS
					, D.MunicipioSTPS
					, D.Latitud
					, D.Longitud
					, CAST(D.Fronterizo AS BIT) AS Fronterizo
					, D.IDTemp
					, D.IDItem
					, CAST(D.IsSugerencia AS BIT) AS IsSugerencia
					, IDMensaje = IIF(ISNULL(D.Codigo, '') <> '', '', '1,') +
								  IIF(ISNULL(D.Descripcion, '') <> '', '', '2,') +
								  IIF(D.IDSucursal = 0, '', '3,') +
								  IIF(D.IDCodigoPostal = 0, '4,', '') +
								  IIF(D.IDColonia = 0, '5,', '') +
								  IIF(D.IDCodigoPostal = -1 AND D.IDColonia <> -2, '6,', '') +
								  IIF(D.IDEstado = -1 AND D.IDColonia <> -2, '7,', '') +
								  IIF(D.IDMunicipio = -1 AND D.IDColonia <> -2, '8,', '') +
								  IIF(D.IDColonia = -1 AND D.IsSugerencia = 0, '9,', '') +
								  IIF(D.IDPais = -1 AND D.IDColonia <> -2, '10,', '') +
								  IIF(D.IsSugerencia = 1, '11,', '') +
								  IIF(D.IDColonia = -2, '12,', '')  +
								  IIF((
										SELECT SUM(Resultado) AS TotalCount
										FROM (
											SELECT COUNT(*) AS Resultado
											FROM
												(
												SELECT SN.Codigo
													FROM #dtSucursalesIDsNormalizadas SN
													WHERE SN.Codigo = D.Codigo AND IsSugerencia = 1
													GROUP BY SN.Codigo, SN.IDItem
												) AS Sugerencias
											UNION ALL
											SELECT COUNT(*) Resultado
											FROM
												(
												SELECT SN.Codigo
													FROM #dtSucursalesIDsNormalizadas SN
													WHERE SN.Codigo = D.Codigo AND IsSugerencia = 0
												) AS NoSugerencias
										) AS Total
									  ) > 1,'13,','') + 
									  IIF(D.IDEstadoSTPS = 0 AND D.IDMunicipioSTPS = 0, '14,', '') +
									  IIF((D.IDEstadoSTPS = 0 AND D.IDMunicipioSTPS = -1) OR (D.IDEstadoSTPS = -1 AND D.IDMunicipioSTPS = 0)  , '15,', '') +
									  IIF(D.IDEstadoSTPS = -1 AND D.IDMunicipioSTPS = -1, '16,', '')									  
			  FROM #dtSucursalesIDsNormalizadas D) INFO
		ORDER BY INFO.IDTemp

	END
GO

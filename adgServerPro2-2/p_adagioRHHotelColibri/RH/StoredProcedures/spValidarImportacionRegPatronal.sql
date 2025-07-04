USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Valida importación masiva sobre registros patronales
** Autor			: Andrea Zainos
** Email			: azainos@adagio.com.mx
** FechaCreacion	: 2024-07-29
** Paremetros		: @dtRegPatronales		Lista de registro patronales.
					: @IDUsuario		Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE  PROCEDURE [RH].[spValidarImportacionRegPatronal]
( 
	@dtRegPatronales [RH].[dtImportacionRegPatronales] READONLY
	, @IDUsuario INT 
)
AS
	BEGIN		
		
		DECLARE @NO	  BIT = 0;

		DECLARE @tempMessages AS TABLE( 
			ID INT
			, [Message] VARCHAR(500)
			, Valid BIT
		)

		DECLARE @dtRegPatronalAux AS TABLE( 
		IDRegPatronal int,
		RegistroPatronal VARCHAR(255),
		RazonSocial VARCHAR(255),
		ActividadEconomica VARCHAR(255),
		ClaseRiesgo VARCHAR(50),
		RepresentanteLegal VARCHAR(255),
		OcupacionRepLegal VARCHAR(255),
		Telefono VARCHAR(50),
   		 FechaAfiliacion DATETIME,
		ConvenioSubsidios BIT,
		DelegacionIMSS VARCHAR(255),
		SubDelegacionIMSS VARCHAR(255),
		CodigoPostal VARCHAR(50),	
		Colonia VARCHAR(255),
		Calle VARCHAR(255),
		Exterior VARCHAR(50),
		Interior VARCHAR(50),
		[IDItem] [int]
		)
		
	
		
		
		-- OBTENEMOS MSJ QUE PERTENECEN A LAS EMPRESAS
		INSERT @tempMessages(ID, [Message], Valid)
		SELECT [IDMensajeTipo]
				, [Mensaje]
				, [Valid]
        FROM [RH].[tblMensajesMap]
        WHERE [MensajeTipo] = 'ImportacionRegistrosPatronalesMap'
        ORDER BY [IDMensajeTipo];


		/* -------------------------------------------------------------------------------------------------------------------------- */


		-- AGREGAMOS LA COLUMNA DE IDItem
		INSERT INTO @dtRegPatronalAux
		SELECT *
				, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS IDItem
		FROM @dtRegPatronales
		--SELECT * FROM @dtEmpresasAux

		
		/* -------------------------------------------------------------------------------------------------------------------------- */


		/*
			OBTENEMOS PRE-RESULTADO PARA EMPRESAS "CON COLONIA"
			Validaciones:
				1.- Obtenemos el IDEmpresa si no existe regresamos '0'.

				** CodigoPostal **
				2.- Si CodigoPostal, Colonia, CodigoRegimenFiscal y  sq	CodigoOrigenRecurso viene vacio o null regresamos '-1'.
				3.- Obtenemos el IDCodigoPostal, IDColonia, IDRegimenFiscal y IDOrigenRecurso si no existe regresamos '0'.
				4.- Valida que la colonia tenga el CodigoPostal '-2'
		*/
		SELECT -- VALIDACION 1
				ISNULL((
					SELECT RP.IDRegPatronal
					FROM [RH].[tblCatRegPatronal] RP
					WHERE RP.RegistroPatronal = TD.RegistroPatronal
				), 0) AS IDRegPatronal
				,TD.RegistroPatronal
				, TD.RazonSocial
				, TD.ActividadEconomica
				, CASE					
					/* VALIDACION 2 */ WHEN ISNULL(TD.ClaseRiesgo, '') = '' THEN -1
					/* VALIDACION 3 */ ELSE ISNULL((Select IDClaseRiesgo from IMSS.tblCatClaseRiesgo WHERE Descripcion=TD.ClaseRiesgo), 0) END 
				  AS IDClaseRiesgo			
				, TD.ClaseRiesgo
				, TD.RepresentanteLegal
				, TD.OcupacionRepLegal				
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
				, TD.FechaAfiliacion	
				, TD.Telefono							
				, TD.ConvenioSubsidios
				, TD.DelegacionIMSS
				, TD.SubDelegacionIMSS
				, TD.IDItem
				, ROW_NUMBER() OVER (ORDER BY (SELECT TD.IDItem)) AS IDTemp
		INTO #dtInformacionRecolectada
		FROM @dtRegPatronalAux TD
			LEFT JOIN SAT.tblCatCodigosPostales CP ON TD.CodigoPostal = CP.CodigoPostal
			LEFT JOIN SAT.tblCatEstados ES ON CP.IDEstado = ES.IDEstado
			LEFT JOIN SAT.tblCatMunicipios MU ON CP.IDMunicipio = MU.IDMunicipio
			LEFT JOIN SAT.tblCatColonias CO ON CP.IDCodigoPostal = CO.IDCodigoPostal
			LEFT JOIN SAT.tblCatPaises PA ON ES.IDPais = PA.IDPais
			--LEFT JOIN IMSS.tblCatClaseRiesgo CR ON TD.ClaseRiesgo = CR.Codigo

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
						, RPA.CodigoPostal AS CodigoPostalConf
						, RPA.Colonia AS ColoniaConf
						, RPA.RegistroPatronal AS RPConf
						, ROW_NUMBER() OVER (PARTITION BY RPA.RegistroPatronal, RPA.CodigoPostal, RPA.Colonia ORDER BY IDTemp) RN
				FROM @dtRegPatronalAux RPA
					LEFT JOIN #dtInformacionRecolectada IR ON RPA.RegistroPatronal = IR.RegistroPatronal AND RPA.RazonSocial = IR.RazonSocial AND RPA.CodigoPostal = IR.CodigoPostal AND REPLACE(RPA.Colonia, ' ', '') = REPLACE(IR.Colonia, ' ', '') AND RPA.IDItem = IR.IDItem
				WHERE ISNULL(RPA.CodigoPostal, '') <> ''
						AND REPLACE(ISNULL(RPA.Colonia, ''), ' ', '') <> ''
			 ) INFO
		WHERE INFO.RN = 1
		--SELECT * FROM #dtRevisionAux
		--RETURN
		

		--** RESULTADO DE CONSULTAS ANIDADAS
		-- IDENTIFICAMOS LAS COLONIAS QUE SI EXISTEN
		SELECT * 
		INTO #dtRevision
		FROM (
		SELECT INFO.IDRegPatronal
				, INFO.RegistroPatronal
				, INFO.RazonSocial
				, INFO.ActividadEconomica
				, INFO.IDClaseRiesgo
				, INFO.ClaseRiesgo
				, INFO.RepresentanteLegal
				, INFO.OcupacionRepLegal			
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
				, INFO.FechaAfiliacion
				, INFO.Telefono				
				, INFO.ConvenioSubsidios
				, INFO.DelegacionIMSS
				, INFO.SubDelegacionIMSS
				, INFO.IDItem
				, INFO.IDTemp 
		FROM #dtRevisionAux INFO
		WHERE ISNULL(IDCodigoPostal, 0) > 0
				AND ISNULL(IDColonia, 0) > 0

		UNION ALL
		
		-- IDENTIFICAMOS LAS COLONIAS QUE NO EXISTEN
		SELECT INFO.IDRegPatronal
				, INFO.RegistroPatronal
				, INFO.RazonSocial
				, INFO.ActividadEconomica
				, INFO.IDClaseRiesgo
				, INFO.ClaseRiesgo
				, INFO.RepresentanteLegal
				, INFO.OcupacionRepLegal
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
				, INFO.FechaAfiliacion
				, INFO.Telefono
				, INFO.ConvenioSubsidios
				, INFO.DelegacionIMSS
				, INFO.SubDelegacionIMSS				
				, INFO.IDItem
				, INFO.IDTemp 
		FROM (
				SELECT IR.*				
						, ROW_NUMBER() OVER (PARTITION BY IR.RegistroPatronal, IR.CodigoPostal ORDER BY IR.IDTemp) RN
				FROM #dtInformacionRecolectada IR
					JOIN (SELECT * FROM #dtRevisionAux WHERE ISNULL(IDCodigoPostal, 0) = 0 AND ISNULL(IDColonia, 0) = 0) RA ON IR.RegistroPatronal = RA.RegistroPatronal AND IR.CodigoPostal = RA.CodigoPostalConf
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
		INTO #dtEmpresasIDsNormalizadas
		FROM (
				SELECT *, 0 AS IsSugerencia FROM #dtAdvertencias
		
				UNION ALL

				-- REVISION DE ITEMS BIEN CONFIGURADOS, AGARRA EL PRIMERO, ESTO SE DA PORQUE EL CODIGO POSTAL TIENE VARIAS COLONIAS
				SELECT R.IDRegPatronal
						, R.RegistroPatronal
						, R.RazonSocial
						, R.ActividadEconomica
						, R.IDClaseRiesgo
						, R.ClaseRiesgo
						, R.RepresentanteLegal
						, R.OcupacionRepLegal
						, R.IDCodigoPostal
						, R.CodigoPostal
						, R.IDEstado
						, R.Estado
						, R.IDMunicipio
						, R.Municipio				
						, CASE 
							WHEN R.Colonia = E.Colonia
								THEN R.IDColonia
								ELSE 0
							END AS IDColonia	
						, CASE 
							WHEN R.Colonia = E.Colonia
								THEN R.Colonia
								ELSE E.Colonia
							END AS Colonia				
						, R.IDPais
						, R.Pais
						, R.Calle
						, R.Exterior
						, R.Interior
						, R.FechaAfiliacion
						, R.Telefono
						, R.ConvenioSubsidios
						, R.DelegacionIMSS
						, R.SubDelegacionIMSS		
						, R.IDItem
						, R.IDTemp
						, 0 AS IsSugerencia	 						
				FROM #dtRevision  R
					LEFT JOIN @dtRegPatronalAux E ON R.RegistroPatronal = E.RegistroPatronal AND R.CodigoPostal = E.CodigoPostal AND R.Colonia = E.Colonia
				

				UNION ALL
		
				SELECT *, 1 AS IsSugerencia FROM #dtSugerencias

				UNION ALL

				SELECT * , 0 AS IsSugerencia FROM #dtMalConfigurada

				UNION ALL

				SELECT * , 0 AS IsSugerencia FROM #dtCodigoPostalInexistente
		) INFO
		--SELECT * FROM #dtEmpresasIDsNormalizadas ORDER BY IDTemp
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
		FROM (SELECT D.IDRegPatronal
						, D.RegistroPatronal
						, D.RazonSocial
						, D.ActividadEconomica
						, CASE 
						WHEN D.IDClaseRiesgo < 0
							THEN NULL
							ELSE D.IDClaseRiesgo
						END AS IDClaseRiesgo
						, D.ClaseRiesgo
						, D.RepresentanteLegal
						, D.OcupacionRepLegal
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
					, D.CodigoPostal	
					, D.Estado
					, D.Municipio
					, D.Colonia					
					, D.Pais
					, D.Calle
					, D.Exterior
					, D.Interior
					--, cast(isnull(D.FechaAfiliacion, '9999-12-31') AS DATE) AS [FechaAfiliacion]
					, D.FechaAfiliacion		
					, D.Telefono
					, cast(D.ConvenioSubsidios as  bit) as ConvenioSubsidios
					, D.DelegacionIMSS
					, D.SubDelegacionIMSS		
					, D.IDTemp
					, D.IDItem
					, CAST(D.IsSugerencia AS BIT) AS IsSugerencia
					, IDMensaje = IIF(ISNULL(D.RegistroPatronal, '') <> '', '', '1,') +
								  IIF(ISNULL(D.RazonSocial, '') <> '', '', '2,') +
								  IIF(ISNULL(D.ClaseRiesgo, '') <> '' AND D.ClaseRiesgo NOT IN (SELECT Descripcion FROM IMSS.tblCatClaseRiesgo WHERE Descripcion COLLATE Cyrillic_General_CI_AI = D.ClaseRiesgo COLLATE Cyrillic_General_CI_AI), '3,', '') +
								  --IIF(D.IDClaseRiesgo = 0, '', '3,') +
								  IIF(D.IDRegPatronal = 0, '', '4,') +
								  IIF(D.IDCodigoPostal = 0, '5,', '') +
								  IIF(D.IDColonia = 0, '6,', '') +
								  IIF(D.IDCodigoPostal = -1 AND D.IDColonia <> -2, '7,', '') +
								  IIF(D.IDEstado = -1 AND D.IDColonia <> -2, '8,', '') +
								  IIF(D.IDMunicipio = -1 AND D.IDColonia <> -2, '9,', '') +
								  IIF(D.IDColonia = -1 AND D.IsSugerencia = 0, '10,', '') +
								  IIF(D.IDPais = -1 AND D.IDColonia <> -2, '11,', '') +
								  IIF(D.IsSugerencia = 1, '12,', '') +
								  IIF(D.IDColonia = -2, '13,', '')  +
								  IIF((
										SELECT SUM(Resultado) AS TotalCount
										FROM (
											SELECT COUNT(*) AS Resultado
											FROM
												(
												SELECT EN.RegistroPatronal
													FROM #dtEmpresasIDsNormalizadas EN
													WHERE EN.RegistroPatronal = D.RegistroPatronal AND IsSugerencia = 1
													GROUP BY EN.RegistroPatronal, EN.IDItem
												) AS Sugerencias
											UNION ALL
											SELECT COUNT(*) Resultado
											FROM
												(
												SELECT EN.RegistroPatronal
													FROM #dtEmpresasIDsNormalizadas EN
													WHERE EN.RegistroPatronal = D.RegistroPatronal AND IsSugerencia = 0
												) AS NoSugerencias
										) AS Total
									  ) > 1,'14,','') 
					
			  FROM #dtEmpresasIDsNormalizadas D) INFO
		ORDER BY INFO.IDTemp

	END
GO

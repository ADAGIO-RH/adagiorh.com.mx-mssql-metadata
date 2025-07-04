USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Valida importación masiva sobre empresas
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2024-07-29
** Paremetros		: @dtEmpresas		Lista de empresas.
					: @IDUsuario		Identificador del usuario.
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [RH].[spValidarImportacionEmpresas]
( 
	@dtEmpresas [RH].[dtImportacionEmpresas] READONLY
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

		DECLARE @dtEmpresasAux AS TABLE( 
			[IdEmpresa] [int] NULL,
			[NombreComercial] [varchar](MAX) NULL,
			[RFC] [varchar](MAX) NULL,
			[CodigoPostal] [varchar](50) NULL,
			[Colonia] [varchar](MAX) NULL,
			[Calle] [varchar](MAX) NULL,
			[Exterior] [varchar](20) NULL,
			[Interior] [varchar](20) NULL,
			[RegFonacot] [varchar](50) NULL,
			[RegInfonavit] [varchar](50) NULL,
			[RegSIEM] [varchar](50) NULL,
			[RegEstatal] [varchar](50) NULL,
			[CodigoRegimenFiscal] [varchar](10) NULL,
			[CodigoOrigenRecurso] [varchar](10) NULL,
			[PasswordInfonavit] [varchar](MAX) NULL,
			[CURP] [varchar](18) NULL,
			[IDItem] [int]
		)
		
		-- DETECCION DE IDIOMA
		SELECT @IDIdioma = LOWER(REPLACE([APP].[fnGetPreferencia]('Idioma', @IDUsuario, 'esmx'), '-', ''))
		
		
		-- OBTENEMOS MSJ QUE PERTENECEN A LAS EMPRESAS
		INSERT @tempMessages(ID, [Message], Valid)
		SELECT [IDMensajeTipo]
				, [Mensaje]
				, [Valid]
        FROM [RH].[tblMensajesMap]
        WHERE [MensajeTipo] = 'ImportacionEmpresasMap'
        ORDER BY [IDMensajeTipo];


		/* -------------------------------------------------------------------------------------------------------------------------- */


		-- AGREGAMOS LA COLUMNA DE IDItem
		INSERT INTO @dtEmpresasAux
		SELECT *
				, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS IDItem
		FROM @dtEmpresas
		--SELECT * FROM @dtEmpresasAux

		
		/* -------------------------------------------------------------------------------------------------------------------------- */


		/*
			OBTENEMOS PRE-RESULTADO PARA EMPRESAS "CON COLONIA"
			Validaciones:
				1.- Obtenemos el IDEmpresa si no existe regresamos '0'.

				** CodigoPostal **
				2.- Si CodigoPostal, Colonia, CodigoRegimenFiscal y CodigoOrigenRecurso viene vacio o null regresamos '-1'.
				3.- Obtenemos el IDCodigoPostal, IDColonia, IDRegimenFiscal y IDOrigenRecurso si no existe regresamos '0'.
				4.- Valida que la colonia tenga el CodigoPostal '-2'
		*/
		SELECT -- VALIDACION 1
				ISNULL((
					SELECT E.IdEmpresa
					FROM [RH].[tblEmpresa] E
					WHERE E.RFC = TD.RFC
				), 0) AS IDEmpresa
				, TD.NombreComercial
				, TD.RFC
				
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
				, TD.RegFonacot
				, TD.RegInfonavit
				, TD.RegSIEM
				, TD.RegEstatal
								
				, CASE
					/* VALIDACION 2 */ WHEN ISNULL(TD.CodigoRegimenFiscal, '') = '' THEN -1
					/* VALIDACION 3 */ ELSE ISNULL(RF.IDRegimenFiscal, 0) END 
				  AS IDRegimenFiscal
				, TD.CodigoRegimenFiscal
								
				, CASE
					/* VALIDACION 2 */ WHEN ISNULL(TD.CodigoOrigenRecurso, '') = '' THEN -1
					/* VALIDACION 3 */ ELSE ISNULL(COR.IDOrigenRecurso, 0) END 
				  AS IDOrigenRecurso
				, TD.CodigoOrigenRecurso

				, TD.PasswordInfonavit
				, TD.CURP
				, TD.IDItem
				, ROW_NUMBER() OVER (ORDER BY (SELECT TD.IDItem)) AS IDTemp
		INTO #dtInformacionRecolectada
		FROM @dtEmpresasAux TD
			LEFT JOIN SAT.tblCatCodigosPostales CP ON TD.CodigoPostal = CP.CodigoPostal
			LEFT JOIN SAT.tblCatEstados ES ON CP.IDEstado = ES.IDEstado
			LEFT JOIN SAT.tblCatMunicipios MU ON CP.IDMunicipio = MU.IDMunicipio
			LEFT JOIN SAT.tblCatColonias CO ON CP.IDCodigoPostal = CO.IDCodigoPostal
			LEFT JOIN SAT.tblCatPaises PA ON ES.IDPais = PA.IDPais
			LEFT JOIN Sat.TblCatRegimenesFiscales RF ON TD.CodigoRegimenFiscal = RF.Codigo
			LEFT JOIN SAT.TblCatOrigenesRecursos COR ON TD.CodigoOrigenRecurso = COR.Codigo
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
						, EA.CodigoPostal AS CodigoPostalConf
						, EA.Colonia AS ColoniaConf
						, EA.RFC AS RFCConf
						, EA.IDItem AS IDItemConf
						, ROW_NUMBER() OVER (PARTITION BY EA.RFC, EA.CodigoPostal, EA.Colonia, EA.IDItem ORDER BY IDTemp) RN
				FROM @dtEmpresasAux EA
					LEFT JOIN #dtInformacionRecolectada IR ON EA.NombreComercial = IR.NombreComercial AND EA.RFC = IR.RFC AND EA.CodigoPostal = IR.CodigoPostal AND REPLACE(EA.Colonia, ' ', '') = REPLACE(IR.Colonia, ' ', '') AND EA.IDItem = IR.IDItem
				WHERE ISNULL(EA.CodigoPostal, '') <> ''
						AND REPLACE(ISNULL(EA.Colonia, ''), ' ', '') <> ''
			 ) INFO
		WHERE INFO.RN = 1
		--SELECT * FROM #dtRevisionAux
		--RETURN
		

		--** RESULTADO DE CONSULTAS ANIDADAS
		-- IDENTIFICAMOS LAS COLONIAS QUE SI EXISTEN
		SELECT * 
		INTO #dtRevision
		FROM (
		SELECT INFO.IDEmpresa
				, INFO.NombreComercial
				, INFO.RFC
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
				, INFO.RegFonacot
				, INFO.RegInfonavit
				, INFO.RegSIEM
				, INFO.RegEstatal
				, INFO.IDRegimenFiscal
				, INFO.CodigoRegimenFiscal
				, INFO.IDOrigenRecurso
				, INFO.CodigoOrigenRecurso
				, INFO.PasswordInfonavit
				, INFO.CURP
				, INFO.IDItem
				, INFO.IDTemp 
		FROM #dtRevisionAux INFO
		WHERE ISNULL(IDCodigoPostal, 0) > 0
				AND ISNULL(IDColonia, 0) > 0

		UNION ALL
		
		-- IDENTIFICAMOS LAS COLONIAS QUE NO EXISTEN
		SELECT INFO.IDEmpresa
				, INFO.NombreComercial
				, INFO.RFC
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
				, INFO.RegFonacot
				, INFO.RegInfonavit
				, INFO.RegSIEM
				, INFO.RegEstatal
				, INFO.IDRegimenFiscal
				, INFO.CodigoRegimenFiscal
				, INFO.IDOrigenRecurso
				, INFO.CodigoOrigenRecurso
				, INFO.PasswordInfonavit
				, INFO.CURP
				, INFO.IDItem
				, INFO.IDTemp 
		FROM (
				SELECT IR.*				
						, ROW_NUMBER() OVER (PARTITION BY IR.RFC, IR.CodigoPostal ORDER BY IR.IDTemp) RN
				FROM #dtInformacionRecolectada IR
					JOIN (SELECT * FROM #dtRevisionAux WHERE ISNULL(IDCodigoPostal, 0) = 0 AND ISNULL(IDColonia, 0) = 0) RA ON IR.RFC = RA.RFCConf AND IR.CodigoPostal = RA.CodigoPostalConf AND IR.IDItem = RA.IDItemConf
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

				-- REVISION DE ITEMS BIEN CONFIGURADOS
				SELECT R.IdEmpresa
						, R.NombreComercial
						, R.RFC
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
						, R.RegFonacot
						, R.RegInfonavit
						, R.RegSIEM
						, R.RegEstatal
						, R.IDRegimenFiscal
						, R.CodigoRegimenFiscal
						, R.IDOrigenRecurso
						, R.CodigoOrigenRecurso
						, R.PasswordInfonavit
						, R.CURP
						, R.IDItem
						, R.IDTemp
						, 0 AS IsSugerencia	 						
				FROM #dtRevision  R
					LEFT JOIN @dtEmpresasAux E ON R.RFC = E.RFC AND R.CodigoPostal = E.CodigoPostal AND R.IDItem = E.IDItem				

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
		FROM (SELECT D.IDEmpresa
					, D.NombreComercial
					, D.RFC	
					
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
						WHEN D.IDRegimenFiscal < 0
							THEN NULL
							ELSE D.IDRegimenFiscal
						END AS IDRegimenFiscal

					, CASE 
						WHEN D.IDOrigenRecurso < 0
							THEN NULL
							ELSE D.IDOrigenRecurso
						END AS IDOrigenRecurso

					, D.CodigoPostal	
					, D.Estado
					, D.Municipio
					, D.Colonia					
					, D.Pais
					, D.Calle
					, D.Exterior
					, D.Interior
					, D.RegFonacot
					, D.RegInfonavit
					, D.RegSIEM
					, D.RegEstatal		
					, D.CodigoRegimenFiscal
					, D.CodigoOrigenRecurso
					, D.PasswordInfonavit
					, D.CURP
					, D.IDTemp
					, D.IDItem
					, CAST(D.IsSugerencia AS BIT) AS IsSugerencia
					, IDMensaje = IIF(ISNULL(D.RFC, '') <> '', '', '1,') +
								  IIF(ISNULL(D.NombreComercial, '') <> '', '', '2,') +
								  IIF(D.IDEmpresa = 0, '', '3,') +
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
												SELECT EN.RFC
													FROM #dtEmpresasIDsNormalizadas EN
													WHERE EN.RFC = D.RFC AND IsSugerencia = 1
													GROUP BY EN.RFC, EN.IDItem
												) AS Sugerencias
											UNION ALL
											SELECT COUNT(*) Resultado
											FROM
												(
												SELECT EN.RFC
													FROM #dtEmpresasIDsNormalizadas EN
													WHERE EN.RFC = D.RFC AND IsSugerencia = 0
												) AS NoSugerencias
										) AS Total
									  ) > 1,'13,','') + 
									  IIF(D.IDRegimenFiscal = 0, '14,', '') +
									  IIF(D.IDRegimenFiscal = -1, '15,', '') +
									  IIF(D.IDOrigenRecurso = 0, '16,', '') +
									  IIF(D.IDOrigenRecurso = -1, '17,', '') 
			  FROM #dtEmpresasIDsNormalizadas D) INFO
		ORDER BY INFO.IDTemp

	END
GO

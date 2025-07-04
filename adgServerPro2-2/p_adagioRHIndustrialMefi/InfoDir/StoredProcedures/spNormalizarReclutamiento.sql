USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************
** Descripción		: Normalizar la información de reclutamiento
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2022-06-22
** Paremetros		: @FechaNormalizacion
** IDAzure			: 

** DataTypes Relacionados:
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROC [InfoDir].[spNormalizarReclutamiento]
(
	@FechaNormalizacion DATE
)
AS
	BEGIN

	DECLARE 
	@IDIdioma varchar(20)
	;

    select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')
		-- ELIMINAR NORMALIZACION 
		DELETE [InfoDir].[tblReclutamientoNormalizado] WHERE FechaNormalizacion = @FechaNormalizacion		

		INSERT INTO [InfoDir].[tblReclutamientoNormalizado]
		SELECT CAST(RCP.FechaAplicacion AS DATE) AS FechaNormalizacion,
			   CP.IDCandidato,
			   C.Nombre + ' ' + C.Paterno AS Candidato,
			   CP.IDPlaza,
			   PL.IDPuesto,
			   JSON_VALUE(PU.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) AS Puesto,
			   RP.IDRequisitoPuesto,
			   RP.Requisito AS RequisitoPuesto,
			   RP.IDTipoCaracteristica,
			   JSON_VALUE(TC.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) AS TipoCaracteristica,
			   --RP.TipoValor,
			   --RP.ValorEsperado,
			   CASE	
					WHEN RP.TipoValor = 'BOOL'
						THEN CASE WHEN JSON_VALUE(RP.ValorEsperado, '$.valueBool') = 'true' THEN 'Si' ELSE 'No' END
					WHEN RP.TipoValor = 'NUMBER'
						THEN JSON_VALUE(RP.ValorEsperado, '$.valueNumber')
					WHEN RP.TipoValor = 'DATE'
						THEN JSON_VALUE(RP.ValorEsperado, '$.valueDate')
					WHEN RP.TipoValor = 'DATERANGE'
						THEN 'Entre ' + JSON_VALUE(ValorEsperado, '$.Min') + ' y ' + JSON_VALUE(ValorEsperado, '$.Max')
					WHEN RP.TipoValor = 'RANGENUMBER'
						THEN 'Entre ' + JSON_VALUE(ValorEsperado, '$.Min') + ' y ' + JSON_VALUE(ValorEsperado, '$.Max')
					ELSE 'No'
				END AS ValorEsperado,
			   CASE
					WHEN RP.TipoValor = 'BOOL'
						THEN CASE WHEN RCP.Resultado = 'true' THEN 'Si' ELSE 'No' END
					ELSE RCP.Resultado
				END AS ResultadoCandidato,
			   CASE	
					WHEN RP.TipoValor = 'BOOL'
						THEN CASE WHEN JSON_VALUE(RP.ValorEsperado, '$.valueBool') = RCP.Resultado THEN 'Si' ELSE 'No' END
					WHEN RP.TipoValor = 'NUMBER'
						THEN CASE WHEN JSON_VALUE(RP.ValorEsperado, '$.valueNumber') = RCP.Resultado THEN 'Si' ELSE 'No' END
					WHEN RP.TipoValor = 'DATE'
						THEN CASE WHEN JSON_VALUE(RP.ValorEsperado, '$.valueDate') = RCP.Resultado THEN 'Si' ELSE 'No' END
					WHEN RP.TipoValor = 'DATERANGE'
						THEN CASE WHEN RCP.Resultado BETWEEN JSON_VALUE(ValorEsperado, '$.Min') AND JSON_VALUE(ValorEsperado, '$.Max') THEN 'Si' ELSE 'No' END
					WHEN RP.TipoValor = 'RANGENUMBER'
						THEN CASE WHEN CAST(RCP.Resultado AS NUMERIC) BETWEEN JSON_VALUE(ValorEsperado, '$.Min') AND JSON_VALUE(ValorEsperado, '$.Max') THEN 'Si' ELSE 'No' END
					ELSE 'No'
				END AS Resultado
		FROM [Reclutamiento].[tblResultadosCandidatoPlaza] RCP
			INNER JOIN [Reclutamiento].[tblCandidatoPlaza] CP ON RCP.IDCandidatoPlaza = CP.IDCandidatoPlaza
			INNER JOIN [Reclutamiento].[tblCandidatos] C ON C.IDCandidato = CP.IDCandidato
			INNER JOIN [RH].[tblCatPlazas] PL ON CP.IDPlaza = PL.IDPlaza
			INNER JOIN [RH].[tblCatPuestos] PU ON PL.IDPuesto = PU.IDPuesto
			INNER JOIN [RH].[tblRequisitosPuestos] RP ON RCP.IDRequisitoPuesto = RP.IDRequisitoPuesto
			INNER JOIN [RH].[tblCatTiposCaracteristicas] TC ON RP.IDTipoCaracteristica = TC.IDTipoCaracteristica
		WHERE RP.TipoValor != 'TEXT' AND
			  CAST(RCP.FechaAplicacion AS DATE) = @FechaNormalizacion
	
	END
GO

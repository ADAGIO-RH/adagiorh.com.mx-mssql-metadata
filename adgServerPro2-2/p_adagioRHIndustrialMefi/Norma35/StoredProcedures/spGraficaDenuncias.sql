USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Norma35].[spGraficaDenuncias] 
    @IDTipoDenuncia INT = 0,
	@IDEstatusDenuncia INT = 0,
	@FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
	@IDUsuario int
AS
BEGIN

	declare 
		 @IDIdioma Varchar(5)
		select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');
		
    IF @FechaInicio IS NULL
        SET @FechaInicio = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0);

    IF @FechaFin IS NULL
        SET @FechaFin = DATEADD(DAY, -1, DATEADD(MONTH, 1, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) + 1, 0)));

	IF OBJECT_ID('tempdb..#tmpFechas') IS NOT NULL
	BEGIN
		DROP TABLE #tmpFechas;
	END

	-- Crear la tabla temporal
	CREATE TABLE #tmpFechas (
		[Fecha] DATE PRIMARY KEY 
	);

	INSERT INTO #tmpFechas ([Fecha])
	EXEC [App].[spListaFechas] @FechaInicio, @FechaFin;

	IF OBJECT_ID('tempdb..#tmpResult') IS NOT NULL
	BEGIN
		DROP TABLE #tmpResult;
	END

CREATE TABLE #tmpResult (Fecha DATE, IDTipoDenuncia INT, TipoDenuncia VARCHAR(255), data INT);

INSERT INTO #tmpResult
SELECT
    f.Fecha
    ,tiposdenuncia.IDTipoDenuncia
    ,tiposdenuncia.Descripcion as TipoDenuncia
    ,(
        Select COUNT(*)
        FROM  Norma35.tblDenuncias AS de WITH (NOLOCK)
        LEFT JOIN [Norma35].[tblCatEstatusDenuncia] AS estd WITH (NOLOCK) ON estd.IDEstatusDenuncia = de.IDEstatusDenuncia
        LEFT JOIN Norma35.tblCatTiposDenuncias tipos WITH (NOLOCK) ON tipos.IDTipoDenuncia = de.IDTipoDenuncia
        WHERE de.FechaEvento = f.Fecha
        and tipos.IDTipoDenuncia = tiposdenuncia.IDTipoDenuncia
		AND ((de.IDEstatusDenuncia = @IDEstatusDenuncia) OR ISNULL(@IDEstatusDenuncia,0) = 0)
    ) as data
       
FROM
    #tmpFechas AS f 
    CROSS APPLY Norma35.tblCatTiposDenuncias tiposdenuncia
WHERE ((tiposdenuncia.IDTipoDenuncia = @IDTipoDenuncia) OR ISNULL(@IDTipoDenuncia,0) = 0)

-- Consulta original (agrupa por Fecha)
SELECT 
    TipoDenuncia as label	
    , '#' + 
    FORMAT(ABS(CHECKSUM(NEWID())) % 256, 'X2') + 
    FORMAT(ABS(CHECKSUM(NEWID())) % 256, 'X2') + 
    FORMAT(ABS(CHECKSUM(NEWID())) % 256, 'X2') borderColor
    , CONCAT('[', 
      STUFF(
        (
          SELECT ',' + CAST(data AS VARCHAR(50))
          FROM #tmpResult AS tmp
          WHERE tmp.TipoDenuncia = tr.TipoDenuncia
          FOR XML PATH('')
        ),
        1,
        1,
        ''
      ) ,']') AS data
FROM #tmpResult AS tr
GROUP BY tr.TipoDenuncia;

SELECT CASE WHEN @IDIdioma = 'es-MX' THEN FORMAT(Fecha,'dd/MM/yyyy')
			WHEN @IDIdioma = 'en-US' THEN FORMAT(Fecha,'MM/dd/yyyy')
			ELSE FORMAT(Fecha,'yyyy-MM-dd')
			END Fecha
FROM #tmpFechas

SELECT
'# de Tipo de Denuncias' as label,
'1' borderWidth,
CONCAT('[', STRING_AGG(SUMData, ', '),']') AS data,
CONCAT('[',REPLACE(STRING_AGG(bColor, ','),'ALPHA', '1'),']')  as borderColor,
CONCAT('[',REPLACE(STRING_AGG(bColor, ','),'ALPHA', '0.5'),']') as backgroundColor
FROM (
    SELECT TipoDenuncia, CAST(SUM(data) AS VARCHAR(50)) AS SUMData
		,'"rgba(' +
                CAST(ABS(CHECKSUM(NEWID())) % 256 AS VARCHAR(3)) + ',' +
                CAST(ABS(CHECKSUM(NEWID())) % 256 AS VARCHAR(3)) + ',' +
                CAST(ABS(CHECKSUM(NEWID())) % 256 AS VARCHAR(3)) + ',' +
                'ALPHA)"' bColor
    FROM #tmpResult
    GROUP BY TipoDenuncia 
) AS Subquery ;

SELECT DISTINCT(TipoDenuncia) FROM #tmpResult

END;
GO

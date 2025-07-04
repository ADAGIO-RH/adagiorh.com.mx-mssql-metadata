USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar en la [Dashboard].[tblHistorialVigenciasPorFechas] por fechas
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-07-09
** Paremetros		:              


	exec [Dashboard].[spBuscarHistorialVigenciasPorFechas] @FechaIni='2020-08-01', @FechaFin='2022-08-25', @IDUsuario=1
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2024-02-14			Jose Roman		Procedimiento para Generar las graficas en Vue para Dashboard de RH
									Historial de Vigentes.
***************************************************************************************************/
/*
[Dashboard].[spBuscarHistorialVigenciasPorFechasVue] '2023-01-14','2023-03-15',1
*/
CREATE proc [Dashboard].[spBuscarHistorialVigenciasPorFechasVue](
     @FechaIni date
    ,@FechaFin date
    ,@IDUsuario int
) as
    declare 
		@IDIdioma varchar(10)
	   ,@IdiomaSQL varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')

	select @IdiomaSQL = i.[SQL]
	from App.tblIdiomas i
	where i.IDIdioma = @IDIdioma

	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
	begin
		set @IdiomaSQL = 'Spanish' ;
	end
  
	SET LANGUAGE @IdiomaSQL;


	IF OBJECT_ID('tempdb..#tmpFechas') IS NOT NULL
	BEGIN
		DROP TABLE #tmpFechas;
	END

	-- Crear la tabla temporal
	CREATE TABLE #tmpFechas (
		[Fecha] DATE PRIMARY KEY 
	);

	INSERT INTO #tmpFechas ([Fecha])
	EXEC [App].[spListaFechas] @FechaIni, @FechaFin;

	IF OBJECT_ID('tempdb..#tmpResult') IS NOT NULL
	BEGIN
		DROP TABLE #tmpResult;
	END

	CREATE TABLE #tmpResult (Fecha DATE, data INT);

	INSERT INTO #tmpResult
	SELECT 
		   Fecha
		   ,Total
		from [Dashboard].[tblHistorialVigenciasPorFechas] with (nolock)
		where Fecha BETWEEN @FechaIni and @FechaFin
       


-- Consulta original (agrupa por Fecha)
SELECT 
    'Vigentes' as label	
    , '#446db2'  borderColor
    , CONCAT('[', 
      STUFF(
        (
          SELECT ',' + CAST(data AS VARCHAR(50))
          FROM #tmpResult AS tmp
          FOR XML PATH('')
        ),
        1,
        1,
        ''
      ) ,']') AS data


SELECT CASE WHEN @IDIdioma = 'es-MX' THEN FORMAT(Fecha,'dd/MM/yyyy')
			WHEN @IDIdioma = 'en-US' THEN FORMAT(Fecha,'MM/dd/yyyy')
			ELSE FORMAT(Fecha,'yyyy-MM-dd')
			END Fecha
FROM [Dashboard].[tblHistorialVigenciasPorFechas]
where Fecha BETWEEN @FechaIni and @FechaFin
GO

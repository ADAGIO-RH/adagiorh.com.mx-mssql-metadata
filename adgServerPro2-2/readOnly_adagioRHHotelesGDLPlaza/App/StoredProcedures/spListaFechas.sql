USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Retorna la lista de fechas según los parámetros que recibe
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-08-14
** Paremetros		: @FechaIni DATE  
				  @FechaFin DATE 
			 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [App].[spListaFechas]( 
		@FechaIni DATE 
	   , @FechaFin DATE ) as
begin
  --  declare @dim [App].[dtFechas] ;
    --@NumberOfYears INT = 30;

    --if (@Idioma is null or len(@Idioma) = 0)
    --begin
	   --set @Idioma = 'Spanish' ;
    --end
    --DECLARE @CutoffDate DATE = DATEADD(YEAR, @NumberOfYears, @StartDate);
   -- SET LANGUAGE @Idioma;
    --SET Language 'Spanish';
    --SET Language 'english';

    --prevent set or regional settings from interfering with 
    --interpretation of dates / literals

    SET DATEFIRST 7;
    --SET DATEFORMAT mdy;
    --SET LANGUAGE US_ENGLISH;
    
    -- this is just a holding table for intermediate calculations:

    --if object_id('tempdb..#dim') is not null drop table #dim;

    --CREATE TABLE #dim
    --(
    --  [Fecha]       DATE PRIMARY KEY, 
    --  [Dia]			AS DATEPART(DAY,      [Fecha]),
    --  [Mes]			AS DATEPART(MONTH,    [Fecha]),
    --  PrimerDiaMes		AS CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, [Fecha]), 0)),
    --  [NombreMes]		AS DATENAME(MONTH,    [Fecha]),
    --  [Semana]		AS DATEPART(WEEK,     [Fecha]),
    --  [ISOSemana]		AS DATEPART(ISO_WEEK, [Fecha]),
    --  [DiaSemana]		AS DATEPART(WEEKDAY,  [Fecha]),
    --  [Quarto]		AS DATEPART(QUARTER,  [Fecha]),
    --  [Anio]			AS DATEPART(YEAR,     [Fecha]),
    --  PrimerDiaAnio	AS CONVERT(DATE, DATEADD(YEAR,  DATEDIFF(YEAR,  0, [Fecha]), 0)),
    --  Formato112		AS CONVERT(CHAR(8),   [Fecha], 112),
    --  Formato101		AS CONVERT(CHAR(10),  [Fecha], 101)
    --);

    CREATE TABLE #dim(
	   [Fecha]       DATE PRIMARY KEY 
	)

    -- use the catalog views to generate as many rows as we need

    INSERT #dim([Fecha]) 
    SELECT d
    FROM
    (
	 SELECT d = DATEADD(DAY, rn - 1, @FechaIni)
	 FROM 
	 (
	   SELECT TOP (DATEDIFF(DAY, @FechaIni, @FechaFin) +1) 
		rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
	   FROM sys.all_objects AS s1
	   CROSS JOIN sys.all_objects AS s2
	   -- on my system this would support > 5 million days
	   ORDER BY s1.[object_id]
	 ) AS x
    ) AS y;

    select *
    from #dim
end
GO

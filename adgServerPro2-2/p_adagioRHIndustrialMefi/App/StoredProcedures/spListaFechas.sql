USE [p_adagioRHIndustrialMefi]
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
    SET DATEFIRST 7;

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

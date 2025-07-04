USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Compensaciones].[spBuscarMatrizIncrementoDetalle](
	@IDMatrizIncremento int,
	@IDUsuario int
)
AS
BEGIN

	if object_id('tempdb..#tempColumnas')	is not null drop table #tempColumnas 
	if object_id('tempdb..#tempData')		is not null drop table #tempData
	if object_id('tempdb..#tempSalida')		is not null drop table #tempSalida

		select distinct 
			ValorNivelAmplitud as Columna,
			cast(CAST(ValorNivelAmplitud*100.00 as int) as Varchar)as Title
		into #tempColumnas
		from Compensaciones.TblMatrizIncrementoDetalle
		Where IDMatrizIncremento = @IDMatrizIncremento

		select *,
		cast(CAST(ValorNivelAmplitud*100.00 as int) as Varchar) as Title
		into #tempData
		from Compensaciones.TblMatrizIncrementoDetalle
		Where IDMatrizIncremento = @IDMatrizIncremento

		--select * from #tempData

	DECLARE @cols AS VARCHAR(MAX),
			@query1  AS VARCHAR(MAX),
			@query2  AS VARCHAR(MAX),
			@colsAlone AS VARCHAR(MAX)
		;

SET @cols = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(c.Title)+',0) AS '+ QUOTENAME(c.Title)
				FROM #tempColumnas c
				GROUP BY c.Columna,c.Title
				ORDER BY c.Columna
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(c.Title)
				FROM #tempColumnas c
				GROUP BY c.Columna,c.Title
				ORDER BY c.Columna
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

--select @cols
--select @colsAlone


				

set @query1 = 'SELECT IDMatrizIncremento,ValorNivelProgresion, ' + @cols + ' from 
				(
					select 
						 IDMatrizIncremento
						, Title
						, isnull(ValorNivelProgresion,0) as ValorNivelProgresion
						, isnull(Valor,0) as Valor
					from #tempData
			   ) x'

	set @query2 = '
				pivot 
				(
					 SUM(Valor)
					for Title in (' + @colsAlone + ')
				) p 
				FOR JSON AUTO 
				
				'
print @query2
exec( @query1 + @query2) 



END
GO

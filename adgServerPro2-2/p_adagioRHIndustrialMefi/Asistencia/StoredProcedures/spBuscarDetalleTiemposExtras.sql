USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [Asistencia].[spBuscarDetalleTiemposExtras]              
(              
	 @FechaIni date = '1900-01-01'
	 ,@Fechafin date = '9999-12-31'              
	 ,@dtEmpleados [RH].[dtEmpleados] READONLY              
)              
AS              
BEGIN        
	--declare 	 
	--	@FechaIni date = '2019-04-01'
	--	,@Fechafin  date = '2019-04-30'  
	--	,@dtEmpleados [RH].[dtEmpleados] ;
	 
	--insert @dtEmpleados
	--exec rh.spbuscarempleados  @FechaIni = @FechaIni,@Fechafin  = @Fechafin 
        
	if object_id('tempdb..#tempTiemposExtras') is not null drop table #tempTiemposExtras;
	
	Select  ie.IDEmpleado
			,SUM(cast(datepart(hh, ie.TiempoAutorizado) as decimal(10,4)))  as Horas 
			,SUM(cast(datepart(mi, ie.TiempoAutorizado) as decimal(10,4))) as  Minutos
	 		,SUM(cast(datepart(SS, ie.TiempoAutorizado) as decimal(10,4))) as  Segundos 	
	 		,SUM(TiempoExtraDecimal) as  TiempoTotal 	
	 		--,cast(0 as decimal(10,4)) as TiempoTotal
	INTO #tempTiemposExtras			
	from Asistencia.tblIncidenciaEmpleado ie
		join @dtEmpleados e on ie.IDEmpleado = e.IDEmpleado
	where (ie.IDIncidencia = 'EX') and 
		(ie.Fecha between @FechaIni and @Fechafin) and (isnull(ie.Autorizado,0) = 1) 
	group by ie.IDEmpleado

	update #tempTiemposExtras
		set	Segundos = case when Segundos > 59 then cast((Segundos / convert(decimal(10,4),60.0)) as int) else Segundos end
			,Minutos = case when Segundos > 59 then (Minutos + cast((Segundos / convert(decimal(10,4),60.0)) as int)) else Minutos end
	
	update #tempTiemposExtras
		set 
			Horas = case when Minutos > 59 then Horas + cast((Minutos / convert(decimal(10,4),60.0)) as int) else Horas end
			,Minutos = case when Minutos > 59 then 60.0 * ((Minutos / convert(decimal(10,4),60.0)) - cast((Minutos / convert(decimal(10,4),60.0)) as int)  ) else Minutos end
	
	update #tempTiemposExtras set TiempoTotal =  horas + (minutos / 60.0) ;
	
	select * from #tempTiemposExtras
END
GO

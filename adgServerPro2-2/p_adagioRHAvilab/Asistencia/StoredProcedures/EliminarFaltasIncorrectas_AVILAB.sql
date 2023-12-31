USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Object:  StoredProcedure [Asistencia].[EliminarFaltasIncorrectas]    Script Date: 04/06/2019 10:30:18 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
-- =============================================  
-- Author.............: Ing. Jose Roman
-- Create date........: 20/06/2013  
-- Last Date Modified.: 04/06/2019  
-- Description: Elimina todas las Faltas mas generadas y La Incidencia FR  
-- =============================================  
CREATE   PROCEDURE [Asistencia].[EliminarFaltasIncorrectas_AVILAB] 
(
	@dtFechas app.dtFechas readonly,  
	@dtEmpleados [RH].[dtEmpleados] readonly,
	@IDUsuario int
) 
AS 
BEGIN  
	SET DATEFIRST 7;  
	SET LANGUAGE Spanish;

	if object_id('tempdb..#tempCatIncidencias') is not null drop table #tempCatIncidencias
	if object_id('tempdb..#tempVigenciaEmpleados') is not null drop table #tempVigenciaEmpleados  
	if object_id('tempdb..#tempEmpleadoAusentismo') is not null drop table #tempEmpleadoAusentismo
	if object_id('tempdb..#tempResultado') is not null drop table #tempResultado

	select * 
	into #tempCatIncidencias
	from Asistencia.tblCatIncidencias
  
	create Table #tempVigenciaEmpleados(  
		IDEmpleado int null,  
		Fecha Date null,  
		Vigente bit null  
	)  

	insert into #tempVigenciaEmpleados  
	Exec [RH].[spBuscarListaFechasVigenciaEmpleado]  @dtEmpleados = @dtEmpleados  
		,@Fechas = @dtFechas  
		,@IDUsuario = @IDUsuario 

	select 
		* 
		,isnull((select top 1 1 
				from Asistencia.tblIncidenciaEmpleado ie 
					inner join #tempCatIncidencias i
						on ie.IDIncidencia = i.IDIncidencia and I.IDIncidencia <> 'F'
							and IE.Autorizado = 1
				where i.EsAusentismo = 1 and ie.IDEmpleado = ve.IDEmpleado
					and ie.Fecha = ve.Fecha),0) tieneAusentismo
	into #tempEmpleadoAusentismo
	from #tempVigenciaEmpleados VE
	where ve.Vigente = 1

	Select 
		tve.Fecha
		,e.IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,ea.tieneAusentismo
		,DF.IDDiaFestivo
		,IE.IDIncidencia
		,(Select count(*) from Asistencia.tblChecadas where FechaOrigen = tve.Fecha and IDEmpleado = tve.IDEmpleado and IDTipoChecada  not in ('EC','SC')) as checadas
	into #tempResultado
	from #tempVigenciaEmpleados tve
		left join #tempEmpleadoAusentismo EA on EA.Fecha = tve.Fecha
			and ea.tieneAusentismo = 1
			and tve.IDEmpleado = EA.IDEmpleado
		inner join @dtEmpleados e on tve.IDEmpleado = e.IDEmpleado
		inner join #tempCatIncidencias I on I.IDIncidencia = 'F'
		left join Asistencia.TblCatDiasFestivos DF on DF.Fecha = tve.Fecha
			and df.Autorizado = 1
		inner join Asistencia.tblIncidenciaEmpleado ie on ie.Fecha = tve.Fecha  
			and ie.IDEmpleado = e.IDEmpleado  
			and ie.IDIncidencia = 'F'
	 where tve.Vigente = 1
		and e.RequiereChecar = 1
		--and DF.IDDiaFestivo is null
	GROUP BY 
		e.IDEmpleado
		,tve.IDEmpleado
		,tve.Fecha
		,I.Autorizar
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO
		,ea.tieneAusentismo
		,DF.IDDiaFestivo
		,IE.IDIncidencia
	order by e.ClaveEmpleado ,tve.Fecha
		
	delete IE
	from #tempResultado R
		inner join Asistencia.tblIncidenciaEmpleado IE on r.Fecha = IE.Fecha
			and r.IDEmpleado = IE.IDEmpleado
			and IE.IDIncidencia = 'F'
	where (R.tieneAusentismo is not null) or (r.IDDiaFestivo is not null) or (r.checadas >= 1) 
		
end
GO

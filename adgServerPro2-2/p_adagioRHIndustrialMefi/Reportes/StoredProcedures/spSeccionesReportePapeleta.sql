USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc Reportes.spSeccionesReportePapeleta(
	@IDPapeleta int
	,@IDUsuario int
) as


	declare 
		 @EsAusentismo bit = 0
		,@IDIncidencia varchar(20)
	;


	select @IDIncidencia = p.IDIncidencia
			,@EsAusentismo = isnull(i.EsAusentismo,cast(0 as bit))
	from Asistencia.tblPapeletas p
		join Asistencia.tblCatIncidencias i on p.IDIncidencia = i.IDIncidencia
	where p.IDPapeleta = @IDPapeleta

	select
		Incidencia = case when @EsAusentismo = cast(0 as bit) then CAST(1 AS bit) else cast(0 as bit) end,
		Ausentimos = case when @EsAusentismo = cast(1 as bit) and @IDIncidencia not IN ('V','I') then CAST(1 AS bit) else cast(0 as bit) end,
		Vacaciones = case when @IDIncidencia = 'V' then CAST(1 AS bit) else cast(0 as bit) end,
		Incapacidad = case when @IDIncidencia = 'I' then CAST(1 AS bit) else cast(0 as bit) end
GO

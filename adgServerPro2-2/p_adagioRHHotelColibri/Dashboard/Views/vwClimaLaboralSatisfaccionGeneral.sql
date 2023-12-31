USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create     view [Dashboard].[vwClimaLaboralSatisfaccionGeneral] as
	-- Satisfacción General
	select 'Satisfacción General' as Title, 
	cast((SUM(Porcentaje)/COUNT(Porcentaje))/100.0 as decimal(18,2)) as Total, IDProyecto
	from (
		select distinct Grupo, Porcentaje, c.IDProyecto
		from Dashboard.tblReporteClimaLaboral c
		--	join Dashboard.vwClimaLaboralProyectos p on p.IDProyecto = c.IDProyecto
		where Grupo like '%SECCION 1%'
	) as info
	group by IDProyecto
GO

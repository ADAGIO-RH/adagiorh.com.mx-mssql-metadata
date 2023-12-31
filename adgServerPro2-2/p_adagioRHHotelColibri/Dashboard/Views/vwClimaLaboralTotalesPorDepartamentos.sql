USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   view Dashboard.vwClimaLaboralTotalesPorDepartamentos as
	-- Total por departamento
	select	IDProyecto
			,Departamento
			,Total = cast(Valor / MaximaCalificacionPosible  as decimal(10,2)) 
	from (
		select 
			IDProyecto,
			Departamento, 
			COUNT(Pregunta) as TotalPreguntas,
			COUNT(Pregunta) * 4 as MaximaCalificacionPosible,
			SUM(ValorFinal) as Valor
		from Reportes.vwDashboardClimaLaboral
		--where Grupo like '%SECCION 1%'
		group by IDProyecto, Departamento
	) as info

GO

USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   proc [Dashboard].[spClimaLaboralSatisfaccionGeneralPorSupervisor](
	@IDProyecto int = 0,
	@ClaveSupervisor varchar(20),
	@IDUsuario int
) as
	-- Satisfacción General
	select 
		'Satisfacción General' as Title, 
		Nombre = case when @ClaveSupervisor = '0292' then 'DIRECCIÓN GENERAL' else 'DIRECCIÓN DE OPERACIÓN' end,
		cast((SUM(Porcentaje)/COUNT(Porcentaje))/100.0 as decimal(18,2)) as Total, 
		(select top 1 color from Dashboard.tblEscala where cast((SUM(Porcentaje)/COUNT(Porcentaje))/100.0 as decimal(18,2)) between [min] and [max]) color,
		IDProyecto
	from (
		select distinct Grupo, Porcentaje, c.IDProyecto
		from Dashboard.tblReporteClimaLaboral c
		--	join Dashboard.vwClimaLaboralProyectos p on p.IDProyecto = c.IDProyecto
		where Grupo like '%SECCION 1%'and c.ClaveEvaluado = @ClaveSupervisor
	) as info
	group by IDProyecto
--GO


GO

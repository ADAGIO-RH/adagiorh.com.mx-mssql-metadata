USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

	--declare 
	--	@IDProyecto int = 21
	--;
	 
CREATE   proc [Dashboard].[spSatisfaccionGeneral] (
	@IDProyecto int
) as

	-- Satisfacción General
	select 'Satisfacción General' as Title, cast((SUM(Porcentaje)/COUNT(Porcentaje))/100.0 as decimal(18,2)) as Total
	from (
		select distinct IDGrupo, Grupo, Porcentaje
		from Dashboard.tblReporteClimaLaboral
		where IDProyecto = @IDProyecto
	) as info


GO

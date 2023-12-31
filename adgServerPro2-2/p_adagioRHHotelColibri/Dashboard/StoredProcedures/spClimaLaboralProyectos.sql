USE [p_adagioRHHotelColibri]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Dashboard].[spClimaLaboralProyectos](
	@IDUsuario int
) as
	select 
		c.*, 
		sg.Title, 
		sg.Total,
		(select top 1 color from Dashboard.tblEscala where Total between [min] and [max]) color
	from Evaluacion360.tblCatProyectos c
		join Dashboard.vwClimaLaboralSatisfaccionGeneral sg on sg.IDProyecto = c.IDProyecto
		join Dashboard.tblPermisosProyectos pp on pp.IDProyecto = c.IDProyecto and pp.IDUsuario = @IDUsuario
	--where c.IDProyecto in (21 , 22)
	order by Total desc
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [ReporteClimaLaboralV1].spBuscarSatisfaccionGeneralPorProyecto(
	@IDProyecto int,
	@IDUsuario int
) as
	--declare 
	--	@IDProyecto int = 136
	--;

	declare @Respuesta [Evaluacion360].[dtSatisfaccionGeneral]

	insert @Respuesta(Title, Valor, IDProyecto)
	select 
		'Satisfacción General' as Title, 
		cast((SUM(Porcentaje)/COUNT(Porcentaje))/ 100.00 as decimal(18,2)) as Valor, 
		IDProyecto
	from (
		select distinct IDGrupo, Porcentaje, c.IDProyecto
		from [InfoDir].[tblRespuestasNormalizadasClimaLaboral] c
		where c.IDProyecto = @IDProyecto and IDTipoPreguntaGrupo in (2,3)
	) as info
	group by IDProyecto

	update @Respuesta
		set
			Total = Valor * 100.00,
			Color = (
					select esg.Color 
					from [Evaluacion360].[tblEscalaSatisfaccionGeneral] esg
					where esg.IDProyecto = @IDProyecto and Valor between esg.[min] and esg.[max]
				)

	select 
		*
	from @Respuesta
GO

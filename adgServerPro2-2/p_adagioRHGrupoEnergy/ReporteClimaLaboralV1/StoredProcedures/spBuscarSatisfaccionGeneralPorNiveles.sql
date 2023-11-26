USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [ReporteClimaLaboralV1].[spBuscarSatisfaccionGeneralPorNiveles](
	@IDProyecto int,
	@IDNivelEmpresarial int = 0,
	@IDUsuario int
) as

	declare 
		@query varchar(max)
	;

	set @query = N'
		select 
			'+case when isnull(@IDNivelEmpresarial, 0) != 0 then 'Indicador' else 'Nivel' end +'
			,AVG(Valor) as Valor
			,IDProyecto
			,FORMATMESSAGE(''{"IDProyecto":%d,"tipo":"nivelempresarial","id":%d, "title": "%s por Indicadores"}'', IDProyecto, IDNivelEmpresarial, Nivel)
		from (
			select 
				d.IDProyecto, 
				d.IDNivelEmpresarial,
				cat.Nombre as Nivel,
				'+case when isnull(@IDNivelEmpresarial, 0) != 0 then 'i.Nombre as Indicador,' else '' end +'
				COUNT(d.IDPregunta) as TotalPreguntas,
				COUNT(d.IDPregunta) * MaximaCalificacionPosible as MaximaCalificacionPosible,
				SUM(d.ValorFinal)/(cast(COUNT(d.IDPregunta) as decimal(18,2)) * MaximaCalificacionPosible) as Valor
				--SUM(d.ValorFinal) as Valor
			from [InfoDir].[tblRespuestasNormalizadasClimaLaboral] d
				join #listaNiveles cat on cat.IDNivelEmpresarial = d.IDNivelEmpresarial
				'+case when isnull(@IDNivelEmpresarial, 0) != 0 then 'join Evaluacion360.tblCatIndicadores i on i.IDIndicador = d.IDIndicador' else '' end +'
			where IDProyecto = '+cast(@IDProyecto as varchar)+' and IDTipoPreguntaGrupo in (2,3)
				'+case when isnull(@IDNivelEmpresarial, 0) != 0 then 'and d.IDNivelEmpresarial = '+cast(@IDNivelEmpresarial as varchar) else '' end +'
			group by d.IDProyecto, d.IDNivelEmpresarial, cat.Nombre, d.MaximaCalificacionPosible, '+case when isnull(@IDNivelEmpresarial, 0) != 0 then 'i.Nombre,' else '' end +' d.MaximaCalificacionPosible
		) as info
		group by  IDProyecto, IDNivelEmpresarial, Nivel '+case when isnull(@IDNivelEmpresarial, 0) != 0 then ',Indicador' else '' end +'
	'; 

	if object_id('tempdb..#listaNiveles') is not null drop table #listaNiveles;

	create table #listaNiveles (
		IDNivelEmpresarial int,
		Nombre varchar(255),
		Orden int,
		TotalPaginas int,
		TotalRegistros int
	);

	declare @Respuesta [Evaluacion360].[dtSatisfaccionGeneral]

	insert #listaNiveles
	exec RH.[spBuscarNivelesEmpresariales] @IDUsuario=@IDUsuario

	insert @Respuesta(Title, Valor, IDProyecto, JSONData)
	exec (@query)

	update @Respuesta
		set
			Total = Valor * 100.00,
			Color = (
					select esg.Color 
					from [Evaluacion360].[tblEscalaSatisfaccionGeneral] esg
					where esg.IDProyecto = @IDProyecto and Valor between esg.[min] and esg.[max]
				)

	select *
	from @Respuesta
	order by Total desc
GO

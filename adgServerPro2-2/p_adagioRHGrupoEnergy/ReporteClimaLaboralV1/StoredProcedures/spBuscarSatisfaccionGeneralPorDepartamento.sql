USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [ReporteClimaLaboralV1].[spBuscarSatisfaccionGeneralPorDepartamento](
	@IDProyecto int,
	@IDDepartamento int = 0,
	@IDUsuario int
) as
	declare 
		@query varchar(max)
	;

	set @query = N'
		select 
			'+case when isnull(@IDDepartamento, 0) != 0 then 'Indicador' else 'Departamento' end +'
			,AVG(Valor) as Valor
			,IDProyecto
			,FORMATMESSAGE(''{"IDProyecto":%d,"tipo":"departamento","id":%d, "title": "%s por Indicadores"}'', IDProyecto, IDDepartamento, Departamento)
		from (
			select 
				d.IDProyecto, 
				d.IDDepartamento,
				depto.Descripcion as Departamento,
				'+case when isnull(@IDDepartamento, 0) != 0 then 'i.Nombre as Indicador,' else '' end +'
				COUNT(d.IDPregunta) as TotalPreguntas,
				COUNT(d.IDPregunta) * MaximaCalificacionPosible as MaximaCalificacionPosible,
				SUM(d.ValorFinal)/(cast(COUNT(d.IDPregunta) as decimal(18,2)) * MaximaCalificacionPosible) as Valor
				--SUM(d.ValorFinal) as Valor
			from [InfoDir].[tblRespuestasNormalizadasClimaLaboral] d
				join #listaDepartamento depto on depto.IDDepartamento = d.IDDepartamento
				'+case when isnull(@IDDepartamento, 0) != 0 then 'join Evaluacion360.tblCatIndicadores i on i.IDIndicador = d.IDIndicador' else '' end +'
			where IDProyecto = '+cast(@IDProyecto as varchar)+' and IDTipoPreguntaGrupo in (2,3)
				'+case when isnull(@IDDepartamento, 0) != 0 then 'and d.IDDepartamento = '+cast(@IDDepartamento as varchar) else '' end +'
			group by d.IDProyecto, d.IDGrupo, d.IDDepartamento, depto.Descripcion, '+case when isnull(@IDDepartamento, 0) != 0 then 'i.Nombre,' else '' end +' d.MaximaCalificacionPosible
		) as info
		group by  IDProyecto, IDDepartamento, Departamento '+case when isnull(@IDDepartamento, 0) != 0 then ',Indicador' else '' end +'
	';

	if OBJECT_ID('tempdb..#listaDepartamento') is not null drop table #listaDepartamento;

	create table #listaDepartamento (
		IDDepartamento int,
		Codigo varchar(20),
		Descripcion varchar(max),
		CuentaContable varchar(25),
		IDEmpleado int,
		JefeDepartamento varchar(100),
		ROWNUMBER int,
		TotalPaginas int,
		TotalRegistros int
	);

	declare @Respuesta [Evaluacion360].[dtSatisfaccionGeneral]

	insert #listaDepartamento
	exec RH.spBuscarCatDepartamentos @IDUsuario=@IDUsuario

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

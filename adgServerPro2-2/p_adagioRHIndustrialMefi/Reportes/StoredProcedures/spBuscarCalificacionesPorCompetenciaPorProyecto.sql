USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar Grupos
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-12-07
** Paremetros		:    
	TipoReferencia:
		0 : Catálogo
		1 : Asignado a una Prueba
		2 : Asignado a un colaborador
		3 : Asignado a un puesto
		4 : Asignado a una Prueba final para responder
     
	 Cuando el campo TipoReferencia vale 0 (Catálogo) entonces IDReferencia también vale 0     


	 exec [Reportes].[spBuscarCalificacionesPorCompetencia] 41081
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-02-01			Aneudy Abreu	Se reempleadó el caracter & por una Y en las preguntas y competencias
									Esto porque provoca un error en el reporte cuando parsea el text a HTML.
***************************************************************************************************/
CREATE proc [Reportes].[spBuscarCalificacionesPorCompetenciaPorProyecto](
	@IDProyecto int 
	,@IDTipoGrupo int =null
) as
--declare  @IDEmpleadoProyecto int = 41081

    SET NOCOUNT ON;
     IF 1=0 BEGIN
       SET FMTONLY OFF
     END

	 declare  @MaxValorEscalaValoracion decimal(10,2) = 0.0
             ,@IDIdioma VARCHAR(max);
        
select @IDIdioma=App.fnGetPreferencia('Idioma', 1, 'esmx')

	--select @IDProyecto = ep.IDProyecto
	--from [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) 
	--where ep.IDEmpleadoProyecto = @IDEmpleadoProyecto 

	
	select @MaxValorEscalaValoracion = max(Valor)
	from [Evaluacion360].[tblEscalasValoracionesProyectos]
	where IDProyecto = @IDProyecto

	if object_id('tempdb..#tempHistorialEstatusEvaluacion') is not null
			drop table #tempHistorialEstatusEvaluacion;

	if object_id('tempdb..#tempEvaluacionesCompletas') is not null
			drop table #tempEvaluacionesCompletas;

	if object_id('tempdb..#tempGrupos') is not null
			drop table #tempGrupos;

	if object_id('tempdb..#tempEstadisticos') is not null
			drop table #tempEstadisticos;

	select ee.*,eee.IDEstatusEvaluacionEmpleado
		,eee.IDEstatus
		,JSON_VALUE(estatus.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Estatus')) as Estatus
		,eee.IDUsuario
		,eee.FechaCreacion 
		,ROW_NUMBER()over(partition by eee.IDEvaluacionEmpleado 
							ORDER by eee.IDEvaluacionEmpleado, eee.FechaCreacion  desc) as [ROW]
	INTO #tempHistorialEstatusEvaluacion
	from [Evaluacion360].[tblEvaluacionesEmpleados] ee with (nolock)
		join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on ee.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		left join [Evaluacion360].[tblEstatusEvaluacionEmpleado] eee with (nolock) on ee.IDEvaluacionEmpleado = eee.IDEvaluacionEmpleado --and eee.IDEstatus = 10
		left join (select * from Evaluacion360.tblCatEstatus where IDTipoEstatus  = 2) estatus on eee.IDEstatus = estatus.IDEstatus
	where ep.IDProyecto = @IDProyecto

--	insert into [Evaluacion360].[tblEstatusEvaluacionEmpleado](IDEvaluacionEmpleado
--,IDEstatus
--,IDUsuario) 
--select 105656,13,1

-- select * from #tempHistorialEstatusEvaluacion
	select  em.IDEvaluacionEmpleado,
    em.IDTipoRelacion,   
    JSON_VALUE(ctp.Traduccion,FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Relacion')) as Relacion
	INTO #tempEvaluacionesCompletas
	from [Evaluacion360].[tblEvaluacionesEmpleados] em
		join [Evaluacion360].[tblEmpleadosProyectos] ep with (nolock) on em.IDEmpleadoProyecto = ep.IDEmpleadoProyecto
		join [Evaluacion360].[tblCatTiposRelaciones] ctp on em.IDTipoRelacion = ctp.IDTipoRelacion
		left join #tempHistorialEstatusEvaluacion estatus on em.IDEvaluacionEmpleado = estatus.IDEvaluacionEmpleado and estatus.ROW = 1
	where ep.IDProyecto = @IDProyecto
		 and estatus.IDEstatus = 13


	select *
	INTO #tempGrupos
	from [Evaluacion360].[tblCatGrupos] cg
		join  #tempEvaluacionesCompletas e on cg.IDReferencia = e.IDEvaluacionEmpleado
	where (cg.TipoReferencia = 4) and (cg.IDTipoGrupo = @IDTipoGrupo or @IDTipoGrupo is null)
			and isnull(cg.Porcentaje,0.0) > 0.0
	 --and cg.IDTipoPreguntaGrupo in (2,3)
 
	select cg.Nombre
		,cg.Descripcion
		,cg.TotalPreguntas --cast(count(*) as decimal(10,2)) as TotalPreguntas
		--,count(*) * @MaxValorEscalaValoracion as MaximaCalificacionPosible
		,cg.MaximaCalificacionPosible
		,cast(sum(cast(isnull(cg.Promedio,0) as decimal(10,2))) / count(*)as decimal(10,2)) as CalificacionObtenida
	--	,sum(cast(isnull(rp.Respuesta,0) as decimal(10,2))) as CalificacionObtenida
	INTO #tempEstadisticos
	from #tempGrupos cg
		join [Evaluacion360].[tblCatTipoGrupo] ctg  on cg.IDTipoGrupo = ctg.IDTipoGrupo
		join [Evaluacion360].[tblCatPreguntas] p on cg.IDGrupo = p.IDGrupo
		--join [Evaluacion360].[tblQuienResponderaPregunta] qrp on qrp.IDPregunta = p.IDPregunta and (cg.IDTipoRelacion = case when qrp.IDTipoRelacion = 5 then cg.IDTipoRelacion else qrp.IDTipoRelacion end) /*Revisar esta parte, se deben de quitar las preguntas de la prueba al generar dicha prueba segun el tipo de relación*/
		left join [Evaluacion360].[tblRespuestasPreguntas] rp on rp.IDEvaluacionEmpleado = cg.IDReferencia and rp.IDPregunta = p.IDPregunta
		left join [Evaluacion360].[tblCatCategoriasPreguntas] cp on p.IDCategoriaPregunta = cp.IDCategoriaPregunta
--	where (cg.GrupoEscala = 1 )
	group by cg.Nombre,cg.Descripcion,cg.TotalPreguntas,cg.MaximaCalificacionPosible
	--order by ctg.IDTipoGrupo, cg.Nombre,cp.Nombre asc

	select  Nombre
			,replace(replace( 
                replace( 
                replace( 
                replace( N'<p> <b>'+coalesce(Nombre,'')+' ' +cast(CalificacionObtenida as varchar) +' de '+cast(MaximaCalificacionPosible as varchar) +'</b> <br/>'+coalesce(Descripcion,'')+'</p>'
                ,    '\', '\\' )
                ,    '%', '\%' )
                ,    '_', '\_' )
                ,    '[', '\[' )
				,	'&','Y')  as NombreYCafilificacion
			--,N'<p> <b>'+Nombre+' '+cast(cast(CalificacionObtenida / TotalPreguntas as decimal(10,2)) as varchar) +' de '+cast(MaximaCalificacionPosible as varchar) +'</b> <br/>'+Descripcion+'</p>' as NombreYCafilificacion
			,coalesce(Descripcion,'') as Descripcion
			,TotalPreguntas
			,MaximaCalificacionPosible
			,CalificacionObtenida
		--,(CalificacionObtenida * 100) / MaximaCalificacionPosible as Promedio
		,cast(CalificacionObtenida / TotalPreguntas as decimal(10,2)) as Calificacion
	from #tempEstadisticos

	

	--select * from Evaluacion360.tblEvaluacionesEmpleados
	--where IDEvaluacionEmpleado in(105657,105656)

	--select *
	--from Evaluacion360.tblEstatusEvaluacionEmpleado
	--where IDEvaluacionEmpleado in(105657,105656)

	--insert into Evaluacion360.tblEstatusEvaluacionEmpleado(IDEvaluacionEmpleado,IDEstatus,IDUsuario)
	--select 105657,13,1

 	--delete from Evaluacion360.tblEstatusEvaluacionEmpleado where IDEstatusEvaluacionEmpleado = 27467
GO

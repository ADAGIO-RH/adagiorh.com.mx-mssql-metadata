USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar pruebas de una evaluación de empleado
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-02-14
** Paremetros		:    
	TipoReferencia:
		0 : Catálogo
		1 : Asignado a una Prueba
		2 : Asignado a un colaborador
		3 : Asignado a un puesto
		4 : Asignado a una Prueba final para responder
     
	 Cuando el campo TipoReferencia vale 0 (Catálogo) entonces IDReferencia también vale 0   
	 
	 
	 Si se cambia el result set de este SP es necesario modificar los siguientes sp's:
	 
	  - [Evaluacion360].[spActualizarProgresoEvaluacionEmpleado]  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-02-07			Aneudy Abreu	Se agregaron los campos  Box9EsRequerido,Comentario,ComentarioEsRequerido 	
***************************************************************************************************/
/*
[Evaluacion360].[spBuscarPreguntasEvaluacionEmpleado]
	 @IDEvaluacionEmpleado = 113582

	*/
CREATE proc [Evaluacion360].[spBuscarPreguntasEvaluacionEmpleado](
	 @IDEvaluacionEmpleado int
) as


--declare 
-- @TipoReferencia	int  =  4	
--	,@IDReferencia	int 	= 113166
--	,@IDUsuario		int 	=1
 declare  
	   @IDIdioma Varchar(5)
	   ,@IdiomaSQL varchar(100) = null
 ;
	SET DATEFIRST 7;

	set @IdiomaSQL = 'Spanish' ;
    
  
    SET LANGUAGE @IdiomaSQL;

	if object_id('tempdb..#tempGrupos') is not null
		drop table #tempGrupos;

	select 
		-- cg.IDGrupo
		--,cg.IDTipoGrupo
		--,ctg.Nombre as TipoGrupo
		--,cg.Nombre as Grupo
		--,cg.Descripcion as DescripcionGrupo
		--,isnull(cg.FechaCreacion,getdate()) as FechaCreacion
		--,LEFT(DATENAME(WEEKDAY,isnull(cg.FechaCreacion,getdate())),3) + ' ' +
		--  CONVERT(VARCHAR(6),isnull(cg.FechaCreacion,getdate()),106) 
		--  + ' '+convert(varchar(4),datepart(year,isnull(cg.FechaCreacion,getdate()) ))
		--  --' '+convert(varchar(5),cast(isnull(cg.FechaCreacion,getdate()) as time)) 
		--	FechaCreacionStr
		--,cg.TipoReferencia
		--,cg.IDReferencia
		--,isnull(cg.CopiadoDeIDGrupo,0) as CopiadoDeIDGrupo
		--,
		p.IDPregunta
		,p.IDTipoPregunta
		,p.Descripcion as Pregunta
		,p.EsRequerida
		,p.Calificar
		,p.Box9
		--,isnull(p.IDCategoriaPregunta,0) as IDCategoriaPregunta
		--,isnull(cp.Nombre,'Sin Categoría signada') as CategoriaPregunta
	 	,Completa = CASE 
			WHEN isnull(p.EsRequerida,0) = 0 and p.Vista = 1 THEN 1
			WHEN 
				(isnull(p.EsRequerida,0) = 1) 
				AND (isnull(p.Box9EsRequerido,0) = 1) 
				AND (isnull(p.Box9,0) = 1) 
				AND (rp.IDRespuestaPregunta IS NOT NULL 
					AND rp.Respuesta IS NOT NULL 
					AND (p.IDTipoPregunta not in (8, 9))) 
				AND p.Vista = 1 THEN 1
			WHEN 
				(isnull(p.EsRequerida,0) = 1) 
				AND (isnull(p.Box9,0) = 1) 
				AND (isnull(p.Box9EsRequerido,0) = 1) 
				AND (rp.IDRespuestaPregunta IS NOT NULL 
					AND rp.Respuesta IS NOT NULL 
					AND rp.Box9DesempenioActual IS NOT NULL 
					AND rp.Box9DesempenioFuturo IS NOT null) 
				AND p.Vista = 1 THEN 1
			WHEN (isnull(p.EsRequerida,0) = 1) 
				AND (isnull(p.Box9EsRequerido,0) = 0) 
				AND (rp.IDRespuestaPregunta IS NOT NULL 
					AND rp.Respuesta IS NOT NULL )
				AND p.Vista = 1 THEN 1
			WHEN (isnull(p.EsRequerida,0) = 1) 
				AND (isnull(p.Box9,0) = 0) 
				AND (isnull(p.Box9EsRequerido,0) = 1) 
				AND (rp.IDRespuestaPregunta IS NOT NULL 
					AND rp.Respuesta IS NOT NULL )
				AND p.Vista = 1 THEN 1
			ELSE 0
		END
		,rp.Respuesta

		--,GrupoEscala = case when exists (select top 1 1 
		--								from [Evaluacion360].[tblCatPreguntas] 
		--								where IDGrupo = cg.IDGrupo and IDTipoPregunta = 8 /*Escala*/)
		--					then cast(1 as bit) else cast(0 as bit) end
	 --   ,isnull(p.Box9EsRequerido,cast(0 as bit)) Box9EsRequerido
		--,isnull(p.Comentario,cast(0 as bit)) Comentario
		--,isnull(p.ComentarioEsRequerido,cast(0 as bit)) ComentarioEsRequerido
		--,(select count(*) from [Evaluacion360].[tblComentariosPregunta] with (nolock) where IDPregunta = p.IDPregunta ) as TotalComentarios
		,ROW_NUMBER()over(ORDER BY ctg.IDTipoGrupo, cg.Nombre asc) as [Row]
	from [Evaluacion360].[tblCatGrupos] cg
		join [Evaluacion360].[tblCatTipoGrupo] ctg  on cg.IDTipoGrupo = ctg.IDTipoGrupo
		join [Evaluacion360].[tblCatPreguntas] p on cg.IDGrupo = p.IDGrupo
		left join [Evaluacion360].[tblRespuestasPreguntas] rp on rp.IDEvaluacionEmpleado = cg.IDReferencia and rp.IDPregunta = p.IDPregunta
	--	left join [Evaluacion360].[tblCatCategoriasPreguntas] cp on p.IDCategoriaPregunta = cp.IDCategoriaPregunta
	where  
		  (cg.TipoReferencia = 4 and cg.IDReferencia = @IDEvaluacionEmpleado)
	order by cg.IDGrupo,p.IDPregunta asc
	--order by ctg.IDTipoGrupo, cg.Nombre,cp.Nombre asc
GO

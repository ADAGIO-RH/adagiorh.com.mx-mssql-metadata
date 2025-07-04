USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**************************************************************************************************** 
** Descripción		: Buscar Grupos y preguntas por Nombre del Grupo
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-10-19
** Paremetros		: @filter

	[Evaluacion360].[spBuscarGruposPreguntasFilters] @filter = 'Co'
		,@IDTipoGrupo = 1
		,@IDUsuario = 1


****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/		
		   
CREATE proc [Evaluacion360].[spBuscarGruposPreguntasFilters]( 
		@filter varchar(255) 
		,@IDTipoGrupo int  = null
		,@IDUsuario int) as
declare  
	   @IDIdioma Varchar(5)
	   ,@IdiomaSQL varchar(100) = null
	   ,@TotalPaginas int = 0;
 
	SET DATEFIRST 7;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')

    select @IdiomaSQL = [SQL]
    from app.tblIdiomas
    where IDIdioma = @IDIdioma

    if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
    begin
	   set @IdiomaSQL = 'Spanish' ;
    end
  
    SET LANGUAGE @IdiomaSQL;

	if object_id('tempdb..#tempGrupos') is not null drop table #tempGrupos;

	SELECT *
	INTO #tempGrupos
	FROM (
			select 				 
				 cg.IDGrupo
				,cg.IDTipoGrupo
				,ctg.Nombre as TipoGrupo
				,cg.Nombre
				,cg.Descripcion
				,isnull(cg.FechaCreacion,getdate()) as FechaCreacion
				,LEFT(DATENAME(WEEKDAY,isnull(cg.FechaCreacion,getdate())),3) + ' ' +
				  CONVERT(VARCHAR(6),isnull(cg.FechaCreacion,getdate()),106) 
				  + ' '+convert(varchar(4),datepart(year,isnull(cg.FechaCreacion,getdate()) ))
					FechaCreacionStr
				,cg.TipoReferencia
				,cg.IDReferencia
				,isnull(cg.CopiadoDeIDGrupo,0) as CopiadoDeIDGrupo
				,ISNULL(cg.IDTipoPreguntaGrupo,0) as IDTipoPreguntaGrupo
				,ISNULL(ctpg.Nombre,'Sin asignar') as TipoPreguntaGrupo
				,isnull(cg.RequerirComentario, 0) as RequerirComentario
				,EscalaIndividualStr = case when cg.IDTipoPreguntaGrupo = 3 then STUFF(
																	(   SELECT ', ('+ cast(Valor as varchar(10))+') '+ CONVERT(NVARCHAR(100), Nombre) 
																		FROM [Evaluacion360].[tblEscalasValoracionesGrupos] 
																		WHERE IDGrupo = cg.IDGrupo 
																		FOR xml path('')
																	)
																	, 1
																	, 1
																	, '') else null end
				,ROW_NUMBER() OVER(PARTITION BY cg.Nombre ORDER BY cg.Nombre asc) [Row]
			from [Evaluacion360].[tblCatGrupos] cg  with (nolock)
				join [Evaluacion360].[tblCatTipoGrupo] ctg  with (nolock)  on cg.IDTipoGrupo = ctg.IDTipoGrupo
				left join [Evaluacion360].[tblCatTiposPreguntasGrupos] ctpg on cg.IDTipoPreguntaGrupo = ctpg.IDTipoPreguntaGrupo
			where (cg.IDTipoGrupo = @IDTipoGrupo) and (cg.Nombre like '%'+@filter+'%')   and cg.TipoReferencia = 0
				) a
	WHERE [Row] = 1


	select cg.*
		,cp.IDPregunta
		,cp.Descripcion as Pregunta
		,ccp.IDCategoriaPregunta
		,ccp.Nombre as Categoria
		,isnull(cp.IDIndicador, 0) as IDIndicador
		,isnull(indicadores.Nombre, 'Sin indicador') as Indicador
	from #tempGrupos cg
		join [Evaluacion360].[tblCatPreguntas] cp  with (nolock) on cp.IDGrupo = cg.IDGrupo
		left join [Evaluacion360].[tblCatCategoriasPreguntas] ccp  with (nolock) on cp.IDCategoriaPregunta = ccp.IDCategoriaPregunta
		left join [Evaluacion360].[tblCatIndicadores] indicadores  with (nolock) on cp.IDIndicador = indicadores.IDIndicador
GO

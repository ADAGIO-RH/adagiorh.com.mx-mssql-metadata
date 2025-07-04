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
** FechaCreacion	: 2018-09-25
** Paremetros		:    
	TipoReferencia:
		0 : Catálogo
		1 : Asignado a una Prueba
		2 : Asignado a un colaborador
		3 : Asignado a un puesto
		4 : Asignado a una Prueba final para responder
     
	 Cuando el campo TipoReferencia vale 0 (Catálogo) entonces IDReferencia también vale 0    
	 
	 exec [Evaluacion360].[spBuscarCatGrupos] @IDTipoGrupo=1, @IDUsuario=1
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2018-11-26			Aneudy Abreu	Se agregaron los campos IDCategoriaCompetencia y Categoría
***************************************************************************************************/
CREATE proc [Evaluacion360].[spBuscarCatGrupos](
	@IDGrupo int = 0
	,@IDTipoGrupo int = 0
	,@TipoReferencia int = 0
	,@IDReferencia int = 0
	,@IDTipoEvaluacion int = 0
	,@IDUsuario int
	,@PageNumber int = 1
	,@PageSize int = 2147483647
) as
	declare  
	   @IDIdioma Varchar(5)
	   ,@IdiomaSQL varchar(100) = null
	   ,@TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	   ,@TotalRegistrosConPeso decimal(18,2) = 0.00
	   ,@Peso decimal(18,2) = 0.00
	   ,@GrandTotalPeso decimal(18,2) = 0.00
	;
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	SET DATEFIRST 7;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')

    select @IdiomaSQL = [SQL]
    from App.tblIdiomas with (nolock)
    where IDIdioma = @IDIdioma

    if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
    begin
	   set @IdiomaSQL = 'Spanish' ;
    end
  
    SET LANGUAGE @IdiomaSQL;

	if object_id('tempdb..#tempGrupos') is not null drop table #tempGrupos;

	select 
		 cg.IDGrupo
		,cg.IDTipoGrupo
		,ctg.Nombre as TipoGrupo
		,cg.Nombre
		,cg.Descripcion
		,isnull(cg.FechaCreacion,getdate()) as FechaCreacion
		,LEFT(datename(WEEKDAY,isnull(cg.FechaCreacion,getdate())),3)		+' '+
			   convert(VARCHAR(6),isnull(cg.FechaCreacion,getdate()),106)	+' '+
			   convert(varchar(4),datepart(year,isnull(cg.FechaCreacion,getdate()) )) as FechaCreacionStr
		,cg.TipoReferencia
		,cg.IDReferencia
		,isnull(cg.CopiadoDeIDGrupo,0) as CopiadoDeIDGrupo
		,ISNULL(cg.IDTipoPreguntaGrupo,0) as IDTipoPreguntaGrupo
		,ISNULL(ctpg.Nombre,'Sin asignar') as TipoPreguntaGrupo
		--,GrupoEscala = case when exists (select top 1 1 
		--								from [Evaluacion360].[tblCatPreguntas] 
		--							where IDGrupo = cg.IDGrupo and IDTipoPregunta = 8 /*Escala*/)
		--then cast(1 as bit) else cast(0 as bit) end
		,EscalaIndividualStr = case when cg.IDTipoPreguntaGrupo = 3 then STUFF(
																	(   SELECT ', ('+ cast(Valor as varchar(10))+') '+ CONVERT(NVARCHAR(100), Nombre) 
																		FROM [Evaluacion360].[tblEscalasValoracionesGrupos] with (nolock)
																		WHERE IDGrupo = cg.IDGrupo 
																		FOR xml path('')
																	)
																	, 1
																	, 1
																	, '') else null end
		,ROW_NUMBER()over(ORDER BY cg.Nombre asc) as [Row]
		,isnull(cg.IsDefault,0) as IsDefault
		,isnull(cg.Peso,0.00) as Peso
		,isnull(cg.RequerirComentario, 0) as RequerirComentario
		,isnull(cg.IDTipoEvaluacion, 0)  as IDTipoEvaluacion
		,isnull(JSON_VALUE(cte.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')),'[GENERAL]') as TipoEvaluacion
	into #tempGrupos
	from [Evaluacion360].[tblCatGrupos] cg with (nolock)
		join [Evaluacion360].[tblCatTipoGrupo] ctg with (nolock) on cg.IDTipoGrupo = ctg.IDTipoGrupo
		left join [Evaluacion360].[tblCatTiposPreguntasGrupos] ctpg with (nolock) on cg.IDTipoPreguntaGrupo = ctpg.IDTipoPreguntaGrupo
		left join Evaluacion360.tblCatTiposEvaluaciones cte on cte.IDTipoEvaluacion = cg.IDTipoEvaluacion
	where (cg.IDGrupo = @IDGrupo or isnull(@IDGrupo, 0) = 0)
		and (cg.IDTipoGrupo = @IDTipoGrupo or isnull(@IDTipoGrupo, 0) = 0)
		and (cg.IDTipoEvaluacion =  isnull(@IDTipoEvaluacion, 0) or isnull(@IDTipoEvaluacion, 0) = 0)
		and isnull(cg.TipoReferencia, 0) = @TipoReferencia 
		and isnull(cg.IDReferencia, 0) = @IDReferencia
	order by cg.IDGrupo asc

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempGrupos

--	select TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end

	if (@TipoReferencia = 1)
	begin
		select @TotalRegistros			= cast(COUNT(IDGrupo) as decimal(18,2)) from #tempGrupos			
		select @TotalRegistrosConPeso	= cast(COUNT(IDGrupo) as decimal(18,2)) from #tempGrupos where ISNULL(Peso,0.00) > 0.00
		select @GrandTotalPeso			= cast(SUM(Peso)	  as decimal(18,2)) from #tempGrupos where ISNULL(Peso,0.00) > 0.00

		--select @TotalRegistros		   as TotalRegistros
		--	  ,@TotalRegistrosConPeso  as TotalRegistrosConPeso
		--	  ,@GrandTotalPeso		   as GrandTotalPeso

		begin try
			set @Peso = (100.00 - ISNULL(@GrandTotalPeso,0.00)) / (@TotalRegistros - @TotalRegistrosConPeso)
		end try
		begin catch
			set @Peso = 0.00
			print Error_message()
		end catch

		update #tempGrupos
			set Peso = @Peso
		where ISNULL(Peso,0.00) = 0.00
	end;

	select *
	,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempGrupos
		order by IDGrupo asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

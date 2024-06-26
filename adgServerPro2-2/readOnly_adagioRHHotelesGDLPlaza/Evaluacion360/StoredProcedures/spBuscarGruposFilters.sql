USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar Grupos por Nombre
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-10-19
** Paremetros		: @filter
	
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Evaluacion360].[spBuscarGruposFilters]( 
		@filter varchar(255) 
		,@IDTipoGrupo int  = null
		,@TipoReferencia int = null
		,@IDUsuario int) 
as
declare  
	   @IDIdioma Varchar(5)
	   ,@IdiomaSQL varchar(100) = null
	   ,@TotalPaginas int = 0;
 
	SET DATEFIRST 7;

	select top 1 @IDIdioma = dp.Valor
    from Seguridad.tblUsuarios u
	   Inner join App.tblPreferencias p
		  on u.IDPreferencia = p.IDPreferencia
	   Inner join App.tblDetallePreferencias dp
		  on dp.IDPreferencia = p.IDPreferencia
	   Inner join App.tblCatTiposPreferencias tp
		  on tp.IDTipoPreferencia = dp.IDTipoPreferencia
	   where u.IDUsuario = @IDUsuario
		  and tp.TipoPreferencia = 'Idioma'

    select @IdiomaSQL = [SQL]
    from app.tblIdiomas
    where IDIdioma = @IDIdioma

    if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
    begin
	   set @IdiomaSQL = 'Spanish' ;
    end
  
    SET LANGUAGE @IdiomaSQL;

	--if object_id('tempdb..#temp') is not null
	--	drop table #temp;

	--select distinct cg.Nombre
	--INTO #temp
	--from [Evaluacion360].[tblCatGrupos] cg
	--where (cg.IDTipoGrupo = @IDTipoGrupo or @IDTipoGrupo is null) and (cg.Nombre like '%'+@filter+'%')  
	--order by cg.Nombre asc

	SELECT *
	FROM (
			--select 				 
			--	 cg.IDGrupo
			--	,cg.IDTipoGrupo
			--	,ctg.Nombre as TipoGrupo
			--	,cg.Nombre
			--	,cg.Descripcion
			--	,isnull(cg.FechaCreacion,getdate()) as FechaCreacion
			--	,LEFT(DATENAME(WEEKDAY,isnull(cg.FechaCreacion,getdate())),3) + ' ' +
			--	  CONVERT(VARCHAR(6),isnull(cg.FechaCreacion,getdate()),106) 
			--	  + ' '+convert(varchar(4),datepart(year,isnull(cg.FechaCreacion,getdate()) ))
			--	  --' '+convert(varchar(5),cast(isnull(cg.FechaCreacion,getdate()) as time)) 
			--		FechaCreacionStr
			--	,cg.TipoReferencia
			--	,cg.IDReferencia
			--	,isnull(cg.CopiadoDeIDGrupo,0) as CopiadoDeIDGrupo
			--	,GrupoEscala = case when exists (select top 1 1 
			--									from [Evaluacion360].[tblCatPreguntas] with (nolock)
			--									where IDGrupo = cg.IDGrupo and IDTipoPregunta = 8 /*Escala*/)
			--	then cast(1 as bit) else cast(0 as bit) end
			--	--,cp.IDPregunta
			--	--,cp.Descripcion as Pregunta
			--	--,ROW_NUMBER()over(ORDER BY cg.Nombre asc) as [Row]
			--	,ROW_NUMBER() OVER(PARTITION BY cg.Nombre ORDER BY cg.Nombre asc) [Row]
			--from [Evaluacion360].[tblCatGrupos] cg  with (nolock)
			--	join [Evaluacion360].[tblCatTipoGrupo] ctg  with (nolock)  on cg.IDTipoGrupo = ctg.IDTipoGrupo
			----	join [Evaluacion360].[tblCatPreguntas] cp on cp.IDGrupo = cg.IDGrupo
			--	--join #temp t on cg.Nombre = t.Nombre
			--where (cg.IDTipoGrupo = @IDTipoGrupo) and (cg.Nombre like '%'+@filter+'%')   and cg.TipoReferencia = 0
			--order by cg.Nombre asc

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
		  --' '+convert(varchar(5),cast(isnull(cg.FechaCreacion,getdate()) as time)) 
			FechaCreacionStr
		,cg.TipoReferencia
		,cg.IDReferencia
		,isnull(cg.CopiadoDeIDGrupo,0) as CopiadoDeIDGrupo
		,ISNULL(cg.IDTipoPreguntaGrupo,0) as IDTipoPreguntaGrupo
		,ISNULL(ctpg.Nombre,'Sin asignar') as TipoPreguntaGrupo
		--,GrupoEscala = case when exists (select top 1 1 
		--								from [Evaluacion360].[tblCatPreguntas] 
		--							where IDGrupo = cg.IDGrupo and IDTipoPregunta = 8 /*Escala*/)
		--then cast(1 as bit) else cast(0 as bit) end
		--,ROW_NUMBER()over(ORDER BY cg.Nombre asc) as [Row]
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
	from [Evaluacion360].[tblCatGrupos] cg
		join [Evaluacion360].[tblCatTipoGrupo] ctg  on cg.IDTipoGrupo = ctg.IDTipoGrupo
		left join [Evaluacion360].[tblCatTiposPreguntasGrupos] ctpg on cg.IDTipoPreguntaGrupo = ctpg.IDTipoPreguntaGrupo
		--join #temp t on cg.Nombre = t.Nombre
	where 
		(cg.IDTipoGrupo = @IDTipoGrupo or @IDTipoGrupo is null) and 
		(cg.TipoReferencia = @TipoReferencia or @TipoReferencia is null) and 
		(cg.Nombre like '%'+@filter+'%')  and cg.TipoReferencia = 0 
				) a
	WHERE [Row] = 1
GO

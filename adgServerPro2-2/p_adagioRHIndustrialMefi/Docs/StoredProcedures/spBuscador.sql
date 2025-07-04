USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Docs].[spBuscador]-- 1
(
	@IDUsuario int 
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Nombre'
	,@orderDirection varchar(4) = 'asc'
)
AS
BEGIN
	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	;
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Nombre' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 
	
	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end
		
	if OBJECT_ID('tempdb..#tempAprobadores') is not null drop table #tempAprobadores;

	select * ,ROW_NUMBER()OVER(Partition by IDDocumento order by IDAprobadorDocumento)RN
	into #tempAprobadores
	from Docs.tblAprobadoresDocumentos ad
	where( ad.Aprobacion = 0
	OR ad.Aprobacion = 2)
	and ad.Secuencia = (select MAX(Secuencia) from Docs.tblAprobadoresDocumentos where IDDocumento = ad.IDDocumento)

	if OBJECT_ID('tempdb..#tempExpirados') is not null drop table #tempExpirados;

	select * 
	into #tempExpirados
	from Docs.tblCarpetasDocumentos
	where( (ValidoHasta <= getdate()) and Expira = 1)
	
	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  
  

	Select 
	 docs.IDItem
	,docs.TipoItem
	,docs.IDParent
	--,(select top 1 Nombre from Docs.tblCarpetasDocumentos where IDItem = docs.IDParent ) as Parent
	,Parent.Nombre as Parent
	,docs.Nombre
	,docs.FilePath 
	,docs.[Descripcion] 
	,docs.[Version] 
	,docs.[PalabrasClave] 
	,docs.[Comentario] 
	,isnull(docs.[ValidoDesde],'1900-01-01') as [ValidoDesde]
	,isnull(docs.[ValidoHasta],'9999-12-31') as [ValidoHasta] 
	,isnull(docs.[Expira],0) as [Expira] 
	,isnull(docs.[DiasAntesCaducidad],0) as  [DiasAntesCaducidad]
	,isnull(docs.[IDTipoDocumento],0) as [IDTipoDocumento] 
	,isnull(td.[Descripcion],'') as [TipoDocumento] 
	,isnull(docs.[Icono], case when docs.TipoItem = 0 then 'fa fa-folder-open-o' else 'fa fa-file-o' end) as [Icono]
	,isnull(docs.[IDAutor],0) as [IDAutor]
	,isnull(docs.[IDPublicador],0) as [IDPublicador]
	,isnull(docs.[FechaCreacion],getdate()) as [FechaCreacion]
	,isnull(docs.[FechaUltimaActualizacion],getdate()) as [FechaUltimaActualizacion]
	,isnull(docs.[Visualizar],0) as  [Visualizar]
	,isnull(docs.[Descargar],0) as [Descargar] 
	,CAST(CASE WHEN isnull(df.[IDDocumentoFavorito],0) = 0 THEN 0 ELSE 1 END as BIT) as [Favorito] 
	,isnull(docs.[Color],'#000') as [Color]
	,ROW_NUMBER()Over(Order by docs.IDItem asc) as ROWNUMBER
	into #tempResponse
	from Docs.tblCarpetasDocumentos docs
		left join docs.tblCatTiposDocumento td
			on docs.IDTipoDocumento = td.IDTipoDocumento
		left join docs.tblDocumentosFavoritos df
			on df.IDDocumento = docs.IDItem
			and df.IDUsuario = @IDUsuario
		left join Docs.tblCarpetasDocumentos Parent
			on docs.IDParent = Parent.IDItem
		
	where  (docs.IDItem in (select IDDocumento from  Docs.tblDetalleFiltrosDocumentosUsuarios where IDUsuario = @IDUsuario))
	and docs.TipoItem = 1
	and (docs.IDItem not in (select IDDocumento from #tempAprobadores))
	and docs.IDItem not in((select IDItem from #tempExpirados))
	and (@query = '""' or contains(docs.*, @query)) 
	order by Parent.Nombre,docs.Nombre
	--and (((Expira = 1) and getdate() > ( dateadd(DAY,-(DiasAntesCaducidad),[ValidoHasta]))) OR Expira =  0)

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDItem) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'asc'		then Nombre end,			
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'desc'	then Nombre end desc,		
		Nombre asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO

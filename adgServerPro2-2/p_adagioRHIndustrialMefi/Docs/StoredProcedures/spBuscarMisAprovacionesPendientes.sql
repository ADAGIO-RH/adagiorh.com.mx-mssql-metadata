USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Docs].[spBuscarMisAprovacionesPendientes] --1
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



	if OBJECT_ID('tempdb..#tempAprobadores') is not null drop table #tempAprobadores;

	select * ,ROW_NUMBER()OVER(Partition by IDDocumento order by IDAprobadorDocumento asc)RN
	into #tempAprobadores
	from Docs.tblAprobadoresDocumentos ad
	where ad.Aprobacion = 0
	and ad.Secuencia = (select max(Secuencia) from Docs.tblAprobadoresDocumentos where IDDocumento = ad.IDDocumento)
   
    if OBJECT_ID('tempdb..#tempAprobadoresRechazados') is not null drop table #tempAprobadoresRechazados;

	select * ,ROW_NUMBER()OVER(Partition by IDDocumento order by IDAprobadorDocumento asc)RN
	into #tempAprobadoresRechazados
	from Docs.tblAprobadoresDocumentos ad
	where ad.Aprobacion = 2
	and ad.Secuencia = (select max(Secuencia) from Docs.tblAprobadoresDocumentos where IDDocumento = ad.IDDocumento)

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end
   
   	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  
  

	Select 
	 d.IDItem
	,d.TipoItem
	,d.IDParent
	,d.Nombre
	,d.FilePath 
	,d.[Descripcion] 
	,d.[Version] 
	,d.[PalabrasClave] 
	,d.[Comentario] 
	,isnull(d.[ValidoDesde],'1900-01-01') as [ValidoDesde]
	,isnull(d.[ValidoHasta],'9999-12-31') as [ValidoHasta] 
	,isnull(d.[Expira],0) as [Expira] 
	,isnull(d.[DiasAntesCaducidad],0) as  [DiasAntesCaducidad]
	,isnull(d.[IDTipoDocumento],0) as [IDTipoDocumento] 
	,isnull(td.[Descripcion],'') as [TipoDocumento] 
	,isnull(d.[Icono], case when TipoItem = 0 then 'fa fa-folder-open-o' else 'fa fa-file-o' end) as [Icono]
	,isnull(d.[IDAutor],0) as [IDAutor]
	,isnull(d.[IDPublicador],0) as [IDPublicador]
	,isnull(u.Cuenta+' - '+u.Nombre+' '+u.Apellido,'') as [Publicador]
	,isnull(d.[FechaCreacion],getdate()) as [FechaCreacion]
	,isnull(d.[FechaUltimaActualizacion],getdate()) as [FechaUltimaActualizacion]
	,isnull(d.[Visualizar],0) as  [Visualizar]
	,isnull(d.[Descargar],0) as [Descargar] 
	,isnull(d.[Color],'#000') as [Color]
	,ROW_NUMBER()Over(Order by IDItem asc) as ROWNUMBER
	into #tempResponse
	from Docs.tblCarpetasDocumentos d
		left join Docs.tblCatTiposDocumento td
			on d.IDTipoDocumento = td.IDTipoDocumento
		left join Seguridad.tblUsuarios u
			on u.IDUsuario = d.IDPublicador
	where IDItem in (
			select IDDocumento from #tempAprobadores where RN = 1 and IDUsuario = @IDUsuario
		)
		and IDItem not in (
			select IDDocumento from #tempAprobadoresRechazados
		)
		and (@query = '""' or contains(d.*, @query)) 

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

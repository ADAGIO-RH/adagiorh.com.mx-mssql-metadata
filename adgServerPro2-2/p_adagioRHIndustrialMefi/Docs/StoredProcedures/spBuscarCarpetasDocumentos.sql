USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Docs].[spBuscarCarpetasDocumentos]-- @IDItem = 12,@IDUsuario = 1
(
	@IDItem int = 0
	,@IDUsuario int 
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Nombre'
	,@orderDirection varchar(4) = 'asc'
)
AS
BEGIN

SET FMTONLY OFF;
--select @IDItem
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	;
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;


	set @query = case 
				when @query = '""' then '""' 
				when @query is null then '""' 
				when @query = '' then '""'
			else '"'+@query + '*"' end

--select @query

	declare @tempResponse as table (
		 IDItem   int   
		,TipoItem       int
		,IDParent		int    
		,Nombre			varchar(max)      
		,FilePath		varchar(max)      
		,Descripcion    varchar(max)      
		,Version		varchar(max) 
		,PalabrasClave	varchar(max) 
		,Comentario		varchar(max) 
		,ValidoDesde	date
		,ValidoHasta	date
		,Expira	bit
		,DiasAntesCaducidad int
		,IDTipoDocumento int
		,Icono varchar(50)
		,IDAutor int
		,Autor varchar(max)
		,IDPublicador int
		,Publicador Varchar(max)
		,FechaCreacion date
		,FechaUltimaActualizacion date
		,Visualizar  bit
		,Descargar bit
		,Color varchar(max)
	);
	
	insert into @tempResponse
	Select 
	 s.IDItem
	,s.TipoItem
	,s.IDParent
	,s.Nombre
	,s.FilePath 
	,s.[Descripcion] 
	,s.[Version] 
	,s.[PalabrasClave] 
	,s.[Comentario] 
	,s.[ValidoDesde] as [ValidoDesde]
	,s.[ValidoHasta] as [ValidoHasta] 
	,isnull([Expira],0) as [Expira] 
	,isnull([DiasAntesCaducidad],0) as  [DiasAntesCaducidad]
	,isnull([IDTipoDocumento],0) as [IDTipoDocumento] 
	,isnull([Icono], case when TipoItem = 0 then 'fa fa-folder-open-o' else 'fa fa-file-o' end) as [Icono]
	,isnull([IDAutor],0) as [IDAutor]
	,isnull(u.Cuenta+' - '+u.Nombre+' '+u.Apellido,'') as [Autor]
	,isnull([IDPublicador],0) as [IDPublicador]
	,isnull(ua.Cuenta+' - '+ua.Nombre+' '+ua.Apellido,'') as [Publicador]
	,isnull([FechaCreacion],getdate()) as [FechaCreacion]
	,isnull([FechaUltimaActualizacion],getdate()) as [FechaUltimaActualizacion]
	,isnull([Visualizar],0) as  [Visualizar]
	,isnull([Descargar],0) as [Descargar] 
	,isnull([Color],'#000') as [Color]
	from Docs.tblCarpetasDocumentos s
	left join Seguridad.tblUsuarios u
			on s.IDAutor = u.IDUsuario
		left join Seguridad.tblUsuarios ua
			on s.IDPublicador = ua.IDUsuario
	where ((IDParent = @IDItem) or (Isnull(@IDItem,0) = 0))
		and (@query = '""' or contains(s.*, @query)) 
	
	--select * from @tempResponse

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT([IDItem]) as decimal(18,2)) from @tempResponse	
	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'asc'		then Nombre end,			
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'desc'	then Nombre end desc,			
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'desc'	then Descripcion end desc,			
		case when @orderByColumn = 'PalabrasClave'	and @orderDirection = 'asc'		then PalabrasClave end,		
		case when @orderByColumn = 'PalabrasClave'	and @orderDirection = 'desc'	then PalabrasClave end desc,		
		case when @orderByColumn = 'Comentario'			and @orderDirection = 'asc'		then Comentario end,				
		case when @orderByColumn = 'Comentario'			and @orderDirection = 'desc'	then Comentario end desc,				
		Nombre asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO

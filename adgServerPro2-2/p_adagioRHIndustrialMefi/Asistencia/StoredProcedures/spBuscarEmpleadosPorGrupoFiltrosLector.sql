USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [Asistencia].[spBuscarEmpleadosPorGrupoFiltrosLector] --@IDLector = 8
(      
	@IDGrupoFiltrosLector int = 0 
	,@IDLector int
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'ClaveEmpleado'
	,@orderDirection varchar(4) = 'asc'
) as      
	 SET LANGUAGE 'Spanish';      
      
	   SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	;
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else '"'+@query + '*"' end

	if object_id('tempdb..#tempEmpleados') is not null drop table #tempEmpleados;                  
        
      

	 select DFEU.IDLectorEmpleado      
		,DFEU.IDLector      
		,DFEU.IDEmpleado      
		,em.ClaveEmpleado
		,isnull(SUBSTRING(em.Nombre, 1, 1) + SUBSTRING(em.Paterno, 1, 1),'') as Iniciales
		,em.NOMBRECOMPLETO      
		,em.Departamento      
		,em.Sucursal      
		,em.Puesto      
		,CASE WHEN isnull(DFEU.IDGrupoFiltrosLector,0) = 0 THEN 'Asignación Directa' ELSE GPL.Nombre END as Filtro 
		,cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as int) as varchar(20)) as PIN	
		,coalesce(em.Nombre,'')+' '+coalesce(em.Paterno, '') as UserName
        ,(select CAST((CASE WHEN (count(*) > 0) THEN 1 ELSE 0 END) as bit) from zkteco.tblTmpFP		with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = l.NumeroSerial) as FP									
        ,(select CAST((CASE WHEN (count(*) > 0) THEN 1 ELSE 0 END) as bit) from zkteco.tblTmpFace	with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = l.NumeroSerial) as Face	
        ,(select CAST((CASE WHEN (count(*) > 0) THEN 1 ELSE 0 END) as bit) from zkteco.tblTmpBioData	with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = l.NumeroSerial) as BioData	
        ,(select CAST((CASE WHEN (count(*) > 0) THEN 1 ELSE 0 END) as bit) from zkteco.tblTmpUserPic	with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = l.NumeroSerial) as UserPic	
		,(select CAST((CASE WHEN ISNULL(Passwd,'')<> '' THEN 1 ELSE 0 END) as bit) from zkteco.tblUserInfo	with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = l.NumeroSerial) as [Password]
        ,(select CAST((CASE WHEN ISNULL(IDCard,'')<> '' THEN 1 ELSE 0 END) as bit) from zkteco.tblUserInfo	with(nolock) where PIN = cast(cast(stuff(em.ClaveEmpleado, 1, patindex('%[0-9]%', em.ClaveEmpleado)-1, '') as bigint) as varchar(20)) and DevSN = l.NumeroSerial) as [Card]
		into #tempEmpleados
	 from [Asistencia].[tblLectoresEmpleados] DFEU with(nolock)
		join [RH].[tblEmpleadosMaster] em with(nolock) on DFEU.IDEmpleado = em.IDEmpleado   
		join [Asistencia].[tblLectores] L with(nolock) on L.IDLector = DFEU.IDLector
		left join [Asistencia].[tblGrupoFiltrosLector] gpl with(nolock)
			on gpl.IDGrupoFiltrosLector = DFEU.IDGrupoFiltrosLector
	where ((DFEU.IDGrupoFiltrosLector = @IDGrupoFiltrosLector)  OR (ISNULL(@IDGrupoFiltrosLector,0) = 0))
	and ((DFEU.IDLector = @IDLector)  OR (ISNULL(@IDLector,0) = 0))
	 and (@query = '""' or contains(em.*, @query)) 

	 select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempEmpleados

	select @TotalRegistros = cast(COUNT([IDEmpleado]) as decimal(18,2)) from #tempEmpleados		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from #tempEmpleados
	order by 
		case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'asc'		then ClaveEmpleado end,			
		case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'desc'	then ClaveEmpleado end desc,			
		case when @orderByColumn = 'NOMBRECOMPLETO'	and @orderDirection = 'asc'		then NOMBRECOMPLETO end,			
		case when @orderByColumn = 'NOMBRECOMPLETO'	and @orderDirection = 'desc'	then NOMBRECOMPLETO end desc,			
		case when @orderByColumn = 'Departamento'	and @orderDirection = 'asc'		then Departamento end,		
		case when @orderByColumn = 'Departamento'	and @orderDirection = 'desc'	then Departamento end desc,		
		case when @orderByColumn = 'Sucursal'			and @orderDirection = 'asc'		then Sucursal end,				
		case when @orderByColumn = 'Sucursal'			and @orderDirection = 'desc'	then Sucursal end desc,				
		case when @orderByColumn = 'Puesto'			and @orderDirection = 'asc'		then Puesto end,				
		case when @orderByColumn = 'Puesto'			and @orderDirection = 'desc'	then Puesto end desc,				
		ClaveEmpleado asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

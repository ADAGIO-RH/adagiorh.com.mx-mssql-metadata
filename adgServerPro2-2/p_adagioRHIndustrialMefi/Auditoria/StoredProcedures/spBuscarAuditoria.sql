USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Auditoria].[spBuscarAuditoria](
    @IDAuditoria int =0
    ,@Accion varchar(20)=null
	,@IDUsuarios varchar(20)=null
	,@IDEmpleados varchar(20)=null
	,@FechaIni datetime = null
	,@FechaFin datetime = null
	,@IDUsuarioLogin int = 1
    ,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Fecha'
	,@orderDirection varchar(4) = 'asc'
) as
	
    SET FMTONLY OFF;  
	declare  
        @TotalPaginas int = 0
	    ,@TotalRegistros int
	    ,@IDIdioma varchar(max);
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuarioLogin, 'esmx')
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Fecha' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	
	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse ;
	    		
	-- set @query = case 
	-- 			when @query is null then '""' 
	-- 			when @query = '' then '""'
	-- 			when @query = '""' then '""'
	-- 		else '"'+@query + '*"' end
    	
	select 
		 a.IDAuditoria
		,a.IDUsuario
		,u.Cuenta as CuentaUsuario
		,coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'') as NombreUsuario
		,u.IDPerfil
		,p.Descripcion as Perfil
		,u.Email as EmailUsuario
		,a.Fecha
		,a.Tabla
		,a.Procedimiento
		,a.Accion
		,a.NewData
		,a.OldData
		,isnull(a.IDEmpleado,0) as IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO as Colaborador
		,e.Departamento
		,e.Sucursal
		,e.Puesto
		,a.Mensaje
		,a.InformacionExtra,
        Utilerias.fnGetUrlFotoUsuario(u.Cuenta) as UrlFotoUsuario, 
        Utilerias.fnGetUrlFotoUsuario(e.ClaveEmpleado) as UrlFotoEmpleado
        into #tempResponse
	from Auditoria.tblAuditoria a with (nolock)
		join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = a.IDUsuario
		join Seguridad.tblCatPerfiles p with (nolock) on p.IDPerfil = u.IDPerfil
		left join RH.tblEmpleadosMaster e with (nolock) on e.IDEmpleado = a.IDEmpleado
	where
    --  (a.IDUsuario = @IDUsuario or @IDUsuario = 0)
	-- 	and (a.IDEmpleado = @IDEmpleado or @IDEmpleado = 0)
		
        (a.IDAuditoria= @IDAuditoria) or (
            (a.Fecha between @FechaIni and @FechaFin)
            AND (a.IDUsuario in (Select ITEM FROM App.Split(@IDUsuarios,',')) OR (isnull(@IDUsuarios,'') = '')) 
            AND (e.IDEmpleado in (Select ITEM FROM App.Split(@IDEmpleados,',')) OR (isnull(@IDEmpleados,'') = '')) 
            AND (a.Accion = @Accion or isnull(@Accion,'')='')
        )


	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDAuditoria) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Accion'			and @orderDirection = 'asc'		then Accion end,			
		case when @orderByColumn = 'Accion'			and @orderDirection = 'desc'	then Accion end desc,
        case when @orderByColumn = 'Fecha'			and @orderDirection = 'asc'		then Fecha end,			
		case when @orderByColumn = 'Fecha'			and @orderDirection = 'desc'	then Fecha end desc,
        case when @orderByColumn = 'Tabla'			and @orderDirection = 'asc'		then Tabla end,			
		case when @orderByColumn = 'Tabla'			and @orderDirection = 'desc'	then Tabla end desc,
        case when @orderByColumn = 'Procedimiento'			and @orderDirection = 'asc'		then Procedimiento end,			
		case when @orderByColumn = 'Procedimiento'			and @orderDirection = 'desc'	then Procedimiento end desc,
        case when @orderByColumn = 'Empleado'			and @orderDirection = 'asc'		then Colaborador end,			
		case when @orderByColumn = 'Empleado'			and @orderDirection = 'desc'	then Colaborador end desc,
        case when @orderByColumn = 'Usuario'			and @orderDirection = 'asc'		then NombreUsuario end,			
		case when @orderByColumn = 'Usuario'			and @orderDirection = 'desc'	then NombreUsuario end desc,

		Accion asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCatSucursales](      
	@IDSucursal int = null    
	,@IDUsuario int =null
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Codigo'
	,@orderDirection varchar(4) = 'asc'
    ,@ValidarFiltros bit =1 
)      
AS      
BEGIN     
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

	declare @TempSucursales as table (
		ID int
	)
  
	insert @TempSucursales
	select ID   
	from Seguridad.tblFiltrosUsuarios   
	where IDUsuario = @IDUsuario and Filtro = 'Sucursales'  
   
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
				else '"'+@query + '*"' end

	declare @tempResponse as table (
		 IDSucursal   int   
		,Codigo       varchar(20)
		,Descripcion  varchar(50)    
		,CuentaContable varchar(20)      
		,IDCodigoPostal int      
		,CodigoPostal   varchar(50)   
		,IDEstado       int
		,Estado			varchar(100)
		,IDMunicipio    int  
		,Municipio      varchar(100)
		,IDColonia      int
		,Colonia      	varchar(100)
		,IDPais			int
		,Pais      		varchar(100)
		,Calle      	varchar(100)
		,Exterior      	varchar(20)
		,Interior      	varchar(20)
		,Telefono    	varchar(20)
		,Responsable    varchar(100)  
		,Email      	varchar(100)
		,ClaveEstablecimiento   varchar(50)   
		,IDEstadoSTPS      int
		,EstadoSTPS      varchar(100)
		,IDMunicipioSTPS int     
		,MunicipioSTPS   varchar(100)   
		,Latitud float
		,Longitud float
		,Fronterizo bit 
	);
	
	insert @tempResponse
	SELECT       
		S.IDSucursal      
		,S.Codigo       
		,S.Descripcion       
		,S.CuentaContable      
		,isnull(S.IDCodigoPostal,0) as IDCodigoPostal      
		,CP.CodigoPostal      
		,isnull(S.IDEstado,0) as IDEstado      
		,'['+E.Codigo+'] '+E.NombreEstado as Estado      
		,isnull(S.IDMunicipio,0) as IDMunicipio      
		,'['+M.Codigo+'] '+M.Descripcion as Municipio      
		,isnull(S.IDColonia,0) as IDColonia      
		,'['+CL.Codigo+'] '+CL.NombreAsentamiento as Colonia      
		,isnull(S.IDPais,0) as IDPais      
		,'['+P.Codigo+'] '+P.Descripcion as Pais      
		,S.Calle      
		,S.Exterior      
		,S.Interior      
		,S.Telefono    
		,S.Responsable      
		,S.Email      
		,S.ClaveEstablecimiento      
		,isnull(S.IDEstadoSTPS,0) as IDEstadoSTPS      
		,'['+STPSEstados.Codigo+'] '+STPSEstados.Descripcion as EstadoSTPS      
		,isnull(S.IDMunicipioSTPS,0) as IDMunicipioSTPS      
		,'['+STPSMunicipios.Codigo+'] '+STPSMunicipios.Descripcion as MunicipioSTPS 
		,isnull(S.Latitud, 19.435717) as Latitud
		,isnull(S.Longitud, -99.073410) as Longitud
		,Cast(isnull(S.Fronterizo,0) as bit) as Fronterizo
	FROM [RH].[tblCatSucursales] S with (nolock)     
		left join Sat.tblCatCodigosPostales CP with (nolock) on S.IDCodigoPostal = CP.IDCodigoPostal      
		left join Sat.tblCatPaises P with (nolock) on S.IDPais = p.IDPais      
		left join Sat.tblCatEstados E with (nolock) on S.IDEstado = E.IDEstado      
		left join Sat.tblCatMunicipios M with (nolock) on S.IDMunicipio = m.IDMunicipio      
		left join Sat.tblCatColonias CL with (nolock) on S.IDColonia = CL.IDColonia      
		Left Join STPS.tblCatEstados STPSEstados with (nolock) on S.IDEstadoSTPS = STPSEstados.IDEstado      
		Left Join STPS.tblCatMunicipios STPSMunicipios with (nolock) on S.IDMunicipioSTPS = STPSMunicipios.IDMunicipio      
	WHERE ((S.IDSucursal = @IDSucursal or isnull(@IDSucursal,0) = 0))      
		and (S.IDSucursal in (select ID from @TempSucursales) or not exists(select ID from @TempSucursales) or @ValidarFiltros=0)  
		and (@query = '""' or contains(s.*, @query)) 
	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT([IDSucursal]) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'asc'		then Codigo end,			
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'desc'	then Codigo end desc,			
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'desc'	then Descripcion end desc,			
		case when @orderByColumn = 'Responsable'	and @orderDirection = 'asc'		then Responsable end,		
		case when @orderByColumn = 'Responsable'	and @orderDirection = 'desc'	then Responsable end desc,		
		case when @orderByColumn = 'Email'			and @orderDirection = 'asc'		then Email end,				
		case when @orderByColumn = 'Email'			and @orderDirection = 'desc'	then Email end desc,				
		Codigo asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO

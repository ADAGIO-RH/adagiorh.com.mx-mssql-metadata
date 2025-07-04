USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Obtiene las solicitudes de prestamos, añadiendole paginación y datos adicionales requeridos en 
                        la nueva intranet
** Autor			: Jose Vargas   
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2022-11-22
** Paremetros		:                                   
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/

CREATE proc [Intranet].[spBuscarSolicitudesPrestamosNuevaIntranet](	
	@IDUsuario int,
    @PageNumber	int = 1,
	@PageSize		int = 2147483647,
	@query			varchar(100) = '""',
	@orderByColumn	varchar(50) = 'TipoSolicitud',
	@orderDirection varchar(4) = 'asc',
    @dtFiltros [Nomina].[dtFiltrosRH]  READONLY             
) as
declare @IDSolicitudPrestamo int,
            @IDEmpleado int ,
            @IDEstatusSolicitudPrestamo int ,
		    @IDTipoSolicitud VARCHAR(MAX),
            @IDIdioma varchar(225),
            @FechaIni date,  
            @FechaFin date

 

    set @IDSolicitudPrestamo = isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDSolicitudPrestamo'),0)
    set @IDEmpleado = isnull((Select top 1 Value from @dtFiltros where Catalogo = ' '),0)
    SET @IDTipoSolicitud = isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDTipoSolicitud'),'')
    set @IDEstatusSolicitudPrestamo= isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDEstatusSolicitudPrestamo'),0)    

    Select  @FechaIni=isnull(Value,null) from @dtFiltros where Catalogo = 'FechaIni'
    Select  @FechaFin=isnull(Value,null) from @dtFiltros where Catalogo = 'FechaFin'

    declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int = 0
	;
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

    set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
				else '"'+@query + '*"' end

    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');  

	declare @tempResponse as table (
        IDSolicitudPrestamo     int   
        ,IDEmpleado             int      
        ,ClaveEmpleado          varchar(100)   
        ,Colaborador            varchar(100)   
        ,Sucursal               varchar(100)       
        ,Puesto                 varchar(100)   
        ,Departamento           varchar(100)   
        ,IDTipoPrestamo         int    
        ,TipoPrestamo           varchar(100)    
        ,MontoPrestamo          decimal(10,2)
        ,Cuotas                 decimal(10,2)
        ,CantidadCuotas         int
        ,FechaCreacion          date
        ,FechaInicioPago        date
        ,Autorizado             bit
        ,IDUsuarioAutorizo      int 
        ,FechaHoraAutorizacion  datetime 
        ,Cancelado              bit
        ,IDUsuarioCancelo int
        ,FechaHoraCancelacion  datetime         
        ,MotivoCancelacion      varchar(max)
        ,IDPrestamo             int 
        ,Descripcion    varchar(max)
        ,Intereses              decimal(10,2)
        ,IDEstatusSolicitudPrestamo int  
        ,Estatus                varchar(50)
        ,CssClass               varchar(100)
        ,VueBindingStyle        varchar(max)
        ,IDFondoAhorro          int 
        ,IDEstatusPrestamo      int
        ,EstatusPrestamo        varchar(50)                
	);
	

    insert into @tempResponse
	select 
		sp.IDSolicitudPrestamo
		,sp.IDEmpleado
		,e.ClaveEmpleado
		,e.NOMBRECOMPLETO as Colaborador
        ,e.Sucursal        
        ,e.Puesto
        ,e.Departamento
		,sp.IDTipoPrestamo
		,ctp.Descripcion as TipoPrestamo
		,isnull(sp.MontoPrestamo,0.00) as MontoPrestamo
		,isnull(sp.Cuotas, 0) as Cuotas
		,sp.CantidadCuotas
		,sp.FechaCreacion
		,sp.FechaInicioPago
		,sp.Autorizado
		,isnull(sp.IDUsuarioAutorizo,0) as IDUsuarioAutorizo
		,sp.FechaHoraAutorizacion
		,sp.Cancelado
		,isnull(sp.IDUsuarioCancelo,0) as IDUsuarioCancelo	   
		,sp.FechaHoraCancelacion
		,sp.MotivoCancelacion
		,isnull(sp.IDPrestamo,0) as IDPrestamo		   
		,sp.Descripcion
		,isnull(sp.Intereses,0.00) as Intereses		
		,sp.IDEstatusSolicitudPrestamo
		,cesp.Nombre as Estatus
		,cesp.CssClass
        ,cesp.VueBindingStyle
		,isnull(sp.IDFondoAhorro,0) as IDFondoAhorro	
		,isnull(sp.IDEstatusPrestamo, 0) as IDEstatusPrestamo
		,isnull(cep.Descripcion, 'Sin estatus préstamo') as EstatusPrestamo
	from [Intranet].[tblSolicitudesPrestamos] sp					with (nolock)
		join [RH].[tblEmpleadosMaster] e							with (nolock) on e.IDEmpleado					= sp.IDEmpleado
		join [Nomina].[tblCatTiposPrestamo] ctp						with (nolock) on ctp.IDTipoPrestamo				= sp.IDTipoPrestamo
		join [Intranet].[tblCatEstatusSolicitudesPrestamos] cesp	with (nolock) on cesp.IDEstatusSolicitudPrestamo = sp.IDEstatusSolicitudPrestamo 		
		left join [Nomina].[tblCatEstatusPrestamo] cep				with (nolock) on cep.IDEstatusPrestamo			= sp.IDEstatusPrestamo
	where (sp.IDSolicitudPrestamo = isnull(@IDSolicitudPrestamo, 0) or isnull(@IDSolicitudPrestamo, 0) = 0)		
	order by sp.FechaCreacion desc

    select @TotalRegistros = cast(COUNT([IDSolicitudPrestamo]) as int) from @tempResponse		
    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2))) from @tempResponse
	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
        ,TotalRows = @TotalRegistros
	from @tempResponse
	order by 		
        case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'asc'		then ClaveEmpleado end,			
		case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'desc'	then ClaveEmpleado end desc								        
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

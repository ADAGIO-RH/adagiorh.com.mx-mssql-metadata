USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jose Vargas
-- Create date: 2022-01-27
-- Description: Busqueda de solicitudes de intranet y prestamos, filtrando por IDusuario: 
--              validando solamente a las que tiene permitido ver 
--              * (si es supervisor podra acceder a los usuarios de sus filtros)  
--              * Las de sus subordinados
-- Andrea Zainos 23-06-2023
-- Cambio para que el resumen se vea dentro de las solicitudes del Empleado
-- Julio Castillo 03/11/2023
-- Se le agrego una validacion para que no muestre las solicitudes del colaborador en la vista de autorizaciones
-- =============================================
CREATE Procedure [Intranet].[spBuscarSolicitudesGeneral] 
( 
	@IDUsuario int 
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'TipoSolicitud'
	,@orderDirection varchar(4) = 'asc'
    ,@dtFiltros [Nomina].[dtFiltrosRH]  READONLY             
)
AS
BEGIN
    
    declare @IsSupervisor bit,
            @IDEmpleado int ,
            @IDEstatusSolicitudPrestamo int ,
		    @IDTipoSolicitud VARCHAR(100),
            @IDTipoSolicitudesPermitidas VARCHAR(100),            
            @IDIdioma varchar(225),
            @FechaIni date=null,  
            @FechaFin date=null,
            @queryForLike varchar(100) =@query,
            @IDEmpleadoUsuario int,
            @ExcluirUsuario bit 

    select         
        @IsSupervisor=Supervisor,        
        @IDUsuario= IDUsuario 
    From Seguridad.tblUsuarios u where 
    u.IDUsuario=@IDUsuario 


    set @ExcluirUsuario = cast(isnull((Select top 1 Value from @dtFiltros where Catalogo = 'ExcluirUsuario'),0) as bit)
    set @IDEmpleadoUsuario = isnull((Select top 1 IDEmpleado from Seguridad.tblUsuarios where IDUsuario = @IDUsuario),0)
    set @IDEmpleado = isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDEmpleado'),0)
    SET @IDTipoSolicitud = isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDTipoSolicitud'),'')
    set @IDEstatusSolicitudPrestamo= isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDEstatusSolicitudPrestamo'),0)    
    set @IDTipoSolicitudesPermitidas= isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDTipoSolicitudesPermitidas'),'')    



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
		 IDSolicitud   int   
        ,IDTipoSolicitud       int
		,TipoSolicitud      varchar(100)    
		,Folio              varchar(20)      
		,IDEmpleado         int      
		,ClaveEmpleado      varchar(100)   
		,Colaborador        varchar(100)   
		,Iniciales	        varchar(5)
		,IDTipoPrestamo     int  
		,TipoPrestamo       varchar(30)
		,FechaIni           date
        ,FechaFin           date
        ,MontoPrestamo      decimal(10,2)
		,Cuotas			    decimal(10,2)
		,CantidadDiasOCuotas     int
		,FechaCreacion      date
        ,IDEstatusSolicitud int 
		,EstatusSolicitud   varchar(20)
		,CssClass      	    varchar(100)
        ,VueBindingStyle    varchar(max)
        ,EstatusPrestamo    varchar(50)  				
        ,DiasDescanso       varchar(50)  				
        ,Motivo       varchar(max)  				
        ,Resumen       varchar(max)  				
	);
	
    
    

    insert into @tempResponse
    SELECT 
        SE.IDSolicitud
        , ts.IDTipoSolicitud
        ,JSON_VALUE(TS.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as TipoSolicitud
        ,'S'+ cast(SE.IDSolicitud as Varchar(10)) as Folio
        ,SE.IDEmpleado
        ,M.ClaveEmpleado
        ,M.NOMBRECOMPLETO as Colaborador
        ,SUBSTRING (M.Nombre, 1, 1) + SUBSTRING (M.Paterno, 1, 1)  as Iniciales
        , 0 as [IDTipoPrestamo]
        , '' as [TipoPrestamo]
        ,isnull(SE.FechaIni,'9999-12-31') as FechaIni
        ,ISNULL(SE.FechaFin, '9999-12-31') AS FechaFin
        ,0.00 as MontoPrestamo        
        ,0.00 as Cuotas
        ,isnull(se.CantidadDias,0) as CantidadDiasOCuotas            
        ,SE.FechaCreacion
        ,cesp.IDEstatusSolicitudPrestamo as IDEstatusSolicitud
        ,JSON_VALUE(cesp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as EstatusSolicitud
        ,cesp.CssClass
        ,cesp.VueBindingStyle            
        ,'' as EstatusPrestamo
        , isnull(SE.DiasDescanso,'') as DiasDescanso
        , case when se.IDTipoSolicitud =2 then JSON_VALUE(I.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))  -- Permisos -> Mostrar Incidencia
            when se.IDTipoSolicitud=3 then isnull(se.ComentarioEmpleado,'')  -- Actualizacion datos -> mostrar el motivo de cambio
            else '' end [Motivo] 
        , case when se.IDTipoSolicitud =2 then JSON_VALUE(I.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) + ' DIAS SOLICITADOS:  '+cast (isnull(SE.CantidadDias,'') as VARCHAR ) -- Permisos -> Mostrar Incidencia
            when se.IDTipoSolicitud=3 then UPPER(isnull(se.ComentarioEmpleado,'') ) -- Actualizacion datos -> mostrar el motivo de cambio
            else '' end [Resumen] 
    FROM Intranet.tblSolicitudesEmpleado SE WITH(NOLOCK)
        INNER JOIN 
            RH.tblEmpleadosMaster M WITH(NOLOCK) on SE.IDEmpleado = M.IDEmpleado        
        INNER JOIN 
            Intranet.tblCatTipoSolicitud TS WITH(NOLOCK) on TS.IDTipoSolicitud = SE.IDTipoSolicitud                        
        INNER JOIN 
            [Intranet].[tblCatEstatusSolicitudesPrestamos] cesp with (nolock) on cesp.IDEstatusSolicitudReferencia = SE.IDEstatusSolicitud        
        LEFT JOIN 
            Asistencia.tblCatIncidencias I WITH(NOLOCK) on SE.IDIncidencia = I.IDIncidencia
        inner JOIN 
            Utilerias.fnBuscarFiltrosEmpleadosIfSupervisorYJefeEmpleados(@IDUsuario) dt on dt.IDEmpleado=m.IDEmpleado
    where (( @FechaFin is null or @FechaIni is null ) or (SE.FechaIni  BETWEEN @FechaIni and @FechaFin and @IDEmpleado=0 )  or (@IDEmpleado<>0))  
            AND (@IDEmpleado =0  or se.IDEmpleado=@IDEmpleado)
            and (
                ( ts.IDTipoSolicitud in(select item from app.Split(@IDTipoSolicitud,','))or @IDTipoSolicitud='') and 
                ( ts.IDTipoSolicitud  in(select item from app.Split(@IDTipoSolicitudesPermitidas,','))or @IDTipoSolicitudesPermitidas='')            
            )
            AND (cesp.IDEstatusSolicitudPrestamo =@IDEstatusSolicitudPrestamo or @IDEstatusSolicitudPrestamo =0) 
            AND (
                    (@query = '""' or contains(m.*, @query)) OR
                    (  'S'+cast(se.IDSolicitud as varchar(10))   like '%'+ @queryForLike +'%' or isnull(@queryForLike,'')='')                    
                )
            AND M.Vigente =1            
    UNION
    select 
        spj.IDSolicitudPrestamo
        , 4 as IDTipoSolicitud
        ,JSON_VALUE(TS.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as TipoSolicitud
        ,'P'+ cast(spj.IDSolicitudPrestamo as Varchar(10)) as Folio            
        ,spj.IDEmpleado
        ,m.ClaveEmpleado
        ,m.NOMBRECOMPLETO as Colaborador
        ,SUBSTRING (m.Nombre, 1, 1) + SUBSTRING (m.Paterno, 1, 1)  as Iniciales            
        ,spj.IDTipoPrestamo
        ,JSON_VALUE(ctp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as TipoPrestamo                                        
        ,isnull(spj.FechaInicioPago,  '9999-12-31') as FechaIni                        
        ,getdate() as FechaFin                        
        ,isnull(spj.MontoPrestamo,0.00) as MontoPrestamo        
        ,isnull(spj.Cuotas, 0) as Cuotas
        ,spj.CantidadCuotas            
        ,spj.FechaCreacion  
        ,cesp.IDEstatusSolicitudPrestamo as IDEstatusSolicitud                                                                                                                                 
        ,JSON_VALUE(cesp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as EstatusSolicitud
        ,cesp.CssClass
        ,cesp.VueBindingStyle            
        ,isnull(cep.Descripcion, 'Sin estatus préstamo') as EstatusPrestamo
        , '' as DiasDescanso
        , '' as [Motivo]
        , 'MONTO SOLICITADO: $ ' +  cast(isnull(spj.MontoPrestamo,0.00) as varchar) as [Resumen] 
    from [Intranet].[tblSolicitudesPrestamos] spj with (nolock)
        INNER JOIN 
            [RH].[tblEmpleadosMaster] m with (nolock) on m.IDEmpleado = spj.IDEmpleado
        INNER JOIN 
            Intranet.tblCatTipoSolicitud TS WITH(NOLOCK) on TS.IDTipoSolicitud = 4                            
        INNER JOIN 
            [Nomina].[tblCatTiposPrestamo] ctp with (nolock) on ctp.IDTipoPrestamo = spj.IDTipoPrestamo
        INNER JOIN 
            [Intranet].[tblCatEstatusSolicitudesPrestamos] cesp with (nolock) on cesp.IDEstatusSolicitudPrestamo = spj.IDEstatusSolicitudPrestamo             
        left join 
            [Nomina].[tblCatEstatusPrestamo] cep on cep.IDEstatusPrestamo = spj.IDEstatusPrestamo 
        INNER JOIN 
            Utilerias.fnBuscarFiltrosEmpleadosIfSupervisorYJefeEmpleados(@IDUsuario) dt on dt.IDEmpleado=m.IDEmpleado
    where  ((@FechaFin is null or @FechaIni is null ) OR (spj.FechaInicioPago  BETWEEN @FechaIni and @FechaFin and @IDEmpleado =0 )  or (@IDEmpleado<>0)) 
    AND  (@IDEmpleado =0  or spj.IDEmpleado=@IDEmpleado)
            and (
                (4 in(select item from app.Split(@IDTipoSolicitud,','))or @IDTipoSolicitud='') and 
                ( 4  in (select item from app.Split(@IDTipoSolicitudesPermitidas,',')) or @IDTipoSolicitudesPermitidas='')                        
            )
            AND (cesp.IDEstatusSolicitudPrestamo =@IDEstatusSolicitudPrestamo or @IDEstatusSolicitudPrestamo =0) 
            AND (
                    (@query = '""' or contains(m.*, @query)) OR
                    ('P'+cast(spj.IDSolicitudPrestamo as varchar(10))   like '%'+ @queryForLike +'%' or isnull(@queryForLike,'')='')                                        
                )
            AND M.Vigente =1      
            
                                                      
    select @TotalRegistros = cast(COUNT([IDSolicitud]) as int) from @tempResponse		
    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2))) from @tempResponse

    IF ( @ExcluirUsuario = 1 )
    begin
    delete from @tempResponse where IDEmpleado = @IDEmpleadoUsuario
    end 

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
        ,TotalRows = @TotalRegistros
	from @tempResponse
	order by 
		case when @orderByColumn = 'TipoSolicitud'			and @orderDirection = 'asc'		then TipoSolicitud end,			
		case when @orderByColumn = 'TipoSolicitud'			and @orderDirection = 'desc'	then TipoSolicitud end desc,
        case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'asc'		then ClaveEmpleado end,			
		case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'desc'	then ClaveEmpleado end desc	,									
        case when @orderByColumn = 'Folio'			and @orderDirection = 'asc'		then Folio end,			
		case when @orderByColumn = 'Folio'			and @orderDirection = 'desc'	then Folio end desc										
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
     
END
GO

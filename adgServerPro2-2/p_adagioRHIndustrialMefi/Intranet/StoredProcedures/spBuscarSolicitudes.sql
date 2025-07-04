USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Intranet].[spBuscarSolicitudes]
( 
	@IDUsuario int 
	,@dtPagination [Nomina].[dtFiltrosRH] READONLY              
    ,@dtFiltros [Nomina].[dtFiltrosRH]  READONLY             
)
AS
BEGIN
    declare  
        @IDEmpleado int,
        @IDEstatus int ,
		@IDTipoSolicitud VARCHAR(MAX),
		@IDSolicitud int,
		@IDIdioma varchar(225),		 
	    @orderByColumn	varchar(50) = 'ClaveRuta',
	    @orderDirection varchar(4) = 'asc',
        
        @FechaIni date,  
		@FechaAbsoluta date,
        @FechaFin date,
		@BanderaGetVacaciones bit


    
            
    SET @IDEmpleado = isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDEmpleado'),0)
    SET @IDTipoSolicitud = isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDTipoSolicitud'),'')
    set @IDEstatus= isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDEstatus'),0)
	set @IDSolicitud= isnull((Select top 1 Value from @dtFiltros where Catalogo = 'IDSolicitud'),0)
	Set @BanderaGetVacaciones =ISNULL((Select top 1 Value from @dtFiltros where Catalogo = 'BanderaGetVacaciones'),1)
    

    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');  
    
    Select  @orderByColumn=isnull(Value,'IDEmpleado') from @dtPagination where Catalogo = 'orderByColumn'
    Select  @orderDirection=isnull(Value,'asc') from @dtPagination where Catalogo = 'orderDirection'

    Select  @FechaIni=isnull(Value,null) from @dtFiltros where Catalogo = 'FechaIni'
    Select  @FechaFin=isnull(Value,null) from @dtFiltros where Catalogo = 'FechaFin'
  Select  @FechaAbsoluta=isnull(Value,null) from @dtFiltros where Catalogo = 'FechaAbsoluta'
    --SELECT  @BuscarTipoFecha
    IF OBJECT_ID(N'tempdb..#tempSetPagination') IS NOT NULL
    BEGIN
        DROP TABLE #tempSetPagination
    END

    
    
    select *  ,
    ROW_NUMBER()Over(Order by  
                                    case when @orderByColumn = 'FechaIni'			and @orderDirection = 'asc'		then Fecha end ,
                                    case when @orderByColumn = 'FechaIni'			and @orderDirection = 'desc'		then Fecha end desc ,   
									 case when @orderByColumn = 'Resumen'			and @orderDirection = 'asc'		then Resumen end ,
                                    case when @orderByColumn = 'Resumen'			and @orderDirection = 'desc'		then Resumen end desc ,  
									case when @orderByColumn = 'EstatusSolicitud'			and @orderDirection = 'asc'		then EstatusSolicitud end ,
                                    case when @orderByColumn = 'EstatusSolicitud'			and @orderDirection = 'desc'		then EstatusSolicitud end desc ,
								    case when @orderByColumn = 'TipoSolicitud'			and @orderDirection = 'asc'		then TipoSolicitud end ,
                                    case when @orderByColumn = 'TipoSolicitud'			and @orderDirection = 'desc'		then TipoSolicitud end desc ,
                                    case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'asc'		then ClaveEmpleado end ,
                                    case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'desc'		then ClaveEmpleado end desc 
        )  as [row]
    into #tempSetPagination
    from 
    (	
        select 
            sp.IDSolicitudPrestamo as  IDSolicitud,
            4 as IDTipoSolicitud
            ,JSON_VALUE(TS.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as TipoSolicitud            
            ,m.ClaveEmpleado as ClaveEmpleado
            ,SP.IDEstatusSolicitudPrestamo as IDEstatus
			,JSON_VALUE(cesp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as EstatusSolicitud
			,SP.FechaInicioPago as Fecha
			,cast(isnull(sp.MontoPrestamo,0.00) as varchar (50)) as Resumen
            ,(
                select *
                from (
                        select 
                            spj.IDSolicitudPrestamo
                            ,     4 as IDTipoSolicitud
                            ,JSON_VALUE(TS.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as TipoSolicitud
                            ,'P'+ cast(spj.IDSolicitudPrestamo as Varchar(10)) as Folio
                            ,spj.IDEmpleado
                            ,e.ClaveEmpleado
                            ,e.NOMBRECOMPLETO as Colaborador
                            ,SUBSTRING (e.Nombre, 1, 1) + SUBSTRING (e.Paterno, 1, 1)  as Iniciales
                            ,e.Puesto
                            ,e.Departamento
                            ,e.Sucursal
                            ,spj.IDTipoPrestamo
                            ,JSON_VALUE(ctp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as TipoPrestamo                            
                            ,isnull(sp.FechaInicioPago,  '9999-12-31') as FechaIni
							,isnull (sp.FechaHoraCancelacion, '9999-12-31') AS FechaFin	
                            --ctp.Descripcion as TipoPrestamo                            
                            ,isnull(spj.MontoPrestamo,0.00) as MontoPrestamo
                            ,isnull(spj.MontoPrestamo,0.00) as Resumen
                            ,isnull(spj.Cuotas, 0) as Cuotas
                            ,spj.CantidadCuotas
                            ,spj.FechaCreacion
                            ,spj.FechaInicioPago
                            ,spj.Autorizado
                            ,isnull(spj.IDUsuarioAutorizo,0) as IDUsuarioAutorizo
                            ,spj.FechaHoraAutorizacion
                            ,spj.Cancelado
                            ,isnull(spj.IDUsuarioCancelo,0) as IDUsuarioCancelo	   
                            ,spj.FechaHoraCancelacion
                            ,spj.MotivoCancelacion
                            ,isnull(spj.IDPrestamo,0) as IDPrestamo		   
                            ,spj.Descripcion
                            ,isnull(spj.Intereses,0.00) as Intereses		
                            ,spj.IDEstatusSolicitudPrestamo                            
                            ,JSON_VALUE(cesp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as EstatusSolicitud
                            ,cesp.CssClass
                            ,cesp.VueBindingStyle
                            ,isnull(spj.IDFondoAhorro,0) as IDFondoAhorro	
                            ,isnull(spj.IDEstatusPrestamo, 0) as IDEstatusPrestamo
                            ,isnull(cep.Descripcion, 'Sin estatus préstamo') as EstatusPrestamo
                        from [Intranet].[tblSolicitudesPrestamos] spj with (nolock)
                            join [RH].[tblEmpleadosMaster] e with (nolock) on e.IDEmpleado = spj.IDEmpleado
                            INNER JOIN Intranet.tblCatTipoSolicitud TS WITH(NOLOCK) on TS.IDTipoSolicitud = 4                            
                            join [Nomina].[tblCatTiposPrestamo] ctp with (nolock) on ctp.IDTipoPrestamo = spj.IDTipoPrestamo
                            join [Intranet].[tblCatEstatusSolicitudesPrestamos] cesp with (nolock) on cesp.IDEstatusSolicitudPrestamo = spj.IDEstatusSolicitudPrestamo 
                            join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = M.IDEmpleado and dfe.IDUsuario = @IDUsuario
                            left join [Nomina].[tblCatEstatusPrestamo] cep on cep.IDEstatusPrestamo = spj.IDEstatusPrestamo 
                        where (spj.IDSolicitudPrestamo = sp.IDSolicitudPrestamo ) 
                    ) info
                    for json auto, WITHOUT_ARRAY_WRAPPER
                ) [data]
            from [Intranet].[tblSolicitudesPrestamos] sp with (nolock)					
            INNER JOIN Intranet.tblCatTipoSolicitud TS WITH(NOLOCK) on TS.IDTipoSolicitud = 4
            join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = sp.IDEmpleado and dfe.IDUsuario = @IDUsuario
			inner join  [Intranet].[tblCatEstatusSolicitudesPrestamos] cesp with (nolock) on cesp.IDEstatusSolicitudPrestamo = sp.IDEstatusSolicitudPrestamo 
            INNER JOIN RH.tblEmpleadosMaster m on m.IDEmpleado=sp.IDEmpleado
            where  
                (SP.IDEmpleado =@IDEmpleado or @IDEmpleado =0) and
				(SP.IDSolicitudPrestamo =@IDSolicitud or @IDSolicitud =0) and   
                (SP.IDEstatusSolicitudPrestamo =@IDEstatus or @IDEstatus =0) and 
				( @FechaAbsoluta >= cast(SP.FechaInicioPago as date)   or @FechaAbsoluta is null)AND
                ( ( SP.FechaInicioPago  BETWEEN @FechaIni and @FechaFin ) OR  (@FechaFin is null or @FechaIni is null)   ) 
                
        union all
        SELECT 			
            SEE.IDSolicitud as IDSolicitud,
            SEE.IDTipoSolicitud as IDTipoSolicitud
            ,JSON_VALUE(TS.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as TipoSolicitud		        
            ,m.ClaveEmpleado as ClaveEmpleado
            ,see.IDEstatusSolicitud as IDEstatus
			,JSON_VALUE(sp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as EstatusSolicitud
			,See.FechaIni as Fecha
			      ,case when SEE.IDTipoSolicitud = 2 then cast (ISNULL(SEE.CantidadDias,0) as varchar(15)) +' Días'
							when SEE.IDTipoSolicitud = 3 then SEE.ComentarioEmpleado 
							END as Resumen
            ,(
                select *
                from (
                    SELECT 
                        SE.IDSolicitud
                        ,'S'+ cast(SE.IDSolicitud as Varchar(10)) as Folio
                        ,SE.IDEmpleado
                        ,M.ClaveEmpleado
                        ,M.NOMBRECOMPLETO as Colaborador
                        ,SUBSTRING (M.Nombre, 1, 1) + SUBSTRING (M.Paterno, 1, 1)  as Iniciales
                        ,M.Puesto
                        ,M.Departamento
                        ,M.Sucursal
                        ,SE.IDTipoSolicitud
                        ,JSON_VALUE(TS.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as TipoSolicitud
                        ,SE.IDEstatusSolicitud 
                        ,JSON_VALUE(ES.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as EstatusSolicitud
                        ,SE.IDIncidencia 
                        -- ,I.Descripcion as Incidencia
                        ,JSON_VALUE(I.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Incidencia
                        ,isnull(SE.FechaIni,'9999-12-31') as FechaIni
						,ISNULL(SE.FechaFin, '9999-12-31') AS FechaFin
                        ,ISNULL(SE.CantidadDias,0) as CantidadDias
                        ,case when SE.IDTipoSolicitud = 2 then cast (ISNULL(SE.CantidadDias,0) as varchar(15)) +' Días'
							when SE.IDTipoSolicitud = 3 then SE.ComentarioEmpleado 
							END as Resumen
						--cast (ISNULL(SE.CantidadDias,0) as varchar(15)) +' Días' as Resumen
                        ,SE.DiasDescanso
                        ,SE.FechaCreacion
                        ,SE.ComentarioEmpleado
                        ,SE.ComentarioSupervisor
                        ,ES.CssClas as Estilo
                        ,ISNULL(SE.CantidadMonto,0) as CantidadMonto
                        ,isnull(SE.IDUsuarioAutoriza,0) as IDUsuarioAutoriza
                        ,ROW_NUMBER()OVER(ORDER BY SE.IDSolicitud ASC) ROWNUMBER
                        ,ES.VueBindingStyle
                    FROM Intranet.tblSolicitudesEmpleado SE WITH(NOLOCK)
                        INNER JOIN RH.tblEmpleadosMaster M WITH(NOLOCK) on SE.IDEmpleado = M.IDEmpleado
                        join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = M.IDEmpleado and dfe.IDUsuario = @IDUsuario
                        INNER JOIN Intranet.tblCatTipoSolicitud TS WITH(NOLOCK) on TS.IDTipoSolicitud = SE.IDTipoSolicitud                        
                        INNER JOIN Intranet.tblCatEstatusSolicitudes ES WITH(NOLOCK) on ES.IDEstatusSolicitud = SE.IDEstatusSolicitud
                        LEFT JOIN Asistencia.tblCatIncidencias I WITH(NOLOCK) on SE.IDIncidencia = I.IDIncidencia
                    WHERE (SE.IDSolicitud = SEE.IDSolicitud) 


                ) info
                for json auto, WITHOUT_ARRAY_WRAPPER
            ) as [data]
            FROM Intranet.tblSolicitudesEmpleado SEE WITH(NOLOCK)	
                INNER JOIN Intranet.tblCatTipoSolicitud TS WITH(NOLOCK) on 
                    TS.IDTipoSolicitud = SEE.IDTipoSolicitud
                INNER JOIN Intranet.tblCatEstatusSolicitudesPrestamos sp on 
                    sp.IDEstatusSolicitudReferencia=SEE.IDEstatusSolicitud
                INNER JOIN Intranet.tblCatEstatusSolicitudes ES WITH(NOLOCK) on
                    ES.IDEstatusSolicitud = SEE.IDEstatusSolicitud	
                INNER JOIN RH.tblEmpleadosMaster m on m.IDEmpleado=SEE.IDEmpleado            
                join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = SEE.IDEmpleado and dfe.IDUsuario = @IDUsuario
            where   (SEE.IDEmpleado = @IDEmpleado or @IDEmpleado =0)   and 
					(SEE.IDSolicitud =@IDSolicitud or @IDSolicitud =0) and   
                    (sp.IDEstatusSolicitudPrestamo = @IDEstatus or @IDEstatus=0)  and  
						--( @FechaAbsoluta >= cast(SEE.FechaIni as date)   or @FechaAbsoluta is null)AND
                    ( (( SEE.FechaIni  BETWEEN @FechaIni and @FechaFin and @IDEmpleado=0  ) or (@FechaFin is null or @FechaIni is null)  or see.IDEmpleado=@IDEmpleado))  
                    
    ) as tabla
    where (IDTipoSolicitud in(select item from app.Split(@IDTipoSolicitud,','))or @IDTipoSolicitud='')
	   AND((@BanderaGetVacaciones is null or @BanderaGetVacaciones=1) OR ( IDTipoSolicitud!=1 AND @BanderaGetVacaciones=0) )


    if exists(select top 1 * from @dtPagination)
        BEGIN
            exec [Utilerias].[spAddPagination] @dtPagination=@dtPagination
        end
    else 
        begin 
            select  * From #tempSetPagination order by row desc
        end


END
GO

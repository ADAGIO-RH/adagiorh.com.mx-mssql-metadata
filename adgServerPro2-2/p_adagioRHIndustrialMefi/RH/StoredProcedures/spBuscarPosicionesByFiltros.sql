USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: sp para buscar posicines por configuracion de plaza
** Autor			: Jose Vargas
** Email			: jvargas,@adagio.com.mx
** FechaCreacion	: 2023-08-16
** Paremetros		:              	

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?

***************************************************************************************************/
--[RH].[spBuscarPosiciones]  @IDEmpleado = 390
CREATE proc [RH].[spBuscarPosicionesByFiltros](
    @dtFiltros Nomina.dtFiltrosRH readonly
	-- @IDPosicion int = 0
	-- ,@IDPlaza	int = 0
	-- ,@IDCliente	int = 0
	-- ,@IDEmpleado int = 0
	-- ,@ParentId	int = 0
    -- ,@IDReclutador int =0
	
	-- ,@StringFiltroEstatus varchar(100) =''
    -- ,@Filtro varchar(255) = null
    -- ,@IDReferencia int   = null
    ,@EsTemporal	bit =null
    ,@EsAsistente	bit =null
    ,@IDPuesto int = 0
    ,@IDOrganigrama int = 0
    ,@IDCliente int = 0
    
    ,@IDUsuario	int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Codigo'
	,@orderDirection varchar(4) = 'asc'
) as
	SET FMTONLY OFF;  

    -- select case  
    --     when @EsTemporal is null then 'null'
    --     when @EsTemporal=0 then 'false'
    --     when @EsTemporal=1 then 'true'
    --     else 'sabe'
    --     end

    declare		
		@TotalPaginas int = 0
		,@TotalRegistros decimal(18,2) = 0.00		
		,@IDIdioma varchar(20)        
        
	;

	IF OBJECT_ID('tempdb..#TempPosicionesByFiltros') IS NOT NULL DROP TABLE #TempPosicionesByFiltros

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx');
	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 
    
	-- set @query = case 
	-- 				when @query is null then '""' 
	-- 				when @query = '' then '""'
	-- 				when @query =  '""' then '""'
	-- 			else '"'+@query + '*"' end
                    
    declare @tempPlazas as table (		
		IDPlaza int		
	);    
    declare @finalPlazas as table(
        IDPlaza int 
    );
    DECLARE @finalPosicion as table (
        IDPosicion int
    )
    
    if( exists(select top 1 1 from @dtFiltros))
    BEGIN
        DECLARE @Conjuncion varchar(3)
        
        SELECT
            @Conjuncion=[Value]
        FROM @dtFiltros 
        WHERE Catalogo ='Conjuncion'

        set @Conjuncion=ISNULL(@Conjuncion,'AND')
        
        
            
            insert into @tempPlazas 
            select IDPlaza from rh.tblCatPlazas             
            where  (IDPuesto=@IDPuesto  OR ISNULL(@IDPuesto,0)=0) and (Codigo=@query or isnull(@query,'')=''); 
        
            insert into @tempPlazas
            SELECT p.IDPlaza            
            FROM
                @tempPlazas tempP
            INNER JOIN rh.tblCatPlazas p on p.IDPlaza=tempP.IDPlaza                                
            CROSS APPLY OPENJSON(Configuraciones)
            WITH (
                IDTipoConfiguracionPlaza NVARCHAR(50),
                Valor INT,
                Descripcion NVARCHAR(100)
            ) AS JsonData
            WHERE 
                JsonData.IDTipoConfiguracionPlaza  in (select distinct Catalogo from @dtFiltros ) AND
                JsonData.Valor  in (
                    (select cast(item as int) from App.Split((select distinct [Value] from @dtFiltros where Catalogo= JsonData.IDTipoConfiguracionPlaza),','))                            
                )               
            
            DECLARE @totalConfiguraciones int 
            DECLARE @CONFIGURACION_GENERALES int ;
            set @CONFIGURACION_GENERALES=1 -- PUESTO

            
            select  @totalConfiguraciones=count(distinct Catalogo)+@CONFIGURACION_GENERALES FROM @dtFiltros  WHERE Catalogo not in ('Conjuncion' )            
            
            IF  @Conjuncion = 'AND'
            begin         
                insert into @finalPlazas
                SELECT 
                    IDPlaza
                FROM @tempPlazas 
                GROUP by IDPlaza            
                having count(*) =@totalConfiguraciones
                order by IDPlaza
             END
            else  
            BEGIN
                insert into @finalPlazas
                SELECT 
                    IDPlaza
                FROM @tempPlazas 
                GROUP by IDPlaza            
                having count(*) >= 2
                order by IDPlaza
            end
            insert into @finalPosicion
            SELECT  
                posiciones.IDPosicion
            FROM  @finalPlazas plaza 
            -- inner join rh.tblCatPlazas plaza on plaza.IDPlaza=tempplaza.IDPlaza
            inner join rh.tblCatPosiciones posiciones on posiciones.IDPlaza=plaza.IDPlaza
            INNER JOIN (
                SELECT IDPosicion, MAX(FechaReg) AS MaxFechaReg
                FROM rh.tblEstatusPosiciones
                WHERE IDEstatus = 2
                GROUP BY IDPosicion
            ) maxEstatus ON posiciones.IDPosicion = maxEstatus.IDPosicion
            INNER JOIN rh.tblEstatusPosiciones estatusPosiciones ON maxEstatus.IDPosicion = estatusPosiciones.IDPosicion AND maxEstatus.MaxFechaReg = estatusPosiciones.FechaReg
             
            
            select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
            from @finalPosicion

            select @TotalRegistros = cast(COUNT([IDPosicion]) as decimal(18,2)) from @finalPosicion		

            select
                *
                ,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end        
                ,cast(@TotalRegistros  as int) as TotalRows
                into #TempPosicionesByFiltros
            from @finalPosicion s
            --order by Codigo asc
            order by  
                case when @orderByColumn = 'IDPosicion'			and @orderDirection = 'asc'		then IDPosicion end desc 
            --         case when @orderByColumn = 'Codigo'			and @orderDirection = 'desc'		then Codigo end desc,
            --         case when @orderByColumn = 'Plaza'			and @orderDirection = 'asc'		then s.Plaza end ,
            --         case when @orderByColumn = 'Plaza'			and @orderDirection = 'desc'		then s.Plaza end desc  ,                                                                  
            --         case when @orderByColumn = 'CodigoPlaza'			and @orderDirection = 'asc'		then s.CodigoPlaza end ,
            --         case when @orderByColumn = 'CodigoPlaza'			and @orderDirection = 'desc'		then s.CodigoPlaza end desc,
            --         case when @orderByColumn = 'Cliente'			and @orderDirection = 'asc'		then Cliente end ,
            --         case when @orderByColumn = 'Cliente'			and @orderDirection = 'desc'		then Cliente end desc,
            --         case when @orderByColumn = 'Temporal'			and @orderDirection = 'asc'		then Temporal end ,
            --         case when @orderByColumn = 'Temporal'			and @orderDirection = 'desc'		then Temporal end desc,
            --         case when @orderByColumn = 'DisponibleDesde'			and @orderDirection = 'asc'		then DisponibleDesde end ,
            --         case when @orderByColumn = 'DisponibleDesde'			and @orderDirection = 'desc'		then DisponibleDesde end desc ,                                                                
            --         case when @orderByColumn = 'DisponibleHasta'			and @orderDirection = 'asc'		then DisponibleHasta end ,
            --         case when @orderByColumn = 'DisponibleHasta'			and @orderDirection = 'desc'		then DisponibleHasta end desc ,                                                                
            --         case when @orderByColumn = 'Empleado.ClaveEmpleado'			and @orderDirection = 'asc'		then ClaveEmpleado end ,
            --         case when @orderByColumn = 'Empleado.ClaveEmpleado'			and @orderDirection = 'desc'		then ClaveEmpleado end desc ,                                                                
            --         case when @orderByColumn = 'Empleado.NombreCompleto'			and @orderDirection = 'asc'		then s.Colaborador end ,
            --         case when @orderByColumn = 'Empleado.NombreCompleto'			and @orderDirection = 'desc'		then Colaborador end desc ,                                                                            
            --         case when @orderByColumn = 'Estatus.Estatus'			and @orderDirection = 'asc'		then Estatus end ,
            --         case when @orderByColumn = 'Estatus.Estatus'			and @orderDirection = 'desc'		then Estatus end desc                                                                                     
            OFFSET @PageSize * (@PageNumber - 1) ROWS
            FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

            select 
                posiciones.IDPosicion,
                posiciones.Codigo [Codigo],
                plazas.IDPlaza,
                plazas.Codigo [CodigoPlaza],
                JSON_VALUE(puesto.Traduccion,FORMATMESSAGE('$.%s.%s',lower(replace(@IDIdioma,'-','')),'Descripcion')) as Plaza,
                plazas.IDCliente,
                cliente.NombreComercial as Cliente,
                posiciones.Temporal,
                posiciones.DisponibleDesde,
                posiciones.DisponibleHasta,            
                plazas.EsAsistente,
                plazas.IDOrganigrama,
                TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end,
                cast(ISNULL(@TotalRegistros, 0)as int) as TotalRows                
            From #TempPosicionesByFiltros temp 
            inner join rh.tblCatPosiciones posiciones on posiciones.IDPosicion=temp.IDPosicion
            inner join rh.tblCatPlazas plazas on plazas.IDPlaza = posiciones.IDPlaza
            inner join rh.tblCatPuestos puesto on puesto.IDPuesto= plazas.IDPuesto
            inner join rh.tblCatClientes cliente on cliente.IDCliente=plazas.IDCliente
            -- select * From #TempPosicionesByFiltros
            --  rh.tblCatPlazas  plaza
            --  inner join @tempPlazas p on p.IDPlaza=plaza.IDPlaza
             
                    -- ( JsonData.IDTipoConfiguracionPlaza  in ('Departamento') AND JsonData.Valor  in ( 7 ) ) 
                    --  or 
                    -- ( JsonData.IDTipoConfiguracionPlaza  in ('Area') AND JsonData.Valor  in ( 5 ) ) 
                    -- or
                    -- ( JsonData.IDTipoConfiguracionPlaza  in ('Sucursal') AND JsonData.Valor  in ( 1 ) ) 
            -- ) as tt
            -- group by IDPlaza
            -- HAVING  ( COUNT(*) =2 )                
    end else
    BEGIN 

        SELECT *
        FROM rh.tblCatPosiciones 
        
        -- WHERE          
    end
GO

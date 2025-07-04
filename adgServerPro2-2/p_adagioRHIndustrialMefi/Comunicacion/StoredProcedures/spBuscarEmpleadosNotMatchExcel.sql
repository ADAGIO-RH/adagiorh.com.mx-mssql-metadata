USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jose Vargas
-- Create date: 2022-08-29
-- Description:	 
-- BUSCA LOS EMPLEADOS QUE NO SE ENCUENTREN EN EL JSON DEL EXCEL, ESTO PARA VERIFICAR LOS EMPLEADOS DEL EXCEL VS LOS EMPLEADOS DEL COMUNICADO  SOLO CUANDO SON CAMPOS INDIVIDUALES
-- =============================================
CREATE PROCEDURE [Comunicacion].[spBuscarEmpleadosNotMatchExcel]
    @dtFiltros [Nomina].[dtFiltrosRH]  READONLY,
    @IDUsuario int ,
    @IsGeneral bit,
    @StringJsonExcel varchar(max),
    @PageNumber	INT = 1,
	@PageSize INT = 2147483647,
	@query VARCHAR(100) = '""',
	@orderByColumn	VARCHAR(50) = 'Descripcion',
	@orderDirection VARCHAR(4) = 'asc'
    
AS
BEGIN
    DECLARE  
			@IDIdioma varchar(225),
			@TotalPaginas INT = 0,
			@TotalRegistros DECIMAL(18,2) = 0.00;

    IF(ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
    IF(isnull(@PageSize, 0) = 0) SET @PageSize = 2147483647;

    SELECT
        @orderByColumn	= CASE WHEN @orderByColumn IS NULL THEN 'Descripcion' ELSE @orderByColumn END,
        @orderDirection = CASE WHEN @orderDirection IS NULL THEN 'asc' ELSE @orderDirection END 

    if object_id('tempdb..#tempFinalEmpleados') is not null drop table #tempFinalEmpleados;
    if object_id('tempdb..#tempEmpleadosExcel') is not null drop table #tempEmpleadosExcel;

    create table #tempEmpleadosExcel (                
                ClaveEmpleado varchar(255), 
                row_number int,
    )		

    
    insert into #tempEmpleadosExcel (row_number,ClaveEmpleado)
    select   ROW_NUMBER() OVER(partition by ClaveEmpleado ORDER BY ClaveEmpleado ASC),* From ( 
        select * from OpenJSON(@StringJsonExcel) wITH (  ClaveEmpleado VARCHAR(20) ) as months
    ) as tabla

    if exists(select top 1 1 from #tempEmpleadosExcel where row_number >1)
    BEGIN 
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
    end
    
    create table #tempFinalEmpleados (
                IDEmpleado int, 
                ClaveEmpleado varchar(255), 
                Puesto varchar(255),
                Departamento varchar(255),
                Sucursal varchar (255),
                NombreCompleto varchar (255),
                Iniciales varchar(255),
                TipoFiltro varchar(255) ,
                TipoFiltroDesc varchar(255) collate database_default)		    

    IF(@IsGeneral = 1 )
        BEGIN
                insert #tempFinalEmpleados
                select   
                    m.IDEmpleado,
                    m.ClaveEmpleado,
                    m.Puesto,
                    m.Departamento,
                    m.Sucursal,
                    m.NOMBRECOMPLETO [NombreCompleto],
                    SUBSTRING (m.Nombre, 1, 1) + SUBSTRING (m.Paterno, 1, 1) [Iniciales] ,
                    'General' as TipoFiltro,
                    'General' as TipoFiltroDesc
                From RH.tblEmpleadosMaster  m                                
                    where  m.Vigente=1
        END
    ELSE
        BEGIN
            declare         		
            @empleados [RH].[dtEmpleados]
            ,@i int = 0
            ,@fecha date = getdate()
            ,@Catalogo varchar (255)        
            ,@dttempFiltros [Nomina].[dtFiltrosRH]
                            
            if object_id('tempdb..#tempFiltrosParaAsignarEmpaAvisos') is not null drop table #tempFiltrosParaAsignarEmpaAvisos;
           
		    select *,ROW_NUMBER()OVER( ORDER BY (SELECT NULL)) AS rownumber 
            INTO #tempFiltrosParaAsignarEmpaAvisos
            from @dtFiltros WHERE Catalogo <> 'Excluir Empleado'
            
			
			--select * from #tempFiltrosAsignarEmpaAvisos
            select @i = min(rownumber) from #tempFiltrosParaAsignarEmpaAvisos  

            while exists(select top 1 1 from #tempFiltrosParaAsignarEmpaAvisos where rownumber >= @i)
                begin
                    delete from @dttempFiltros;
                    delete from @empleados;

                    insert into @dttempFiltros (Catalogo,Value)
                    select Catalogo, Value
                        from #tempFiltrosParaAsignarEmpaAvisos
                    where rownumber = @i

                    select @Catalogo=Catalogo
                    from #tempFiltrosParaAsignarEmpaAvisos
                    where rownumber = @i

                    insert into @empleados
                    -- exec [Comunicacion].[spBuscarEmpleados]
                    exec [RH].[spBuscarEmpleadosMaster]
                        @FechaIni	= @fecha
                        ,@Fechafin	= @fecha 
                        ,@IDUsuario	= @IDUsuario
                        ,@dtFiltros = @dttempFiltros
                    

                    insert #tempFinalEmpleados
                        (TipoFiltro,TipoFiltroDesc,IDEmpleado,ClaveEmpleado,Departamento,Puesto,Sucursal,Iniciales,NombreCompleto)
                    select @Catalogo,
                        case @Catalogo 
                                when 'Areas' then concat(@Catalogo ,' | ',Area) 
                                when 'CentrosCostos' then concat(@Catalogo ,' | ',CentroCosto)                     
                                when 'ClasificacionesCorporativas' then concat(@Catalogo ,' | ',ClasificacionCorporativa)                     
                                when 'Clientes' then concat(@Catalogo ,' | ',Cliente)                     
                                when 'Departamentos' then concat(@Catalogo ,' | ',Departamento) 
                                when 'Departamentos' then concat(@Catalogo ,' | ',Departamento) 
                                when 'Divisiones' then concat(@Catalogo ,' | ',Division) 
                                when 'Prestaciones' then concat(@Catalogo ,' | ',TiposPrestacion) 
                                when 'Puestos' then concat(@Catalogo ,' | ',Puesto) 
                                when 'RazonesSociales' then concat(@Catalogo ,' | ',RazonSocial) 
                                when 'Regiones' then concat(@Catalogo ,' | ',Region) 
                                when 'RegPatronales' then concat(@Catalogo ,' | ',RegPatronal)                     
                                when 'Sucursales' THEN concat(@Catalogo ,' | ',Sucursal) 
                                when 'TiposContratacion' THEN concat(@Catalogo ,' | ',TipoContrato) 
                                when 'TiposNomina' THEN concat(@Catalogo ,' | ',TipoNomina) 
                                else  @Catalogo end,
                        IDEmpleado,
                        ClaveEmpleado,
                        Departamento,
                        Puesto,
                        Sucursal,
                        SUBSTRING (Nombre, 1, 1) + SUBSTRING (Paterno, 1, 1) ,
                        NOMBRECOMPLETO
                    FROM @empleados
                    select @i = min(rownumber)
                    from #tempFiltrosParaAsignarEmpaAvisos
                    where rownumber > @i
                end;                                         
        END
                
        DELETE tf FROM #tempFinalEmpleados tf
        LEFT JOIN #tempEmpleadosExcel  t  on tf.ClaveEmpleado=t.ClaveEmpleado
        where t.ClaveEmpleado is not null

        delete #tempFinalEmpleados where  IDEmpleado in (
                            Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo in('Excluir Empleado','Excluir Usuarios')),',')
            );    

        SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
		FROM #tempFinalEmpleados

		SELECT @TotalRegistros = CAST(COUNT([IDEmpleado]) AS DECIMAL(18,2)) FROM #tempFinalEmpleados		

		SELECT *,
			   TotalPaginas = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END,
               cast(@TotalRegistros as int) [TotalRows]
		FROM #tempFinalEmpleados
		ORDER BY 
			case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'asc'		    then ClaveEmpleado end  ,
                                    case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'desc'		then ClaveEmpleado end desc,
                                    case when @orderByColumn = 'NombreCompleto'			and @orderDirection = 'asc'		    then NombreCompleto end  ,
                                    case when @orderByColumn = 'NombreCompleto'			and @orderDirection = 'desc'		then NombreCompleto end desc ,
                                    case when @orderByColumn = 'Puesto'			        and @orderDirection = 'asc'		    then Puesto end ,
                                    case when @orderByColumn = 'Puesto'			        and @orderDirection = 'desc'		then Puesto end desc,
                                    case when @orderByColumn = 'Sucursal'			    and @orderDirection = 'asc'		    then Sucursal end ,
                                    case when @orderByColumn = 'Sucursal'			    and @orderDirection = 'desc'		then Sucursal end desc ,
                                    case when @orderByColumn = 'Departamento'			and @orderDirection = 'asc'		    then Departamento end  ,
                                    case when @orderByColumn = 'Departamento'			and @orderDirection = 'desc'		then Departamento end desc 
		OFFSET @PageSize * (@PageNumber - 1) ROWS
		FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO

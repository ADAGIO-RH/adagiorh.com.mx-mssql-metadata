USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Autor   : Jose Vargas
** Email   : jvargas@adagio.com.mx  
** FechaCreacion : 2022-07-04
** Paremetros  :                
  
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
***************************************************************************************************/
CREATE PROCEDURE [Comunicacion].[spBuscarEmpleadosFiltrosTemp]
    (
    @dtFiltros [Nomina].[dtFiltrosRH]  READONLY,
    @IDUsuario int ,
    @IDAviso int =0,
    @PageNumber	INT = 1,
    @PageSize INT = 2147483647,
    @query VARCHAR(100) = '',
    @orderByColumn	VARCHAR(50) = 'Descripcion',
    @orderDirection VARCHAR(4) = 'asc'
)
AS
BEGIN
    declare         		
		@empleados [RH].[dtEmpleados]
		,@i int = 0
		,@fecha date = getdate()
		,@Catalogo varchar (255)        
        ,@Values varchar(255)
        ,@dttempFiltros [Nomina].[dtFiltrosRH]
        ,@TotalPaginas INT = 0
        ,@TotalRegistros DECIMAL(18,2) = 0.00
        ,@EXCLUIR_EMPLEADOS  varchar(255) = 'Excluir Empleado';

    IF(ISNULL(@PageNumber, 0) = 0) SET @PageNumber = 1;
    IF(isnull(@PageSize, 0) = 0) SET @PageSize = 2147483647;

    SELECT
        @orderByColumn	= CASE WHEN @orderByColumn IS NULL THEN 'Descripcion' ELSE @orderByColumn END,
        @orderDirection = CASE WHEN @orderDirection IS NULL THEN 'asc' ELSE @orderDirection END

    if object_id('tempdb..#tempFinalEmpleados') is not null drop table #tempFinalEmpleados;
    if object_id('tempdb..#tempFiltrosAsignarEmpaAvisos') is not null drop table #tempFiltrosAsignarEmpaAvisos;

    SELECT @IDAviso=isnull(@IDAviso,0)

    create table #tempFinalEmpleados
    (
        IDEmpleado int,
        ClaveEmpleado varchar(255),
        Puesto varchar(255),
        Departamento varchar(255),
        Sucursal varchar (255),
        NombreCompleto varchar (255),
        Iniciales varchar(255),
        TipoFiltro varchar(255) ,
        TipoFiltroDesc varchar(255) collate database_default
    )

    create TABLE #tempFiltrosAsignarEmpaAvisos
    (
        Catalogo VARCHAR(100),
        Value Varchar(300),
        rownumber int
    )

    insert #tempFiltrosAsignarEmpaAvisos (Catalogo,[Value],rownumber)
    select Catalogo, [Value], ROW_NUMBER()OVER( ORDER BY (SELECT NULL)) AS rownumber from @dtFiltros WHERE Catalogo <>'search'     

    select @i = min(rownumber) from #tempFiltrosAsignarEmpaAvisos 
    
    while exists(select top 1 1 from #tempFiltrosAsignarEmpaAvisos where rownumber >= @i)
    begin
        delete from @dttempFiltros;
        delete from @empleados;

        insert into @dttempFiltros (Catalogo,Value)
        select Catalogo, Value
            from #tempFiltrosAsignarEmpaAvisos
        where rownumber = @i

        select @Catalogo=Catalogo
        from #tempFiltrosAsignarEmpaAvisos
        where rownumber = @i

        IF @Catalogo = @EXCLUIR_EMPLEADOS -- Esta condicion reemplaza temporalmente el filtro `Excluir Empleado` por `Empleado` para realizar la busqueda en el SP `[RH].[spBuscarEmpleadosMaster]`
        BEGIN
            update @dttempFiltros set Catalogo= 'Empleados' WHERE Catalogo=@EXCLUIR_EMPLEADOS            
        end
            
        insert into @empleados        
        exec [RH].[spBuscarEmpleadosMaster]
            @FechaIni	= @fecha
            ,@Fechafin	= @fecha 
            ,@IDUsuario	= @IDUsuario
            ,@dtFiltros = @dttempFiltros


        insert #tempFinalEmpleados (TipoFiltro,TipoFiltroDesc,IDEmpleado,ClaveEmpleado,Departamento,Puesto,Sucursal,Iniciales,NombreCompleto)
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
        from #tempFiltrosAsignarEmpaAvisos
        where rownumber > @i
    end;

    -- CTE que elimina los colaboradores duplicados	
    WITH TempEmp (IDEmpleado, duplicateRecCount) AS
    (
        SELECT IDEmpleado, ROW_NUMBER() OVER(PARTITION by IDEmpleado ORDER BY IDEmpleado) AS duplicateRecCount FROM #tempFinalEmpleados
    )
    --Now Delete Duplicate Records
    DELETE FROM TempEmp WHERE duplicateRecCount > 1;

    declare @MostrarColaboradoresExcluidos bit 
    set @MostrarColaboradoresExcluidos =Case when (select count(*) from @dtFiltros)=1  and     
                                                   (select top 1 Catalogo from @dtFiltros)  = @EXCLUIR_EMPLEADOS
                                        THEN 1 else 0 end;    

    
    IF @MostrarColaboradoresExcluidos =0
    BEGIN        
        delete #tempFinalEmpleados where  IDEmpleado in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = @EXCLUIR_EMPLEADOS),','))        
    END

	DELETE F
	FROM #tempFinalEmpleados F
		inner join RH.tblEmpleadosMaster M with(nolock) on F.IDEmpleado = M.IDEmpleado
	WHERE ISNULL(M.Vigente,0) = 0

 
    IF @IDAviso <> 0
        BEGIN            
            MERGE [Comunicacion].[tblFiltrosAvisos] AS TARGET
                USING #tempFiltrosAsignarEmpaAvisos as SOURCE
                    on  TARGET.IDAviso = @IDAviso and TARGET.TipoFiltro= SOURCE.Catalogo and Target.[Values]=SOURCE.Value                        
            WHEN NOT MATCHED BY TARGET THEN 
                INSERT(IDAviso,TipoFiltro,[Values])
                values(@IDAviso,
                        SOURCE.Catalogo,
                        SOURCE.Value)
            WHEN NOT MATCHED BY SOURCE AND TARGET.IDAviso= @IDAviso then
            DELETE
                OUTPUT $action;        

            MERGE [Comunicacion].[tblEmpleadosAvisos] AS TARGET
                USING #tempFinalEmpleados as SOURCE
                    on TARGET.IDEmpleado = SOURCE.IDEmpleado and TARGET.IDAviso = @IDAviso
            WHEN MATCHED THEN
                update 
                set TARGET.TipoFiltro = SOURCE.TipoFiltroDesc                            
            WHEN NOT MATCHED BY TARGET THEN 
                INSERT(IDAviso,IDEmpleado,TipoFiltro)
                values(@IDAviso,
                        SOURCE.IDEmpleado,
                        SOURCE.TipoFiltroDesc)                                 
            WHEN NOT MATCHED BY SOURCE AND TARGET.IDAviso= @IDAviso then
            DELETE
                OUTPUT $action;
    END
    ELSE
        BEGIN
			select *
			into #tempSetPagination
			From #tempFinalEmpleados
			where ((@query <> '' and ( 
												ClaveEmpleado like '%'+@query+'%' or
				NombreCompleto like '%'+@query+'%' or
				Puesto like '%'+@query+'%' or
				Sucursal like '%'+@query+'%' or
				Departamento like '%'+@query+'%' 
											)                
				) or (@query='' or @query is null) )

			SELECT @TotalPaginas = CEILING(CAST(COUNT(*) AS DECIMAL(20,2))/CAST(@PageSize AS DECIMAL(20,2)))
			FROM #tempSetPagination

			SELECT @TotalRegistros = CAST(COUNT([IDEmpleado]) AS DECIMAL(18,2))
			FROM #tempSetPagination

			SELECT *,
				TotalPaginas = CASE WHEN @TotalPaginas = 0 THEN 1 ELSE @TotalPaginas END,
				cast(@TotalRegistros as int) [TotalRows]
			FROM #tempSetPagination
			ORDER BY 
					case when @orderByColumn = 'ClaveEmpleado' and @orderDirection = 'asc'		    then ClaveEmpleado end  ,
					case when @orderByColumn = 'ClaveEmpleado' and @orderDirection = 'desc'		then ClaveEmpleado end desc,
					case when @orderByColumn = 'NombreCompleto' and @orderDirection = 'asc'		    then NombreCompleto end  ,
					case when @orderByColumn = 'NombreCompleto' and @orderDirection = 'desc'		then NombreCompleto end desc ,
					case when @orderByColumn = 'Puesto' and @orderDirection = 'asc'		    then Puesto end ,
					case when @orderByColumn = 'Puesto' and @orderDirection = 'desc'		then Puesto end desc,
					case when @orderByColumn = 'Sucursal' and @orderDirection = 'asc'		    then Sucursal end ,
					case when @orderByColumn = 'Sucursal' and @orderDirection = 'desc'		then Sucursal end desc ,
					case when @orderByColumn = 'Departamento' and @orderDirection = 'asc'		    then Departamento end  ,
					case when @orderByColumn = 'Departamento' and @orderDirection = 'desc'		then Departamento end desc 
				OFFSET @PageSize * (@PageNumber - 1) ROWS
				FETCH NEXT @PageSize ROWS ONLY
			OPTION
			(RECOMPILE);

		END
	END
GO

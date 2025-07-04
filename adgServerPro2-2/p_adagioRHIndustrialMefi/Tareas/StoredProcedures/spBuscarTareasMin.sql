USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp se encarga buscar la información de la tarea.
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-01-30
** Paremetros		:           
    Este sp puede realizar busqueda por los siguientes filtros:
        * @IDEstatusTarea (Tareas.tblCatEstatusTareas)
        * @IDTarea
        * @IDReferencia y @IDTipoTablero (Estos datos juntos hacen referencia a un 'Tablero'. La función del `Tablero` es agrupar todo un conjunto de tareas.)

    @IDUsuario
    Usuarios que ejecuto la acción.    
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
        ?                   ?               ?               
***************************************************************************************************/
CREATE proc [Tareas].[spBuscarTareasMin] (    	
    @IDTarea int ,
    @IDTipoTablero int , 
    @IDReferencia int ,
    @IDUsuario int,
    @IDEstatusTarea int=null,
    @dtFiltros [Nomina].[dtFiltrosRH] READONLY,
    -- @Prioridad varchar(100)='',
    -- @FiltroUsuarios varchar(max)='',
    -- @FlagUsuarios bit=null,
    -- @FechaInicio date =null,     
    -- @FechaFin date =null,     
    -- @FlagFecha bit=null,
    -- @FlagFechasVencidas bit=0,
    -- @Conjuncion varchar(3) ='AND',
    @Archivado bit =0,	
    @PageNumber	int = 1,    
	@PageSize		int = 2147483647,
	@query			varchar(100) = '""',
	@orderByColumn	varchar(50) = 'Orden',
	@orderDirection varchar(4) = 'asc'
) as
begin

    DECLARE        
	   @TotalPaginas int = 0
	   ,@TotalRegistros int = 0
	   ,@IDIdioma varchar(max),
       @QueryMain as varchar(max);       
	
    DECLARE @FiltroSinMiembros bit ,
    @FiltroFechasVencidas bit ,
    @FiltroFechasNoFechas bit ,
    @FiltroFechasConFechas bit ,
    @FiltroChecklistCompletados bit,
    @FiltroChecklistNoCompletados bit,
    @FiltroConChecklist bit,
    @FiltroSinChecklist bit,

    @FiltroConAdjuntos bit,
    @FiltroSinAdjuntos bit,

    @FiltroConComentarios bit,
    @FiltroSinComentarios bit,

    @Conjuncion varchar(3),
    @FiltroIDSUsuarios VARCHAR(MAX),
    @FiltroIDPrioridad varchar(max),
    @FiltroFechaInicio date ,
    @FiltroFechaFin date ,
    @FiltroArchivado bit, 
    @FiltroNoArchivado bit
    ;
    

    

    set @query = case 
                when @query is null then '""' 
                when @query = '' then '""'
                when @query = '""' then '""'
            else '"'+@query + '*"' end

    select @FiltroSinMiembros=cast([Value] as bit) from @dtFiltros where Catalogo= 'SinMiembros';    
    select @FiltroIDSUsuarios = cast([Value] as varchar(max)) from @dtFiltros where Catalogo= 'IDSUsuarios';    
    select @Conjuncion=CAST([Value] as varchar(3)) from @dtFiltros where Catalogo= 'Conjuncion';
    select @FiltroIDPrioridad = cast([Value] as varchar(max)) from @dtFiltros where Catalogo= 'IDSPrioridad';    

    select @FiltroFechasVencidas = cast([Value] as bit) from @dtFiltros where Catalogo= 'FechasVencidas';    
    select @FiltroFechasNoFechas = cast([Value] as bit) from @dtFiltros where Catalogo= 'FechasNoFechas';    
    select @FiltroFechasConFechas = cast([Value] as bit) from @dtFiltros where Catalogo= 'FechasConFechas';    
    select @FiltroFechaInicio = cast([Value] as date) from @dtFiltros where Catalogo= 'FechaInicio';    
    select @FiltroFechaFin = cast([Value] as date) from @dtFiltros where Catalogo= 'FechaFin';     
    
    select @FiltroChecklistCompletados = cast([Value] as bit) from @dtFiltros where Catalogo= 'ChecklistCompletados';    
    select @FiltroChecklistNoCompletados = cast([Value] as bit) from @dtFiltros where Catalogo= 'ChecklistNoCompletados';    
    select @FiltroConChecklist = cast([Value] as bit) from @dtFiltros where Catalogo= 'ConChecklist';    
    select @FiltroSinChecklist = cast([Value] as bit) from @dtFiltros where Catalogo= 'SinChecklist';   

    select @FiltroConAdjuntos = cast([Value] as bit) from @dtFiltros where Catalogo= 'ConAdjuntos';    
    select @FiltroSinAdjuntos = cast([Value] as bit) from @dtFiltros where Catalogo= 'SinAdjuntos';   

    select @FiltroConComentarios = cast([Value] as bit) from @dtFiltros where Catalogo= 'ConComentarios';    
    select @FiltroSinComentarios = cast([Value] as bit) from @dtFiltros where Catalogo= 'SinComentarios';   

    select @FiltroArchivado = cast([Value] as bit) from @dtFiltros where Catalogo= 'Archivados';    
    select @FiltroNoArchivado = cast([Value] as bit) from @dtFiltros where Catalogo= 'NoArchivados';   
    

    SET @Conjuncion= isnull(@Conjuncion,'AND');
    DECLARE @StringFiltrosChecklist VARCHAR(MAX),
    @StringFiltrosFechas VARCHAR(MAX),
    @StringFiltrosAdjuntos VARCHAR(MAX),
    @StringFiltrosComentarios VARCHAR(MAX),
    @StringFiltrosArchivados varchar(max)    ;

    SET @StringFiltrosChecklist = '';
    SET @StringFiltrosFechas = '';
    SET @StringFiltrosAdjuntos = '';
    SET @StringFiltrosComentarios = '';
    set @StringFiltrosArchivados='';

    


    SET @StringFiltrosComentarios += CASE WHEN @FiltroConComentarios = 1 THEN ' (TotalComentarios > 0) OR' ELSE '' END;
    SET @StringFiltrosComentarios += CASE WHEN @FiltroSinComentarios = 1 THEN ' (isnull(TotalComentarios,0) = 0) OR' ELSE '' END;    
    IF RIGHT(@StringFiltrosComentarios, 2) = 'OR'
    BEGIN
        SET @StringFiltrosComentarios = LEFT(@StringFiltrosComentarios, LEN(@StringFiltrosComentarios) - 2);
    END;
    

    SET @StringFiltrosAdjuntos += CASE WHEN @FiltroConAdjuntos = 1 THEN ' (TotalAdjuntos > 0) OR' ELSE '' END;
    SET @StringFiltrosAdjuntos += CASE WHEN @FiltroSinAdjuntos = 1 THEN ' (isnull(TotalAdjuntos,0) = 0) OR' ELSE '' END;    
    IF RIGHT(@StringFiltrosAdjuntos, 2) = 'OR'
    BEGIN
        SET @StringFiltrosAdjuntos = LEFT(@StringFiltrosAdjuntos, LEN(@StringFiltrosAdjuntos) - 2);
    END;

    
    SET @StringFiltrosChecklist += CASE WHEN @FiltroChecklistCompletados = 1 THEN ' (TotalCheckListActivos > 0 And TotalCheckListNoActivos=0) OR' ELSE '' END;
    SET @StringFiltrosChecklist += CASE WHEN @FiltroChecklistNoCompletados = 1 THEN ' (TotalCheckListActivos >= 0 And TotalCheckListNoActivos>0) OR' ELSE '' END;
    SET @StringFiltrosChecklist += CASE WHEN @FiltroConChecklist = 1 THEN ' (TotalCheckListActivos > 0 OR TotalCheckListNoActivos > 0) OR' ELSE '' END;
    SET @StringFiltrosChecklist += CASE WHEN @FiltroSinChecklist = 1 THEN ' ( ISNULL(TotalCheckListActivos,0) = 0 And ISNULL(TotalCheckListNoActivos,0)=0) OR' ELSE '' END;
    IF RIGHT(@StringFiltrosChecklist, 2) = 'OR'
    BEGIN
        SET @StringFiltrosChecklist = LEFT(@StringFiltrosChecklist, LEN(@StringFiltrosChecklist) - 2);
    END;

    -- select * from tareas.tblTareas
    

    SET @StringFiltrosFechas = CASE WHEN @FiltroFechasVencidas = 1 THEN ' (FechaFin <= GETDATE()) OR' ELSE '' END;
    SET @StringFiltrosFechas += CASE WHEN @FiltroFechasNoFechas = 1 THEN ' (FechaInicio IS NULL AND FechaFin IS NULL) OR' ELSE '' END;
    SET @StringFiltrosFechas += CASE WHEN @FiltroFechasConFechas = 1 THEN ' (FechaInicio IS NOT NULL OR FechaFin IS NOT NULL) OR' ELSE '' END;
    SET @StringFiltrosFechas += CASE WHEN @FiltroFechaFin IS NOT NULL THEN ' FechaFin <= ''' + CONVERT(VARCHAR, @FiltroFechaFin, 120) + ''' OR ' ELSE '' END;
    SET @StringFiltrosFechas += CASE WHEN @FiltroFechaInicio IS NOT NULL THEN ' (FechaInicio >= ''' + CONVERT(VARCHAR, @FiltroFechaInicio, 120) + ''') OR' ELSE '' END;
    -- SET @StringFiltrosFechas += CASE WHEN @FiltroFechaInicio IS NOT NULL AND @FiltroFechaFin IS NOT NULL THEN ' (FechaInicio >= ''' + CONVERT(VARCHAR, @FiltroFechaInicio, 120) + ''' AND FechaFin <= ''' + CONVERT(VARCHAR, @FiltroFechaFin, 120) + ''') OR' ELSE '' END;
    IF RIGHT(@StringFiltrosFechas, 2) = 'OR'
    BEGIN
        SET @StringFiltrosFechas = LEFT(@StringFiltrosFechas, LEN(@StringFiltrosFechas) - 2);
    END;
        

    
    SET @StringFiltrosArchivados += CASE WHEN @FiltroArchivado = 1 THEN ' Archivado = 1 OR' ELSE '' END;
    SET @StringFiltrosArchivados += CASE WHEN @FiltroNoArchivado = 1 THEN ' Archivado = 0 OR' ELSE '' END;

    IF RIGHT(@StringFiltrosArchivados, 2) = 'OR'
    BEGIN
        SET @StringFiltrosArchivados = LEFT(@StringFiltrosArchivados, LEN(@StringFiltrosArchivados) - 2);
    END;


	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 
    
    IF OBJECT_ID('tempdb..#TempTareas') IS NOT NULL DROP TABLE #TempTareas;      
    CREATE TABLE #TempTareas (
        IDTarea INT,
        Titulo NVARCHAR(100),
        TieneDescripcion BIT,
        FechaInicio DATE,
        FechaFin DATE,
        IDPrioridad INT,
        Orden INT,
        Archivado BIT,
        TotalCheckListActivos INT,
        TotalCheckListNoActivos INT,
        IDUsuariosAsignados NVARCHAR(MAX),
        TotalComentarios INT,
        TotalAdjuntos INT,
        IDEstatusTarea int 
        
    );  

    DECLARE @FiltroIDsTareasResultFiltros varchar(max);
    DECLARE @IDsUsuariosTabla TABLE (IDUsuario INT);    
    INSERT INTO @IDsUsuariosTabla
    SELECT CAST(value AS INT) AS IDUsuario
    FROM STRING_SPLIT(@FiltroIDSUsuarios, ',');

    SELECT @FiltroIDsTareasResultFiltros = STRING_AGG(t.IDTarea, ',') WITHIN GROUP (ORDER BY t.IDTarea)
    FROM tareas.tblTareas t
    CROSS JOIN @IDsUsuariosTabla u
    WHERE CHARINDEX('{"IDUsuario":' + CAST(u.IDUsuario AS VARCHAR) + '}', t.IDUsuariosAsignados) > 0 AND IDTipoTablero = @IDTipoTablero AND IDReferencia = @IDReferencia AND Archivado=0;
        

    set @FiltroIDsTareasResultFiltros= isnull(@FiltroIDsTareasResultFiltros,'0');

    SET @QueryMain= N'      
        SELECT [IDTarea],
            [Titulo],
            case when isnull([Descripcion],'''') = '''' then cast(0 as bit) else cast(1 as bit) end  as TieneDescripcion  ,                                    
            [FechaInicio],
            [FechaFin],
            [IDPrioridad] ,
            Orden,
            isnull(Archivado,0) as Archivado,            
            isnull(TotalCheckListActivos,0) as TotalCheckListActivos,
            isnull(TotalCheckListNoActivos,0) as TotalCheckListNoActivos,                     
            IDUsuariosAsignados AS IDUsuariosAsignados ,
            isnull(TotalComentarios,0)  as TotalComentarios ,
            isnull(TotalAdjuntos,0) AS TotalAdjuntos        ,
            isnull(IDEstatusTarea,0) as IDEstatusTarea
        From Tareas.tblTareas  ttm
        WHERE     

            '+(case when isnull(@IDTarea,0) =0 then 
                '                        
                    ( (IDTipoTablero = '+ CAST(isnull(@IDTipoTablero,0) AS varchar(10))+' AND IDReferencia = '+ CAST(ISNULL(@IDReferencia,0) AS varchar(10))+') )
                        '+ ( case when isnull(@IDEstatusTarea,0) = 0 then '' else ('AND IDEstatusTarea='+ cast(@IDEstatusTarea as varchar(10))) end ) +'
                        AND
                        (            
                            1='+ (case when @Conjuncion='AND' then '1' else '0' end )+ '                           
                            '+ (case when @FiltroIDSUsuarios <> '' and @FiltroSinMiembros=1 then (@Conjuncion + ( ' ( IDTarea in ('+@FiltroIDsTareasResultFiltros+') OR IDUsuariosAsignados = ''[]'' )'))
                                    when @FiltroIDSUsuarios <> ''  then (@Conjuncion + '( IDTarea in ('+@FiltroIDsTareasResultFiltros+') )') 
                                    when @FiltroSinMiembros=1 then ( @Conjuncion + ' IDUsuariosAsignados = ''[]'' ' ) 
                                    else ''
                                end)+'
                            '+ (case when @FiltroIDPrioridad <> '' THEN ( @Conjuncion+ ' isnull(IDPrioridad,0) IN ( Select item from App.Split('''+@FiltroIDPrioridad+''','',''))' ) else '' end)+'
                            '+ (case when @StringFiltrosFechas <>'' THEN (@Conjuncion+ ' ( '+@StringFiltrosFechas+')') else '' end )+'
                            '+ (case when @StringFiltrosChecklist <>'' THEN (@Conjuncion+ ' ( '+@StringFiltrosChecklist+')') else '' end )+'
                            '+ (case when @StringFiltrosAdjuntos <>'' THEN (@Conjuncion+ ' ( '+@StringFiltrosAdjuntos+')') else '' end )+'
                            '+ (case when @StringFiltrosComentarios <>'' THEN (@Conjuncion+ ' ( '+@StringFiltrosComentarios+')') else '' end )+'
                            
                        )   
                        '+(case when @StringFiltrosArchivados <> '' then (@Conjuncion + '( '+@StringFiltrosArchivados+' )') else ' AND Archivado=0' end)+'
                        '+( case when  @query='""' then '' else' AND contains(ttm.*, '' '+@query+' '')' end )+'            
                '
            else 
                'IDTarea = '+CAST(ISNULL(@IDTarea,0) AS varchar(10))            
            end  );            

print 'pastor';
    print @QueryMain;
    INSERT INTO #TempTareas
    EXEC (@QueryMain);        
         
    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempTareas

	select @TotalRegistros = cast(COUNT([IDTarea]) as decimal(18,2)) from #TempTareas		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,@TotalRegistros as TotalRegistros
	from #TempTareas
	order by 
		
		Orden asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

end
GO

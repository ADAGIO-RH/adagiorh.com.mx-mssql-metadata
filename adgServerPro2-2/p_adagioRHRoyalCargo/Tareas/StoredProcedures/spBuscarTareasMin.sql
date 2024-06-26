USE [p_adagioRHRoyalCargo]
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
    @Prioridad varchar(100)='',
    @FiltroUsuarios varchar(max)='',
    @FlagUsuarios bit=null,
    @FechaInicio date =null,     
    @FechaFin date =null,     
    @FlagFecha bit=null,
    @FlagFechasVencidas bit=0,
    @Conjuncion varchar(3) ='AND',
    @Archivado bit =0,	
    @PageNumber	int = 1,    
	@PageSize		int = 2147483647,
	@query			varchar(100) = '""',
	@orderByColumn	varchar(50) = 'Orden',
	@orderDirection varchar(4) = 'asc'
) as
begin

    declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int = 0
	   ,@IDIdioma varchar(max),
       @QueryMain as varchar(max);
	;
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
        TotalAdjuntos INT
        
    );  


    set @QueryMain= N'      
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
            isnull(TotalAdjuntos,0) AS TotalAdjuntos        
        From Tareas.tblTareas  ttm
        WHERE         
            ( (IDTipoTablero = '+ CAST(@IDTipoTablero AS varchar(10))+' AND IDReferencia = '+ CAST(ISNULL(@IDReferencia,0) AS varchar(10))+') OR IDTarea = ' +CAST(ISNULL(@IDTarea,0) AS varchar(10))+')
            AND
            (            
                '+ (case when @Conjuncion='AND' then ' (1=1) ' else ' (1=0 ) ' end )+ '
                '+ ( case when isnull(@IDEstatusTarea,0) = 0 then '' else (@Conjuncion +' IDEstatusTarea='+ cast(@IDEstatusTarea as varchar(10))) end ) +'
                '+ (case when isnull(@Prioridad,'')='' then '' else ( @Conjuncion+ ' isnull(IDPrioridad,0) IN ( Select item from App.Split('''+@Prioridad+''','',''))' ) end )+'
                '+ (case when @FlagFechasVencidas = 0 then ''  else ( @Conjuncion+ ' FechaFin <= GETDATE()') end )+'
                '+ (case when @FlagFecha is null  then ''  when @FlagFecha=0 then  ( @Conjuncion+ ' FechaInicio is null and FechaFin is null')   else ( @Conjuncion+ ' FechaInicio is not null or  FechaFin is not null')   end )+'
                '+ (case when @FlagUsuarios is null  then ''  when @FlagUsuarios=0 then  ( @Conjuncion+ ' IDUsuariosAsignados = ''[]'' ' )   else ( @Conjuncion+ ' IDUsuariosAsignados <> ''[]'' ' )    end )+'
                '+ (case when @FechaInicio is null  then ''  else (@Conjuncion + ' FechaInicio >= '' '  +CONVERT(VARCHAR, @FechaInicio, 120) + ' '' ' ) end )+'
                '+ (case when @FechaFin is null  then ''  else (@Conjuncion + ' FechaFin <= '' '  +CONVERT(VARCHAR, @FechaFin, 120) + ' '' ' ) end )+'                        
            )  
        AND Archivado=0';            

    print @QueryMain;
    INSERT INTO #TempTareas
    EXEC (@QueryMain);        
          
    IF ISNULL(@FiltroUsuarios,'')<>'' and @Conjuncion='AND'
    BEGIN        
        DECLARE @IDsUsuariosTabla TABLE (IDUsuario INT);
        INSERT INTO @IDsUsuariosTabla
        SELECT CAST(value AS INT) AS IDUsuario
        FROM STRING_SPLIT(@FiltroUsuarios, ',');
        
        delete from #TempTareas where IDTarea not in (
            SELECT DISTINCT t.IDTarea            
                FROM tareas.tblTareas t        
            CROSS JOIN @IDsUsuariosTabla u
            WHERE CHARINDEX('{"IDUsuario":' + CAST(u.IDUsuario AS VARCHAR) + '}', t.IDUsuariosAsignados) > 0
        )        
    END 
     
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

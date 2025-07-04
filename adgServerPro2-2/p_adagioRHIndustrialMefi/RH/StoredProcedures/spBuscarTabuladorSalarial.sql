USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [RH].[spBuscarTabuladorSalarial] (
	@IDNivelSalarial int = 0,
    @Nombre varchar(150),
	@Nivel int = 0,
    @Estatus int =1 ,
	@IDUsuario int,
    @PageNumber	int = 1,
	@PageSize		int = 2147483647,
	@query			varchar(100) = null,
	@orderByColumn	varchar(50) = 'Nombre',
	@orderDirection varchar(4) = 'asc'
) as

    declare @tempResponse as table (
		    IDNivelSalarial   int ,
            Nivel       int,
            Minimo		decimal(18,2),
		    Q1			decimal(18,2),
		    Medio		decimal(18,2),
		    Q3			decimal(18,2),
		    Maximo		decimal(18,2),
		    Amplitud	decimal(18,4),
		    Progresion	decimal(18,4),
            Nombre varchar(150)  ,  
            MinNivel       int,
            MaxNivel       int,
            OrderDesc bit,
            Estatus int
        );

    declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int = 0
	;
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Nombre' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

    insert into @tempResponse
	select 
		ts.IDNivelSalarial,
		ts.Nivel,
		ts.Minimo,
		ts.Q1,
		ts.Medio,
		ts.Q3,
		ts.Maximo,
		ts.Amplitud,
		ts.Progresion,
        ts.Nombre ,  0,0 ,1,
        ts.Estatus as Estatus
	from RH.tblTabuladorSalarial ts with(nolock)
	where  (ts.IDNivelSalarial = @IDNivelSalarial or isnull(@IDNivelSalarial, 0) = 0)
		and (ts.Nivel = @Nivel or isnull(@Nivel, 0) = 0) 
		and (Nombre = @query or @query is null) 
		and (Nombre = @Nombre or @Nombre is null)  
		and (ts.Estatus=@Estatus or isnull(@Estatus, 0)= 0)
	order by Nombre,Nivel asc
	--(isnull(@IDNivelSalarial,0) <> 0)

    update  s 
        set s.MinNivel = (select min(Nivel) from RH.tblTabuladorSalarial where Nombre=s.Nombre) ,
         s.MaxNivel = (select max(Nivel) from RH.tblTabuladorSalarial where Nombre=s.Nombre)          
    from @tempResponse s
    
    update s 
        set OrderDesc =case when  (select Minimo from RH.tblTabuladorSalarial where Nivel=s.MinNivel and Nombre=s.Nombre)  > (select Minimo from RH.tblTabuladorSalarial where Nivel=s.MaxNivel and Nombre=s.Nombre)                               
                            then 0 else 1 end 
    from @tempResponse s
                

    select @TotalRegistros = cast(COUNT([IDNivelSalarial]) as int) from @tempResponse		
    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2))) from @tempResponse

	select [IDNivelSalarial],
    [Nivel],
    [Minimo],
    [Q1],
    [Medio],
    [Q3],
    [Maximo],
    [Amplitud],
    [Progresion],
    isnull([Nombre],'')  as Nombre,
    isnull([MinNivel],0) as MinNivel,
    isnull([MaxNivel],0) as MaxNivel,
    [OrderDesc],
    [Estatus]
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
        ,TotalRows = @TotalRegistros
	from @tempResponse
	order by 
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'asc'		then Nombre end,			
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'desc'	then Nombre end desc ,
        case when @orderByColumn = 'Nivel'			and @orderDirection = 'asc'		then Nivel end,			
		case when @orderByColumn = 'Nivel'			and @orderDirection = 'desc'	then Nivel end desc ,
        case when @orderByColumn = 'Nombre'	        then nivel  end	ASC	
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

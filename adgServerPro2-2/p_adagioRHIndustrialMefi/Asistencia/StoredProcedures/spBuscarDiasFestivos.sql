USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Asistencia].[spBuscarDiasFestivos] --@IDUsuario = 1, @query='""', @IDDiaFestivo = 0, @Ejercicio = 0
(
	@IDDiaFestivo int = 0
	,@IDUsuario int 
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Descripcion'
	,@orderDirection varchar(4) = 'asc'
    ,@Ejercicio int =0
)
AS
BEGIN

SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
       ,@IDIdioma VARCHAR(250)
	;
 	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Descripcion' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end

	declare @tempResponse as table (
	 IDDiaFestivo				int   
		,Fecha					DATE
		,FechaReal				DATE    
		,Descripcion			varchar(500)      
		,DescripcionCalendario	varchar(500)      
		,Autorizado				bit      
		,IDPais					int  
		,Pais					varchar(100)
		,Traduccion				varchar(max)
	);


	insert @tempResponse
	SELECT 
		DF.IDDiaFestivo
		,DF.Fecha
		,DF.FechaReal
		,UPPER(JSON_VALUE(DF.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) as Descripcion
		,'[DF] '+coalesce(p.Codigo,'')+' - '+ coalesce(JSON_VALUE(DF.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) ,'') as DescripcionCalendario
		,isnull(DF.Autorizado,0) as Autorizado
		,isnull(DF.IDPais,0) as IDPais
		,ISNULL(p.Descripcion,'SIN ASIGNACIÓN') as Pais
        ,DF.Traduccion
	FROM Asistencia.TblCatDiasFestivos DF with(nolock)
		left join Sat.tblCatPaises p with(nolock)
			on DF.IDPais = p.IDPais
	WHERE ((IDDiaFestivo = @IDDiaFestivo) OR (ISNULL(@IDDiaFestivo,0) = 0)) 
    and ((YEAR(df.FechaReal) = @Ejercicio ) OR (ISNULL(@Ejercicio,0) = 0))     
	and (@query = '""' or contains(df.*, @query)) 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT([IDDiaFestivo]) as decimal(18,2)) from @tempResponse	

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'desc'	then Descripcion end desc,			
		Descripcion asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO

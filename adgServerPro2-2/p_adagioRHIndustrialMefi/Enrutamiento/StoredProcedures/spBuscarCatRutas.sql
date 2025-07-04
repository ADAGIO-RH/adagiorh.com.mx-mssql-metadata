USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: PROCEDIMIENTO PARA BUSCAR CATALOGO DE RUTAS
** Autor			: JOSE ROMAN
** Email			: JROMAN@ADAGIO.COM.MX
** FechaCreacion	: 2022-01-12
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE [Enrutamiento].[spBuscarCatRutas]
(
	@IDCatRuta int = 0,
	@IDCliente int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Nombre'
	,@orderDirection varchar(4) = 'asc'
	,@IDUsuario int 
)
AS
BEGIN
	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
	   ,@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
 
	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;
   
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
				else '"'+@query + '*"' end

	declare @tempResponse as table (
		 IDCatRuta   int   
		,Nombre       varchar(250)
		,IDCatTipoProceso  int  
		,TipoProceso varchar(500)     
		,IDCliente int
		,Cliente Varchar(500)
	);
	
	insert @tempResponse
	SELECT       
		 R.IDCatRuta      
		,R.Nombre       
		,R.IDCatTipoProceso       
		,TP.Codigo as TipoProceso
		,R.IDCliente
		,Cliente = JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial'))
	FROM [Enrutamiento].[tblCatRutas] R with (nolock)     
		left join [Enrutamiento].[tblCatTiposProcesos] TP with (nolock) on R.IDCatTipoProceso = TP.IDCatTipoProceso
		left join RH.tblCatClientes C with(nolock) on R.IDCliente = C.IDCliente

		    
	WHERE ((R.IDCatRuta = @IDCatRuta or isnull(@IDCatRuta,0) = 0))      
		and (@query = '""' or contains(R.*, @query)) 
		and (R.IDCliente = @IDCliente OR ISNULL(@IDCliente,0) = 0)

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT([IDCatRuta]) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'asc'		then Nombre end,			
		case when @orderByColumn = 'Nombre'			and @orderDirection = 'desc'	then Nombre end desc,			
		case when @orderByColumn = 'TipoProceso'	and @orderDirection = 'asc'		then TipoProceso end,			
		case when @orderByColumn = 'TipoProceso'	and @orderDirection = 'desc'	then TipoProceso end desc,							
		Nombre asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO

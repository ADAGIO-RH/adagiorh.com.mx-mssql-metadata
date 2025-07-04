USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Compensaciones].[spBuscarCompensaciones](
	@IDCompensacion int = 0
	,@IDUsuario int 
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Fecha'
	,@orderDirection varchar(4) = 'asc'
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
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Fecha' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 


   
	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query = '""' then '""'
				else '"'+@query + '*"' end

	
	declare @tempResponse as table (
		 IDCompensacion			int not null 
		,Descripcion			Varchar(250) not null
		,IDCatTipoCompensacion	int not null 
		,TipoCompensacion		Varchar(255)
		,IDCliente				int null 
		,Cliente				Varchar(250)
		,IDTipoNomina			int null 
		,TipoNomina				Varchar(250)
		,IDPeriodo				int null 
		,Periodo				Varchar(500)
		,IDConcepto				int null 
		,Concepto				Varchar(500)
		,IDMatrizIncremento		int null 
		,MatrizIncremento		Varchar(250)
		,IDEvaluacion			int null
		,Evaluacion				Varchar(250)
		,Fecha					Date not null
		,bPorcentaje			bit null 
		,bDiasSueldo			bit null 
		,bMonto					bit null 
		,Porcentaje				decimal(18,4) null
		,DiasSueldo				decimal(18,4) null
		,Monto					decimal(18,4) null
	);
	
	insert @tempResponse
	SELECT 
		 C.IDCompensacion			
		,C.Descripcion			
		,C.IDCatTipoCompensacion	
		,TC.Descripcion asTipoCompensacion		
		,isnull(C.IDCliente,0) as IDCliente
		,JSON_VALUE(Clientes.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente				
		,isnull(C.IDTipoNomina,0) as IDTipoNomina
		,TN.Descripcion as TipoNomina				
		,isnull(C.IDPeriodo,0) as IDPeriodo
		,P.Descripcion	as Periodo	
		,isnull(Concepto.IDConcepto,0) as IDConcepto
		,Concepto.Descripcion	as Periodo		
		,isnull(C.IDMatrizIncremento,0) as IDMatrizIncremento
		,MI.Descripcion as MatrizIncremento		
		,isnull(C.IDEvaluacion,0) as IDEvaluacion			
		,'' as Evaluacion				
		,C.Fecha					
		,isnull(C.bPorcentaje,0) as bPorcentaje
		,isnull(C.bDiasSueldo,0) as	bDiasSueldo		
		,isnull(C.bMonto,0) as bMonto					
		,isnull(C.Porcentaje,0) as Porcentaje 				
		,isnull(C.DiasSueldo,0) as DiasSueldo 				
		,isnull(C.Monto		,0) as Monto		 			
	FROM [Compensaciones].[TblCompensaciones] C With(nolock)
		inner join [Compensaciones].[tblCatTiposCompensaciones] TC With(nolock) on C.IDCatTipoCompensacion = TC.IDCatTipoCompensacion
		left join  [RH].[tblCatClientes] Clientes With(nolock) on clientes.IDCliente = C.IDCliente
		left join  [Nomina].[TblcatTipoNomina] TN With(nolock) on TN.IDTipoNomina = C.IDTipoNomina
		left join  [Nomina].[TblCatPeriodos] P with(nolock) on P.IDPeriodo = C.IDPeriodo
		left join  [Nomina].[tblCatConceptos] Concepto with(nolock) on Concepto.IDConcepto = C.IDConcepto
		left join  [Compensaciones].[tblMatrizIncremento] MI with(nolock) on MI.IDMatrizIncremento = C.IDMatrizIncremento
	WHERE ((C.IDCompensacion = isnull(@IDCompensacion,0) or isnull(@IDCompensacion,0) = 0))    
		and ((@query = '""' or (contains(C.*, @query)) ) ) 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT([IDCompensacion]) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 		
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'desc'	then Descripcion end desc,	
		case when @orderByColumn = 'Fecha'			and @orderDirection = 'asc'		then Fecha end,			
		case when @orderByColumn = 'Fecha'			and @orderDirection = 'desc'	then Fecha end desc,
		Descripcion asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO

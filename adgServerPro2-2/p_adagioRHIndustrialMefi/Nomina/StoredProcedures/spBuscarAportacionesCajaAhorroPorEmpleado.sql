USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Buscar el detalle de aportaciones de caja de ahorro
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-11-27
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?

[Nomina].[spBuscarAportacionesCajaAhorroPorEmpleado]
		@IDCajaAhorro	= 1
		,@IDEmpleado	= 1279
		,@IDUsuario		= 1
***************************************************************************************************/
CREATE proc [Nomina].[spBuscarAportacionesCajaAhorroPorEmpleado](
		@IDCajaAhorro	int	--= 2
		,@IDEmpleado	int	--= 1279
		,@IDUsuario		int
        ,@PageNumber	int = 1
        ,@PageSize		int = 2147483647
        ,@query			varchar(100) = '""'
        ,@orderByColumn	varchar(50) = 'Fecha'
        ,@orderDirection varchar(4) = 'desc'   
) as
	--declare @IDFondoAhorro	int = 4
	--		,@IDEmpleado	int = 1279
	--		,@IDUsuario		int = 1
	declare  
			@IDPeriodoInicial	   int
			,@IDPeriodoFinal	   int 
			,@CodigoConceptoCajaAhorro varchar(10) = '320'
            ,@TotalPaginas INT = 0
	        ,@TotalRegistros INT 
		    ,@IDIdioma VARCHAR(20)
	 ;

    	SELECT @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	IF (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	IF (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	SELECT
		 @orderByColumn	 = CASE WHEN @orderByColumn	 IS NULL THEN 'Fecha' ELSE @orderByColumn  END
		,@orderDirection = CASE WHEN @orderDirection IS NULL THEN  'desc' ELSE @orderDirection END

	SET @query = CASE
					WHEN @query IS NULL THEN '""' 
					WHEN @query = '' THEN '""'
					WHEN @query =  '""' THEN '""'
				    ELSE '"'+@query + '*"' END

	IF OBJECT_ID('tempdb..#TempAportacionesCajaAhorro') IS NOT NULL DROP TABLE #TempAportacionesCajaAhorro;

	
	Select	dp.IDDetallePeriodo
			,IDEmpleado  
			,DP.IDConcepto  
			,c.Codigo
			, p.FechaFinPago as Fecha
			-- ,coalesce(UPPER(p.ClavePeriodo),'')+'-'+coalesce(UPPER(p.Descripcion),'') as Periodo
            ,UPPER(p.ClavePeriodo) as Periodo
            ,UPPER(P.Descripcion) as DescripcionPeriodo
			,ISNULL(DP.ImporteTotal1,0) as Monto
			,c.Descripcion as Concepto
    INTO #TempAportacionesCajaAhorro            
	from Nomina.tblDetallePeriodo DP  
		Inner join Nomina.tblCatPeriodos P on DP.IDPeriodo = P.IDPeriodo AND DP.IDEmpleado = @IDEmpleado AND P.Cerrado = 1  
		Inner join Nomina.tblCatConceptos c on dp.IDConcepto = c.IDConcepto  
	where c.Codigo = @CodigoConceptoCajaAhorro
    and (@query = '""' or contains(p.*, @query)) 
	order by p.FechaInicioPago asc

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempAportacionesCajaAhorro

	select @TotalRegistros = cast(COUNT(IDDetallePeriodo) as decimal(18,2)) from #TempAportacionesCajaAhorro
	
	select	*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempAportacionesCajaAhorro
	order by 	
		case when @orderByColumn = 'Fecha' and @orderDirection = 'asc'	then Fecha end,			
		case when @orderByColumn = 'Fecha' and @orderDirection = 'desc'	then Fecha end desc
			
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

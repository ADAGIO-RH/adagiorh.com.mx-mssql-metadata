USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Buscar periodos según los valores de los parámetros que recibe
** Autor			: Jose Rafael Román
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2018-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-04-23			Aneudy Abreu	Se agregó el parámetro @Ejercicio 
2024-06-12			Aneudy Abreu	Se agregaron los parámetros @SoloCerrados y @SoloFiniquito
2024-10-02			Jose Roman		Se agrega el parametro de Presupuesto para distinguir si estoy
									en nómina standart o presupuesto.
***************************************************************************************************/
CREATE PROCEDURE [Nomina].[spBuscarCatPeriodos](
	@IDPeriodo		int = null
	,@IDCliente		int = null
	,@IDTipoNomina	int = null
	,@Ejercicio		int = 0
    ,@TodosEstatus  bit = 1
	,@SoloCerrados	bit = 0
    ,@SoloAbiertos  bit = 0    
	,@TodosTipoPeriodo bit = 1
    ,@SoloGeneral bit = 0    
	,@SoloFiniquito bit = 0
    ,@SoloEspecial bit = 0
	,@Presupuesto   bit = 0
	,@IDUsuario		int = null    
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'FechaFinPago'
	,@orderDirection varchar(4) = 'desc'
)
AS
BEGIN
	SET FMTONLY OFF;

	DECLARE
		@IDIdioma varchar(20)
	   ,@TotalPaginas int = 0
	   ,@TotalRegistros int
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	  
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'FechaFinPago' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#tempPeriodos') IS NOT NULL DROP TABLE #tempPeriodos
	
	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end

	SELECT 
		p.IDPeriodo
		, isnull(p.IDTipoNomina,0) as IDTipoNomina
		,tn.Descripcion as TipoNomina
		, isnull(tn.IDPeriodicidadPago,0) as IDPeriodicidadPago
		,UPPER(pp.Descripcion) as PerioricidadPago
		, ISNULL(tn.IDCliente,0) as IDCliente
		,JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente
		,isnull(p.Ejercicio,0) as Ejercicio
		,UPPER(p.ClavePeriodo) AS ClavePeriodo
		,UPPER(p.Descripcion) AS Descripcion
		,p.FechaInicioPago
		,p.FechaFinPago
		,p.FechaInicioIncidencia
		,p.FechaFinIncidencia
		,isnull(p.Dias,0) as Dias
		,isnull(p.AnioInicio,0) as AnioInicio
		,isnull(p.AnioFin,0) as AnioFin
		,isnull(p.MesInicio,0) as MesInicio
		,isnull(p.MesFin,0) as MesFin
		,p.IDMes
		,JSON_VALUE(m.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) Mes
		,isnull(p.BimestreInicio,0) as BimestreInicio
		,isnull(p.BimestreFin,0) as BimestreFin
		,isnull(p.General,0) as General
		,isnull(p.Finiquito,0) as Finiquito
		,isnull(p.Especial,0) as Especial
		,isnull(p.Cerrado,0) as Cerrado
		,isnull(p.Aguinaldo,0) as Aguinaldo
		,isnull(p.PTU,0) as PTU
		,isnull(p.DevolucionFondoAhorro,0) as DevolucionFondoAhorro
		,isnull(p.Presupuesto,0) as Presupuesto
		,coalesce(UPPER(p.ClavePeriodo),'')+' '+coalesce(UPPER(substring(m.Descripcion,1,3)),'')+' '+coalesce(UPPER(p.Descripcion),'') as FullDescripcion
		,coalesce(UPPER(c.NombreComercial),'')+' ['+coalesce(UPPER(tn.Descripcion),'')+']' as ClienteTipoNomina
		,ROWNUMBER = ROW_NUMBER()Over(ORDER BY p.IDPeriodo)
	into #tempPeriodos
	FROM Nomina.tblCatPeriodos p with (nolock)
		inner join Nomina.tblCatTipoNomina tn with (nolock) on p.IDTipoNomina = tn.IDTipoNomina
		inner join Sat.tblCatPeriodicidadesPago pp with (nolock) on tn.IDPeriodicidadPago = pp.IDPeriodicidadPago
		inner join Nomina.tblCatMeses m with (nolock) on p.IDMes = m.IDMes
		inner join RH.tblCatClientes c with (nolock) on tn.IDCliente = c.IDCliente
	where (p.IDPeriodo = @IDPeriodo or isnull(@IDPeriodo,0) = 0)
		and (tn.IDCliente = @IDCliente or isnull(@IDCliente,0) = 0)
		and (tn.IDTipoNomina = @IDTipoNomina or isnull(@IDTipoNomina,0) = 0)
		and (p.Ejercicio = @Ejercicio or isnull(@Ejercicio,0) = 0)
		and (isnull(p.Cerrado, 0) = case when isnull(@SoloCerrados, 0) = 1 then 1 else isnull(p.Cerrado,0) end)
		-- and (isnull(p.Finiquito, 0) = case when isnull(@SoloFiniquito, 0) = 1 then 1 else isnull(p.Finiquito,0) end)
		-- and (isnull(p.Presupuesto, 0)  = case when isnull(@Presupuesto, 0) = 1 then 1 else 0 end)
        AND (
                (ISNULL(@TodosTipoPeriodo,0) = 1 AND ISNULL(@SoloEspecial,0) = 0 AND ISNULL(@SoloFiniquito,0) = 0 AND ISNULL(@SoloGeneral,0) = 0 AND ISNULL(@Presupuesto,0) = 0)
                OR (ISNULL(@SoloEspecial,0) = 1 AND ISNULL(p.Especial, 0) = 1)
                OR (ISNULL(@SoloFiniquito,0) = 1 AND ISNULL(p.Finiquito, 0) = 1)
                OR (ISNULL(@SoloGeneral,0) = 1 AND ISNULL(p.General, 0) = 1)
                OR (ISNULL(@Presupuesto,0) = 1 AND ISNULL(p.Presupuesto, 0) = 1)
        )
        AND (
                (ISNULL(@TodosEstatus,0) = 1 AND ISNULL(@SoloAbiertos,0) = 0 AND ISNULL(@SoloCerrados,0) = 0)
                OR (ISNULL(@SoloAbiertos,0) = 1 AND ISNULL(p.Cerrado, 0) = 0)
                OR (ISNULL(@SoloCerrados,0) = 1 AND ISNULL(p.Cerrado, 0) = 1)                
        )
		and ( 
			(@query = '""' or contains(p.*, @query)) OR
			(@query = '""' or contains(C.*, @query)) OR
			(@query = '""' or contains(pp.*, @query)) OR
			(@query = '""' or contains(tn.*, @query)) OR
			(@query = '""' or contains(m.*, @query))
		) 
	--order by p.Ejercicio desc, p.ClavePeriodo asc	

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempPeriodos

	select @TotalRegistros = COUNT(IDPeriodo) from #tempPeriodos		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempPeriodos
	order by 
		case when @orderByColumn = 'FechaFinPago'			and @orderDirection = 'asc'		then FechaFinPago end,			
		case when @orderByColumn = 'FechaFinPago'			and @orderDirection = 'desc'	then FechaFinPago end desc,	
		case when @orderByColumn = 'Cliente'			and @orderDirection = 'asc'		then Cliente end,			
		case when @orderByColumn = 'Cliente'			and @orderDirection = 'desc'	then Cliente end desc,		
		case when @orderByColumn = 'ClavePeriodo'			and @orderDirection = 'asc'		then ClavePeriodo end,			
		case when @orderByColumn = 'ClavePeriodo'			and @orderDirection = 'desc'	then ClavePeriodo end desc,	
		case when @orderByColumn = 'Ejercicio'			and @orderDirection = 'asc'		then Ejercicio end,			
		case when @orderByColumn = 'Ejercicio'			and @orderDirection = 'desc'	then Ejercicio end desc,	
		case when @orderByColumn = 'Mes'			and @orderDirection = 'asc'		then Mes end,			
		case when @orderByColumn = 'Mes'			and @orderDirection = 'desc'	then Mes end desc,	
		case when @orderByColumn = 'PerioricidadPago'			and @orderDirection = 'asc'		then PerioricidadPago end,			
		case when @orderByColumn = 'PerioricidadPago'			and @orderDirection = 'desc'	then PerioricidadPago end desc,	
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'desc'	then Descripcion end desc,	
		case when @orderByColumn = 'Dias'			and @orderDirection = 'asc'		then Dias end,			
		case when @orderByColumn = 'Dias'			and @orderDirection = 'desc'	then Dias end desc,	
		case when @orderByColumn = 'FechaInicioPago'			and @orderDirection = 'asc'		then FechaInicioPago end,			
		case when @orderByColumn = 'FechaInicioPago'			and @orderDirection = 'desc'	then FechaInicioPago end desc,	
		case when @orderByColumn = 'FechaInicioIncidencia'			and @orderDirection = 'asc'		then FechaInicioIncidencia end,			
		case when @orderByColumn = 'FechaInicioIncidencia'			and @orderDirection = 'desc'	then FechaInicioIncidencia end desc,	
		case when @orderByColumn = 'FechaFinIncidencia'			and @orderDirection = 'asc'		then FechaFinIncidencia end,			
		case when @orderByColumn = 'FechaFinIncidencia'			and @orderDirection = 'desc'	then FechaFinIncidencia end desc,	
		FechaFinPago desc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO

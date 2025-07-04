USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************     
** Descripción  : BUSCAR los PTU's     
** Autor   : Jose Roman   
** Email   : jose.roman@adagio.com.mx    
** FechaCreacion : 2019-04-30    
** Paremetros  :                  
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
  
***************************************************************************************************/   

CREATE PROCEDURE [Nomina].[spBuscarPTU] (
	@IDPTU int = 0
	,@IDUsuario int = null    
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Ejercicio'
	,@orderDirection varchar(4) = 'asc'
)
AS
BEGIN
	
	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	;
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Ejercicio' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempDepartamentos') IS NOT NULL DROP TABLE #TempDepartamentos 
	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end

	SELECT PTU.IDPTU
		,PTU.IDEmpresa
		,emp.NombreComercial
		,emp.RFC
		,PTU.Ejercicio
		,PTU.ConceptosIntegranSueldo
		,PTU.DiasMinimosTrabajados
		,PTU.DiasDescontar
		,PTU.DescontarIncapacidades
		,PTU.TiposIncapacidadesADescontar
		,PTU.CantidadGanancia 
		,PTU.CantidadRepartir 
		,PTU.CantidadPendiente 
		,PTU.EjercicioPago
		,ISNULL(PTU.IDPeriodo, 0) as IDPeriodo
		,ISNULL(p.Descripcion,'[SIN PERIODO SELECCIONADO]') as Periodo
		,ISNULL(PTU.MontoSueldo, 0) as MontoSueldo
		,ISNULL(PTU.MontoDias, 0) as MontoDias
		,ISNULL(PTU.FactorSueldo, 0) as FactorSueldo
		,ISNULL(PTU.FactorDias, 0) as FactorDias
		,ISNULL(PTU.IDEmpleadoTipoSalarioMensualConfianza, 0) as IDEmpleadoTipoSalarioMensualConfianza
		,ISNULL(coalesce(e.ClaveEmpleado,'')+'-'+coalesce(e.NombreCompleto,''), '[NO SE A DETERMINADO EL TOPE]') as ColaboradorTopeMaximoConfianza
		,ISNULL(PTU.TopeSalarioMensualConfianza, 0) as TopeSalarioMensualConfianza 
		,ISNULL(PTU.TopeConfianza, 0) as TopeConfianza
		,isnull(ptu.AplicarReforma, 0) as AplicarReforma
		,isnull(ptu.AplicarPTUFinanciero, 0) as AplicarPtuFinanciero
		,ROW_NUMBER()over(Order by PTU.IDPTU ASC) as ROWNUMBER
		into #tempResponse
	from Nomina.tblPTU PTU with (nolock)
		inner join RH.tblEmpresa Emp with (nolock) on PTU.IDEmpresa = Emp.IdEmpresa
		left join Nomina.tblCatPeriodos p with (nolock) on p.IDPeriodo = PTU.IDPeriodo
		left join RH.tblEmpleadosMaster e with (nolock) on e.IDEmpleado = PTU.IDEmpleadoTipoSalarioMensualConfianza
	Where (PTU.IDPTU = @IDPTU)  OR (@IDPTU = 0)
	and ((@query = '""' or contains(Emp.*, @query))OR ( (@query = '""' or contains(p.*, @query)))) 


	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDPTU) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Ejercicio'			and @orderDirection = 'asc'		then Ejercicio end,			
		case when @orderByColumn = 'Ejercicio'			and @orderDirection = 'desc'	then Ejercicio end desc,		
		Ejercicio asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);


END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca préstamos de Fondo de Ahorro
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2019-05-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
***************************************************************************************************/
CREATE proc [Nomina].[spBuscarPrestamosFondoAhorro](
	 @IDPrestamoFondoAhorro	int = 0
	,@IDFondoAhorro			int	= 0
	,@IDPrestamo			int	= 0
    ,@IDEmpleado			int	= 0
	,@IDUsuario int
    ,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query			varchar(100) = '""'
    ,@orderByColumn	varchar(50) = 'FechaInicioPago'
    ,@orderDirection varchar(4) = 'desc'   
) as 

DECLARE  
	   @TotalPaginas INT = 0
	   ,@TotalRegistros INT, 
		@IDIdioma VARCHAR(20)
	;

	SELECT @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	IF (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	IF (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	SELECT
		 @orderByColumn	 = CASE WHEN @orderByColumn	 IS NULL THEN 'FechaInicioPago' ELSE @orderByColumn  END
		,@orderDirection = CASE WHEN @orderDirection IS NULL THEN  'desc' ELSE @orderDirection END

	SET @query = CASE
					WHEN @query IS NULL THEN '""' 
					WHEN @query = '' THEN '""'
					WHEN @query =  '""' THEN '""'
				    ELSE '"'+@query + '*"' END

	IF OBJECT_ID('tempdb..#TempPrestamos') IS NOT NULL DROP TABLE #TempPrestamos;
	
	select     
		P.IDPrestamo    
		,P.Codigo    
		,P.IDEmpleado    
		,E.ClaveEmpleado    
		,E.Nombre    
		,E.SegundoNombre    
		,E.Paterno    
		,E.Materno    
		,COALESCE(E.Paterno,'')+' '+COALESCE(E.Materno,'')+' '+COALESCE(E.Nombre,'')+' '+COALESCE(E.SegundoNombre,'') AS NOMBRECOMPLETO    
		,P.IDTipoPrestamo    
		-- ,TP.Descripcion as TipoPrestamo    
        ,JSON_VALUE(TP.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as TipoPrestamo
		,P.IDEstatusPrestamo    
		,EP.Descripcion as EstatusPrestamo    
		,P.MontoPrestamo    
		,P.Cuotas    
		,P.CantidadCuotas    
		,P.Descripcion    
		,P.FechaCreacion    
		,P.FechaInicioPago    
		,(P.MontoPrestamo + isnull(P.Intereses,0))- isnull((Select Sum(MontoCuota) from Nomina.fnPagosPrestamo(P.IDPrestamo)),0)  as Balance           
        ,isnull(P.Intereses,0) as Intereses
		,ROW_NUMBER()Over(order by p.IDPrestamo) as ROWNUMBER   
        ,PFA.IDPrestamoFondoAhorro AS IDPrestamoFondoAhorro
        ,PFA.IDFondoAhorro AS IDFondoAhorro
        ,PFA.Monto AS Monto
        ,PFA.FechaHora AS FechaHora
        ,US.IDUsuario AS IDUsuario
        ,US.Cuenta AS Usuario
    into #TempPrestamos        
	from [Nomina].[tblPrestamos] p    
	inner join [Nomina].[tblCatTiposPrestamo] TP    on p.IDTipoPrestamo = TP.IDTipoPrestamo
	inner join [Nomina].[tblPrestamosFondoAhorro] pfa on p.IDPrestamo = pfa.IDPrestamo --and pfa.IDEmpleado = @IDEmpleado   
	inner join [Nomina].[tblCatEstatusPrestamo] EP    on EP.IDEstatusPrestamo = p.IDEstatusPrestamo    
	inner join [RH].[tblEmpleados] e on P.IDEmpleado = e.IDEmpleado    
	inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario    
    left join Seguridad.tblusuarios US ON US.IDUsuario=@IDUsuario
	where ((pfa.IDFondoAhorro = @IDFondoAhorro) or ISNULL(@IDFondoAhorro,0)=0)
		and  ((e.IDEmpleado = @IDEmpleado) or ISNULL(@IDEmpleado,0)=0)
        and ((pfa.IDPrestamoFondoAhorro=@IDPrestamoFondoAhorro) or ISNULL(@IDPrestamoFondoAhorro,0)=0)
        and ((pfa.IDPrestamo=@IDPrestamo) or ISNULL(@IDPrestamo,0)=0)
		and TP.Codigo = 'PF'
        and (@query = '""' or contains(p.*, @query)) 
	order by p.FechaInicioPago desc  

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempPrestamos

	select @TotalRegistros = cast(COUNT(IDPrestamo) as decimal(18,2)) from #TempPrestamos
	
	select	*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempPrestamos
	order by 	
		case when @orderByColumn = 'FechaInicioPago' and @orderDirection = 'asc'	then FechaInicioPago end,			
		case when @orderByColumn = 'FechaInicioPago' and @orderDirection = 'desc'	then FechaInicioPago end desc
			
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

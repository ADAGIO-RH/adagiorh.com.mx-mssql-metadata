USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************     
** Descripción  : Busca préstamos    
** Autor   : Jose Roman    
** Email   : jose.roman@adagio.com.mx    
** FechaCreacion : 2019-01-01    
** Paremetros  :                  
    
** DataTypes Relacionados:     
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
2019-05-10   Aneudy Abreu Se agregó el parámetro @IDUsuario y el JOIN a la tabla de     
         Seguridad.tblDetalleFiltrosEmpleadosUsuarios    
***************************************************************************************************/    
CREATE PROCEDURE [Nomina].[spBuscarPrestamos]  --@IDUsuario = 1, @EsFonacot = 0,  @IDEmpleado = 390, @EsPersonal = 1
(   
  @IDEmpleado int = 0   
 ,@IDPrestamo int = 0   
 ,@EsFonacot bit = 0   
 ,@EsPersonal bit = 0   
 ,@IDUsuario int 
 ,@PageNumber	int = 1
 ,@PageSize		int = 2147483647
 ,@query			varchar(100) = '""'
 ,@orderByColumn	varchar(50) = 'FechaInicioPago'
 ,@orderDirection varchar(4) = 'desc'   
)    
AS    
BEGIN 


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
	into #TempPrestamos
    from [Nomina].[tblPrestamos] p    
		inner join [Nomina].[tblCatTiposPrestamo] TP    
		on p.IDTipoPrestamo = TP.IDTipoPrestamo    
		inner join [Nomina].[tblCatEstatusPrestamo] EP    
		on EP.IDEstatusPrestamo = p.IDEstatusPrestamo    
		inner join [RH].[tblEmpleados] e    
		on P.IDEmpleado = e.IDEmpleado    
		inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario    
	where ((p.IDPrestamo = @IDPrestamo) or (@IDPrestamo = 0))  
		and  ((e.IDEmpleado = @IDEmpleado) or (@IDEmpleado = 0))   
		and TP.Descripcion in (select Descripcion 
								from [Nomina].[tblCatTiposPrestamo] 
								where (((@EsFonacot = 1) and (Descripcion = 'FONACOT')) 
									  OR((@EsFonacot = 0) AND (Descripcion <> 'FONACOT')))
									  and (((@EsPersonal = 1) and (Descripcion not in  ('PRÉSTAMO FONDO DE AHORRO','FONACOT')))
										OR ((@EsPersonal = 0))))  
		--and (p.IDTipoPrestamo <> 6)
        and (@query = '""' or contains(p.*, @query)) 
	order by p.FechaCreacion desc  
    
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
  
END
GO

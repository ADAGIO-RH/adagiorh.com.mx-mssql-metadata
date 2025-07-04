USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca las devoluciones de Caja de ahorro
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

[Nomina].[spBuscarDevolucionesCajaAhorro] 
	@IDDevolucionesCajaAhorro = 0
	,@IDCajaAhorro = 1
	,@IDUsuario = 1
***************************************************************************************************/
CREATE proc [Nomina].[spBuscarDevolucionesCajaAhorro](
	@IDDevolucionesCajaAhorro int = 0
	,@IDCajaAhorro int = 0
	,@IDUsuario int
    ,@PageNumber	int = 1
    ,@PageSize		int = 2147483647
    ,@query			varchar(100) = '""'
    ,@orderByColumn	varchar(50) = 'FechaHora'
    ,@orderDirection varchar(4) = 'desc'   
) as

  DECLARE
		@IDIdioma varchar(20)
        ,@TotalPaginas INT = 0
	    ,@TotalRegistros INT 		
	;

	
    SELECT @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	IF (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	IF (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	SELECT
		 @orderByColumn	 = CASE WHEN @orderByColumn	 IS NULL THEN 'FechaHora' ELSE @orderByColumn  END
		,@orderDirection = CASE WHEN @orderDirection IS NULL THEN  'desc' ELSE @orderDirection END

	SET @query = CASE
					WHEN @query IS NULL THEN '""' 
					WHEN @query = '' THEN '""'
					WHEN @query =  '""' THEN '""'
				    ELSE '"'+@query + '*"' END

	IF OBJECT_ID('tempdb..#TempDevolucionesCajaAhorro') IS NOT NULL DROP TABLE #TempDevolucionesCajaAhorro;

	select 
		dca.IDDevolucionesCajaAhorro
		,dca.IDCajaAhorro
		,e.IDEmpleado
		,e.NOMBRECOMPLETO as Colaborador
		,dca.Monto
		,dca.FechaHora
		,dca.IDPeriodo
		-- ,coalesce(UPPER(p.ClavePeriodo),'')+'-'+coalesce(UPPER(p.Descripcion),'') as Periodo
		,UPPER(p.ClavePeriodo) as Periodo
        ,UPPER(P.Descripcion) as DescripcionPeriodo
        ,isnull(p.Cerrado,cast(0 as bit)) as Descontado
		,dca.IDUsuario
		,coalesce(u.Nombre,'')+' '+coalesce(u.Apellido,'') as Usuario
		,tn.IDTipoNomina
		,tn.Descripcion as TipoNomina
		,c.IDCliente
		,JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial'))  as Cliente
        INTO #TempDevolucionesCajaAhorro
	from Nomina.[tblDevolucionesCajaAhorro] dca with (nolock) 
		join Nomina.tblCajaAhorro ca with (nolock) on dca.IDCajaAhorro = ca.IDCajaAhorro
		join RH.tblEmpleadosMaster e with (nolock) on ca.IDEmpleado = e.IDEmpleado
		join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario = @IDUsuario
		join Nomina.tblCatPeriodos p with (nolock) on dca.IDPeriodo = p.IDPeriodo
		join Nomina.tblCatTipoNomina tn with (nolock) on p.IDTipoNomina = tn.IDTipoNomina
		join RH.tblCatClientes c with (nolock) on tn.IDCliente = c.IDCliente
		join Seguridad.tblUsuarios u with (nolock) on dca.IDUsuario = u.IDUsuario
	where (dca.IDDevolucionesCajaAhorro = @IDDevolucionesCajaAhorro or @IDDevolucionesCajaAhorro = 0)
		and (dca.IDCajaAhorro = @IDCajaAhorro or @IDCajaAhorro = 0)
        and (@query = '""' or contains(p.*, @query)) 

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempDevolucionesCajaAhorro

	select @TotalRegistros = cast(COUNT(IDDevolucionesCajaAhorro) as decimal(18,2)) from #TempDevolucionesCajaAhorro
	
	select	*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempDevolucionesCajaAhorro
	order by 	
		case when @orderByColumn = 'FechaHora' and @orderDirection = 'asc'	then FechaHora end,			
		case when @orderByColumn = 'FechaHora' and @orderDirection = 'desc'	then FechaHora end desc
			
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/**************************************************************************************************** 
** Descripción		: Busca lista de Controles de Confronta IMSS
** Autor			: JOSE ROMAN
** Email			: jroman@adagio.com.mx
** FechaCreacion	: 2025-02-07
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROCEDURE [IMSS].[spBuscarControlConfrontaIMSS](
	@IDControlConfrontaIMSS int =null
	,@IDUsuario		int = null    
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'FechaHoraRegistro'
	,@orderDirection varchar(4) = 'desc'
)
AS
BEGIN
	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int	
        ,@IDIdioma varchar(max)
	;
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  
 

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end
  
	SELECT     
		 CC.IDControlConfrontaIMSS    
		,CC.IDRegPatronal
		,RP.RegistroPatronal +' - '+ RP.RazonSocial as RegPatronal 
		,ISNULL(CC.IDMes,0) as IDMes
		,UPPER (JSON_VALUE(M.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) as Mes
		,ISNULL(CC.Ejercicio,0) as Ejercicio
		,ISNULL(CC.IDBimestre,0) as IDBimestre
		,UPPER (B.Descripcion) as Bimestre 
		,ISNULL(CC.EMA,0) as EMA
		,ISNULL(CC.EBA,0) as EBA
		,CC.FechaHoraRegistro as FechaHoraRegistro
		,ISNULL(CC.IDUsuario,0) as IDUsuario
		,ISNULL(U.Cuenta,'') +' '+ ISNULL(U.Nombre,'') + ' '+ISNULL(U.Apellido,'') as Usuario
	into #tempResponse
	FROM [IMSS].[tblControlConfrontaIMSS] CC with(nolock)     
		INNER JOIN [RH].[tblCatRegPatronal] RP with(nolock)
			on CC.IDRegPatronal = RP.IDRegPatronal
		LEFT JOIN Nomina.tblCatMeses M with(Nolock)
			on CC.IDMes = M.IDMes
		LEFT JOIN Nomina.tblCatBimestres B with(Nolock)
			on CC.IDBimestre = B.IDBimestre
		LEFT JOIN Seguridad.tblUsuarios U With(Nolock)
			on CC.IDUsuario = U.IDUsuario
 	WHERE
		 (CC.IDControlConfrontaIMSS = @IDControlConfrontaIMSS or isnull(@IDControlConfrontaIMSS,0) =0) 
			and (@query = '""' or contains(RP.*, @query) or contains(M.*, @query) OR contains(B.*, @query)) 

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDControlConfrontaIMSS) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'FechaHoraRegistro'			and @orderDirection = 'asc'		then FechaHoraRegistro end,			
		case when @orderByColumn = 'FechaHoraRegistro'			and @orderDirection = 'desc'	then FechaHoraRegistro end desc,		
		FechaHoraRegistro asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
END
GO

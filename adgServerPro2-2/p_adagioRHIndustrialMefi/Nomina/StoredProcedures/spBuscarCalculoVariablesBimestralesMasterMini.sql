USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************
** Descripción     : 
** Autor           : Javier Peña
** Email           : jpena@adagio.com.mx
** FechaCreacion   : 2024-07-16
** Parámetros      :    
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd) Autor            Comentario
------------------ ---------------- ------------------------------------------------------------

***************************************************************************************************/

CREATE     PROCEDURE [Nomina].[spBuscarCalculoVariablesBimestralesMasterMini](    	        
	 @IDControlCalculoVariables int = 0
    ,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'ClaveEmpleado'
	,@orderDirection varchar(4) = 'desc'
	,@IDUsuario int
) AS

    DECLARE  
	   @TotalPaginas INT = 0
	   ,@TotalRegistros INT, 
		@IDIdioma VARCHAR(20)
	;

	SELECT @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	IF (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	IF (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	SELECT
		 @orderByColumn	 = CASE WHEN @orderByColumn	 IS NULL THEN 'ClaveEmpleado' ELSE @orderByColumn  END
		,@orderDirection = CASE WHEN @orderDirection IS NULL THEN  'desc' ELSE @orderDirection END

	SET @query = CASE
					WHEN @query IS NULL THEN '""' 
					WHEN @query = '' THEN '""'
					WHEN @query =  '""' THEN '""'
				    ELSE '"'+@query + '*"' END

	IF OBJECT_ID('tempdb..#TempCalculoVariablesBimestralesMaster') IS NOT NULL DROP TABLE #TempCalculoVariablesBimestralesMaster; 

	SELECT 
        [CVBM].[IDCalculoVariablesBimestralesMaster]
        ,[CVBM].[IDControlCalculoVariables]
        ,[CVBM].[IDEmpleado]
        ,Utilerias.GetInfoUsuarioEmpleadoFotoAvatar(CVBM.IDEmpleado,0) as UsuarioEmpleadoFotoAvatar
        ,[EM].[ClaveEmpleado]  
        ,[EM].[NOMBRECOMPLETO]        
        ,ISNULL([CS].[Descripcion],'SIN SUCURSAL') AS [Sucursal]
        ,ISNULL(JSON_VALUE(CD.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')),'SIN DEPARTAMENTO') as [Departamento]
        ,ISNULL(JSON_VALUE(CP.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')),'SIN PUESTO') as [Puesto]                
	INTO #TempCalculoVariablesBimestralesMaster
    FROM [Nomina].[TblCalculoVariablesBimestralesMaster] CVBM	
        INNER JOIN RH.tblEmpleadosMaster EM
                ON EM.IDEmpleado = CVBM.IDEmpleado	
        LEFT JOIN RH.tblCatSucursales CS
                ON CS.IDSucursal = EM.IDSucursal
        LEFT JOIN RH.tblCatDepartamentos CD
                ON CD.IDDepartamento = EM.IDDepartamento
        LEFT JOIN RH.tblCatPuestos CP
                ON CP.IDPuesto = EM.IDPuesto		
	WHERE (CVBM.IDControlCalculoVariables = @IDControlCalculoVariables or isnull(@IDControlCalculoVariables, 0) = 0)    	
        and ( 
			(@query = '""' or contains(EM.*, @query)) OR
			(@query = '""' or contains(CS.*, @query)) OR
			(@query = '""' or contains(CD.*, @query)) OR
			(@query = '""' or contains(CP.*, @query)) 			
		) 

    select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempCalculoVariablesBimestralesMaster

	select @TotalRegistros = cast(COUNT(IDCalculoVariablesBimestralesMaster) as decimal(18,2)) from #TempCalculoVariablesBimestralesMaster
	
	select	*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempCalculoVariablesBimestralesMaster
	order by 	
		case when @orderByColumn = 'ClaveEmpleado' and @orderDirection = 'asc'	then ClaveEmpleado end,			
		case when @orderByColumn = 'ClaveEmpleado' and @orderDirection = 'desc'	then ClaveEmpleado end desc
			
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

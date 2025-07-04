USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Comunicacion].[spBuscarNotificacionesBirthday](
	 @IDNotificacionBirthday int = 0
	,@SoloActual bit = 0
	,@IDUsuario int
	,@PageNumber		int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = null
	,@orderByColumn	varchar(50) = 'FechaReg'
	,@orderDirection varchar(4) = 'asc'
) as
	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int, 
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'FechaReg' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	IF OBJECT_ID('tempdb..#TempNotificacionesBirthday') IS NOT NULL DROP TABLE #TempNotificacionesBirthday  

	SELECT     
		n.IDNotificacionBirthday   
		,n.Nombre
		,n.Asunto 
		,n.Body   
		,n.Actual
		,n.IDUsuario
		,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario
		,n.IDIdioma
		,i.Idioma
		,n.FechaReg
	into #TempNotificacionesBirthday
	FROM Comunicacion.tblNotificacionBirthday n with (nolock)    
		join Seguridad.tblUsuarios u on u.IDUsuario = n.IDUsuario
		join App.tblIdiomas i on i.IDIdioma = n.IDIdioma
	WHERE (n.IDNotificacionBirthday = @IDNotificacionBirthday or isnull(@IDNotificacionBirthday, 0) = 0)
		and (n.Actual = case when isnull(@SoloActual, 0) = 1 then 1 else n.Actual end)

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempNotificacionesBirthday

	select @TotalRegistros = cast(COUNT(IDNotificacionBirthday) as decimal(18,2)) from #TempNotificacionesBirthday		
	
	select	*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempNotificacionesBirthday
	order by 	
		case when @orderByColumn = 'FechaReg'			and @orderDirection = 'asc'		then FechaReg end,			
		case when @orderByColumn = 'FechaReg'			and @orderDirection = 'desc'	then FechaReg end desc,		
			FechaReg desc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

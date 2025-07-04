USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Enrutamiento].[spBuscarUnidadesProceso] --@Opcion = 1, @IDUsuario = 1
(
	@IDUnidad int = 0
	,@Opcion int = 1
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Codigo'
	,@orderDirection varchar(4) = 'asc'
	,@IDUsuario int
)
AS
BEGIN
	/*
		Opciones:
		OP: 1 -- Unidades en Proceso(Creadas por el Usuario, y Por Proceso Que debe ver el Usuario)
		OP: 2 -- Unidades pendientes de mi Ejecucion
		OP: 3 -- Unidades pendientes de mi Autorizacion
		OP: 4 -- Unidades Completadas(Creadas por el Usuario, y Por Proceso Que debe ver el Usuario)
	*/


	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros decimal(18,2) = 0.00
		,@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (@PageNumber = 0) set @PageNumber = 1;
	if (@PageSize = 0) set @PageSize = 2147483647;

	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
				else '"'+@query + '*"' end

	declare @tempResponse as table (
		 IDUnidad   int   
		,Codigo       varchar(20)
		,Descripcion  varchar(500)    
		,IDCatTipoProceso   int   
		,TipoProceso  varchar(500)
		,IDEstatus   int   
		,Estatus  varchar(500)
		,IDReferencia   int   
		,Avance  int
		,IDCliente int
		,Cliente Varchar(500)
		,IDRutaUnidadProceso int null
		,TemplateUser varchar(500)
	);

	IF OBJECT_ID(N'tempdb..#tempNoCompletadoEjecucion') IS NOT NULL DROP TABLE #tempNoCompletadoEjecucion
	IF OBJECT_ID(N'tempdb..#tempNoCompletadoAutorizacion') IS NOT NULL DROP TABLE #tempNoCompletadoAutorizacion
	
	
	

	IF(@Opcion = 1)
	BEGIN
		insert into @tempResponse
		SELECT UP.IDUnidad
			,UP.Codigo
			,UP.Descripcion
			,UP.IDCatTipoProceso
			,TP.Codigo as TipoProceso
			,UP.IDEstatus 
			,CG.Catalogo as Estatus
			,UP.IDReferencia
			,CASE WHEN NOT EXISTS (Select top 1 1 from [Enrutamiento].[tblRutaUnidadProceso] where IDUnidad = UP.IDUnidad and isnull(Completado,0) = 0) THEN 100
				ELSE ((100/(Select count(*) from [Enrutamiento].[tblRutaUnidadProceso] where IDUnidad = UP.IDUnidad)) * 
					(Select count(*) from [Enrutamiento].[tblRutaUnidadProceso] where IDUnidad = UP.IDUnidad and Completado = 1))
					END as Avance
			,UP.IDCliente
			,JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente
			,isnull((Select top 1 IDRutaUnidadProceso from [Enrutamiento].[tblRutaUnidadProceso] RUP where RUP.IDUnidad = UP.IDUnidad and Completado = 0 order by Orden asc),0) IDRutaUnidadProceso
			,TP.TemplateUser
		FROM [Enrutamiento].[tblUnidadProceso] UP WITH(Nolock)
			inner join [Enrutamiento].[tblCatTiposProcesos] TP
				on TP.IDCatTipoProceso = UP.IDCatTipoProceso
			Inner join [App].[tblCatalogosGenerales] CG With(Nolock)
				on CG.IDTipoCatalogo = 6
				and CG.IDCatalogoGeneral = UP.IDEstatus
			inner join [RH].[tblCatClientes] c
				on C.IDCliente = UP.IDCliente
		WHERE CG.IDCatalogoGeneral in( 1,6) -- EN PROCESO
			AND UP.IDUsuarioCreador = @IDUsuario
		
		--select * from @tempResponse
	END
	
	IF(@Opcion = 2)
	BEGIN
		--insert into @tempResponse
		SELECT UP.IDUnidad
			,UP.Codigo
			,UP.Descripcion
			,UP.IDCatTipoProceso
			,TP.Codigo as TipoProceso
			,UP.IDEstatus 
			,CG.Catalogo as Estatus
			,UP.IDReferencia
			,CASE WHEN NOT EXISTS (Select top 1 1 from [Enrutamiento].[tblRutaUnidadProceso] where IDUnidad = UP.IDUnidad and isnull(Completado,0) = 0) THEN 100
				ELSE ((100/(Select count(*) from [Enrutamiento].[tblRutaUnidadProceso] where IDUnidad = UP.IDUnidad)) * 
					(Select count(*) from [Enrutamiento].[tblRutaUnidadProceso] where IDUnidad = UP.IDUnidad and Completado = 1))
					END as Avance
			,UP.IDCliente
			,JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente
			,isnull((Select top 1 IDRutaUnidadProceso from [Enrutamiento].[tblRutaUnidadProceso] RUP where RUP.IDUnidad = UP.IDUnidad and Completado = 0 order by Orden asc),0) IDRutaUnidadProceso
			,TP.TemplateUser
			into #tempNoCompletadoEjecucion
		FROM [Enrutamiento].[tblUnidadProceso] UP WITH(Nolock)
			inner join [Enrutamiento].[tblCatTiposProcesos] TP
				on TP.IDCatTipoProceso = UP.IDCatTipoProceso
			Inner join [App].[tblCatalogosGenerales] CG With(Nolock)
				on CG.IDTipoCatalogo = 6
				and CG.IDCatalogoGeneral = UP.IDEstatus
			inner join [RH].[tblCatClientes] c
				on C.IDCliente = UP.IDCliente
		WHERE CG.IDCatalogoGeneral = 1 -- EN PROCESO
			
			insert into @tempResponse
			select IDUnidad
				,Codigo
				,Descripcion
				,IDCatTipoProceso
				,TipoProceso
				,IDEstatus
				,Estatus
				,IDReferencia
				,Avance
				,IDCliente
				,Cliente
				,IDRutaUnidadProceso
				,TemplateUser
			from #tempNoCompletadoEjecucion t
			 where IDRutaUnidadProceso in (select IDRutaUnidadProceso from [Enrutamiento].tblEjecucionUnidadProceso where isnull(Realizado,0) = 0 and IDUsuario = @IDUsuario)


	END

	IF(@Opcion = 3)
	BEGIN
		--insert into @tempResponse
		SELECT UP.IDUnidad
			,UP.Codigo
			,UP.Descripcion
			,UP.IDCatTipoProceso
			,TP.Codigo as TipoProceso
			,UP.IDEstatus 
			,CG.Catalogo as Estatus
			,UP.IDReferencia
			,CASE WHEN NOT EXISTS (Select top 1 1 from [Enrutamiento].[tblRutaUnidadProceso] where IDUnidad = UP.IDUnidad and isnull(Completado,0) = 0) THEN 100
				ELSE ((100/(Select count(*) from [Enrutamiento].[tblRutaUnidadProceso] where IDUnidad = UP.IDUnidad)) * 
					(Select count(*) from [Enrutamiento].[tblRutaUnidadProceso] where IDUnidad = UP.IDUnidad and Completado = 1))
					END as Avance
			,UP.IDCliente
			,JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente
			,isnull((Select top 1 IDRutaUnidadProceso from [Enrutamiento].[tblRutaUnidadProceso] RUP where RUP.IDUnidad = UP.IDUnidad and Completado = 0 order by Orden asc),0) IDRutaUnidadProceso
			,TP.TemplateUser
			into #tempNoCompletadoAutorizacion
		FROM [Enrutamiento].[tblUnidadProceso] UP WITH(Nolock)
			inner join [Enrutamiento].[tblCatTiposProcesos] TP
				on TP.IDCatTipoProceso = UP.IDCatTipoProceso
			Inner join [App].[tblCatalogosGenerales] CG With(Nolock)
				on CG.IDTipoCatalogo = 6
				and CG.IDCatalogoGeneral = UP.IDEstatus
			inner join [RH].[tblCatClientes] c
				on C.IDCliente = UP.IDCliente
		WHERE CG.IDCatalogoGeneral = 1 -- EN PROCESO
			
			insert into @tempResponse
			select IDUnidad
				,Codigo
				,Descripcion
				,IDCatTipoProceso
				,TipoProceso
				,IDEstatus
				,Estatus
				,IDReferencia
				,Avance
				,IDCliente
				,Cliente
				,IDRutaUnidadProceso
				,TemplateUser
			from #tempNoCompletadoAutorizacion t
			 where IDRutaUnidadProceso in (select IDRutaUnidadProceso from [Enrutamiento].tblAutorizacionUnidadProceso where isnull(Autorizado,0) = 0 and IDUsuario = @IDUsuario)
			 and (IDRutaUnidadProceso not in(select IDRutaUnidadProceso from [Enrutamiento].tblEjecucionUnidadProceso ) OR IDRutaUnidadProceso in (select IDRutaUnidadProceso from [Enrutamiento].tblEjecucionUnidadProceso where isnull(Realizado,0) = 1 ) )
			

	END

	IF(@Opcion = 4)
	BEGIN
		insert into @tempResponse
		SELECT UP.IDUnidad
			,UP.Codigo
			,UP.Descripcion
			,UP.IDCatTipoProceso
			,TP.Codigo as TipoProceso
			,UP.IDEstatus 
			,CG.Catalogo as Estatus
			,UP.IDReferencia
			,CASE WHEN NOT EXISTS (Select top 1 1 from [Enrutamiento].[tblRutaUnidadProceso] where IDUnidad = UP.IDUnidad and isnull(Completado,0) = 0) THEN 100
				ELSE ((100/(Select count(*) from [Enrutamiento].[tblRutaUnidadProceso] where IDUnidad = UP.IDUnidad)) * 
					(Select count(*) from [Enrutamiento].[tblRutaUnidadProceso] where IDUnidad = UP.IDUnidad and Completado = 1))
					END as Avance
			,UP.IDCliente
			,JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente
			,isnull((Select top 1 IDRutaUnidadProceso from [Enrutamiento].[tblRutaUnidadProceso] RUP where RUP.IDUnidad = UP.IDUnidad and Completado = 0 order by Orden asc),0) IDRutaUnidadProceso
			,TP.TemplateUser
		FROM [Enrutamiento].[tblUnidadProceso] UP WITH(Nolock)
			inner join [Enrutamiento].[tblCatTiposProcesos] TP
				on TP.IDCatTipoProceso = UP.IDCatTipoProceso
			Inner join [App].[tblCatalogosGenerales] CG With(Nolock)
				on CG.IDTipoCatalogo = 6
				and CG.IDCatalogoGeneral = UP.IDEstatus
			inner join [RH].[tblCatClientes] c
				on C.IDCliente = UP.IDCliente
		WHERE CG.IDCatalogoGeneral in (2,3,4,5) -- Completadas diferentes estatus o cancelada o rechazada
			AND UP.IDUsuarioCreador = @IDUsuario
	END

	
 
 	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempResponse

	select @TotalRegistros = cast(COUNT([IDUnidad]) as decimal(18,2)) from @tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempResponse
	order by 
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'asc'		then Codigo end,			
		case when @orderByColumn = 'Codigo'			and @orderDirection = 'desc'	then Codigo end desc,			
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'	and @orderDirection = 'desc'	then Descripcion end desc,			
		Codigo asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO

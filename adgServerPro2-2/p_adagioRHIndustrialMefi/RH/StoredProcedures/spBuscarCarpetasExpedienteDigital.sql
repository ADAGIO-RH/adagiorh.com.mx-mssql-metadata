USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarCarpetasExpedienteDigital](
  @IDCarpetaExpedienteDigital int =null
 ,@Core			bit = null
 ,@IDUsuario	int = null    
 ,@PageNumber	int = 1
 ,@PageSize		int = 2147483647
 ,@query		varchar(100) = '""'
 ,@orderByColumn	varchar(50) = 'Descripcion'
 ,@orderDirection	varchar(4) = 'asc'
)
AS
BEGIN
	SET FMTONLY OFF;

	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
		,@EXPDIG0001 bit = 0
		,@EXPDIG0002 bit = 0
	;      
	
	if exists(select top 1 1 
		from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
			join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
		where pes.IDUsuario = @IDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'EXPDIG0001')
	begin
		set @EXPDIG0001 = 1
	end;

	if exists(select top 1 1 
	from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
			join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
		where pes.IDUsuario = @IDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'EXPDIG0002')
	begin
		set @EXPDIG0002 = 1
	end;
 
	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Descripcion' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end
  
	IF OBJECT_ID('tempdb..#TempResponse') IS NOT NULL DROP TABLE #TempResponse  

	 SELECT 
		 CED.IDCarpetaExpedienteDigital
		,CED.Descripcion
		,ISNULL(CED.Core,0) as Core
		,ISNULL(CED.IDTipoComportamientoCarpetaExpedienteDigital,0) AS IDTipoComportamientoCarpetaExpedienteDigital
		,TCC.Descripcion as TipoComportamientoCarpetaExpedienteDigital
		,isnull(CED.Icono, 'folder-fill') as Icono
	 INTO #tempResponse
	 FROM RH.tblCatCarpetasExpedienteDigital CED WITH(NOLOCK)
		INNER JOIN RH.tblCatTipoComportamientoCarpetaExpedienteDigital TCC WITH(NOLOCK)
			ON CED.IDTipoComportamientoCarpetaExpedienteDigital = TCC.IDTipoComportamientoCarpetaExpedienteDigital
	WHERE  (@query = '""' or contains(CED.*, @query)) 
	 and (CED.IDCarpetaExpedienteDigital = @IDCarpetaExpedienteDigital or isnull(@IDCarpetaExpedienteDigital,0) =0)
	 and (CED.Core = @Core OR @Core is null)
	 --and (CED.Core = 1 and CED.Descripcion = 'CONTRATOS' and @EXPDIG0001 = 1)
	 --and (CED.Core = 1 and CED.Descripcion = 'NOMINAS' and @EXPDIG0002 = 1)

	 IF(@EXPDIG0001 <> 1)
	 BEGIN
		DELETE #tempResponse
		WHERE Descripcion = 'CONTRATOS'
		and Core = 1
	 END

	 IF(@EXPDIG0002 <> 1)
	 BEGIN
		DELETE #tempResponse
		WHERE Descripcion = 'NOMINAS'
		and Core = 1
	 END

	 select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #tempResponse

	select @TotalRegistros = COUNT(IDCarpetaExpedienteDigital) from #tempResponse		

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #tempResponse
	order by 
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'asc'		then Descripcion end,			
		case when @orderByColumn = 'Descripcion'			and @orderDirection = 'desc'	then Descripcion end desc,		
		Descripcion asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO

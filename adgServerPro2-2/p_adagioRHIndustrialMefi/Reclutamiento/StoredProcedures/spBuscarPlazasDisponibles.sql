USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Emmanuel Contreras
-- Create date: 2022-05-24
-- Description:	Stored Procedure para obtener las plazas disponibles
-- [Reclutamiento].[spBuscarPlazasDisponibles]42
-- =============================================
CREATE PROCEDURE [Reclutamiento].[spBuscarPlazasDisponibles](
	@IDUsuario int = 0
	,@IDPlaza int = 0
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'Orden'
	,@orderDirection varchar(4) = 'asc'
) AS
BEGIN
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
					when @query =  '""' then '""'
				else '"'+@query + '*"' end

	declare @tempPlazas as table (
		IDPlaza int,
		IDCliente int,
		ClienteNombre varchar(200),
		Codigo varchar(200),
		Nombre varchar(200),
		DescripcionPuesto text,
		PosicionesDisponibles int,
		CandidatosInscritos int,
		IDPuesto int,
		Sucursal varchar(max)
	);

	insert into @tempPlazas
	select
		cP.IDPlaza,
		cP.IDCliente,
		JSON_VALUE(cc.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')),
		cP.Codigo,
		JSON_VALUE(ctPue.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),
		ctPue.DescripcionPuesto,
		cP.PosicionesDisponibles,
		(SELECT count(*) from Reclutamiento.tblCandidatoPlaza where IDPlaza = cP.IDPlaza),
		ctPue.IDPuesto,
		(
			select *
			from (
				select 
					isnull((
							select suc.Codigo+'-'+suc.Descripcion 
							from RH.tblCatSucursales suc 
							where suc.IDSucursal = config.Valor
						), '[SIN ASIGNAR]')  as Nombre
				from  OPENJSON(cP.Configuraciones, '$') 
				with (
					IDTipoConfiguracionPlaza varchar(max), 
					Valor int
				) as config
				where config.IDTipoConfiguracionPlaza = 'Sucursal'
			) as info
			for json auto, without_array_wrapper
		) Sucursal
	From RH.tblCatPlazas cP 
        inner join Reclutamiento.tblPerfilPublicacionVacante pp on pp.IDPlaza=cP.IDPlaza
		left join [RH].[tblCatClientes] cc on cP.IDCliente = cc.IDCliente
		left join RH.tblCatPuestos ctPue on cP.IDPuesto = ctPue.IDPuesto

	where cP.PosicionesDisponibles > 0
		and (cp.IDPlaza = @IDPlaza OR ISNULL(@IDPlaza,0) = 0) 
		and (@query = '""' or contains(ctPue.*, @query))
	--order by IDPlaza

	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @tempPlazas

	select @TotalRegistros = cast(COUNT(IDPlaza) as decimal(18,2)) from @tempPlazas	

	select *
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
	from @tempPlazas
	order by
		CandidatosInscritos desc
		--Nombre
		--case when @orderByColumn = 'Orden'			and @orderDirection = 'asc'		then IDPlaza end,	
		--case when @orderByColumn = 'Orden'			and @orderDirection = 'desc'	then IDPlaza end desc,			
		--IDPlaza asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);

END
GO

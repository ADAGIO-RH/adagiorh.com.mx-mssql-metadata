USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar lista de plazas
** Autor			: Aneudy Abreu
** Email			: aabreu@adagio.com.mx
** FechaCreacion	: 2022-10-17
** Paremetros		:              

** DataTypes Relacionados: 

	Si se modifica el result set de este sp es necesario aplicar el cambio en el sp [RH].[spIPlazasImportacion]

	[RH].[spBuscarPlazasFillConfiguraciones] @IDUsuario=1
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
2022-30-12			Alejandro Paredes	Se agrego la columna ParentCodigo
***************************************************************************************************/
create   proc [RH].[spBuscarPlazasFillConfiguraciones] (
	@IDPlaza int = 0
	,@IDCliente int = 0
	,@ParentId int = 0
	,@IDUsuario int
    ,@StringFiltroEstatus varchar(100)= ''
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = null
	,@orderByColumn	varchar(50) = 'Codigo'
	,@orderDirection varchar(4) = 'asc'
) as
	SET FMTONLY OFF;  

	declare  
		@TotalPaginas int = 0
		,@TotalRegistros decimal(18,2) = 0.00
		,@IDTipoCatalogoEstatusPlazas int = 4
		,@IDIdioma varchar(20)
	;
	
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Codigo' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	set @query = case 
					when @query = '' then null
				else @query end

	declare @tempPlazas as table (
		IDPlaza int,
		IDCliente int,
		Cliente App.XLName,
		Codigo App.SMName,	
		Descripcion App.XLName,
		ParentId		int,
		ParentCodigo	varchar(25),
		TotalPosiciones	int,
		PosicionesOcupadas		int,
		PosicionesDisponibles	int,		
        IDPuesto int,
        Configuraciones nvarchar(max),   
		IDNivelSalarial int,
		DescripcionPublicaVacante varchar(max)
	)

	declare @tempEstatusPlazas as table (
		IDEstatusPlaza int,
		IDPlaza int,
		IDEstatus int,
		Estatus varchar(255),
		IDUsuario int,
		FechaReg datetime,
        ConfiguracionStatus nvarchar(max),
		[ROW] int
	)

	insert @tempPlazas
	select 
		p.IDPlaza
		,p.IDCliente
		,JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente
		,p.Codigo	
		,JSON_VALUE(puesto.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion 
		,p.ParentId
		,ISNULL(p2.Codigo, '0') as ParentCodigo
		,p.TotalPosiciones	 
		,p.PosicionesOcupadas		
		,p.PosicionesDisponibles
        ,p.IDPuesto		
        ,p.Configuraciones 
		,ISNULL(p.IDNivelSalarial,0) IDNivelSalarial
		,p.DescripcionPublicaVacante
	from [RH].[tblCatPlazas] p with (nolock)
		join [RH].[tblCatClientes] c with (nolock) on c.IDCliente = p.IDCliente
		join [RH].[TblCatPuestos] puesto with(nolock) on puesto.IDPuesto = p.IDPuesto
		left join [RH].[tblCatPlazas] p2 with(nolock) on p.ParentId = p2.IDPlaza
	where (p.IDPlaza = @IDPlaza or isnull(@IDPlaza, 0) = 0)
		and  (p.IDCliente = @IDCliente or isnull(@IDCliente, 0) = 0)
		and  (p.ParentId = @ParentId or isnull(@ParentId, 0) = 0)

	insert @tempEstatusPlazas
	select 
		isnull(estatusPlaza.IDEstatusPlaza,0) AS IDEstatusPlaza
		,plazas.IDPlaza
		,isnull(estatusPlaza.IDEstatus,0) AS IDEstatus
		,isnull(estatus.Catalogo,'Sin estatus') AS Estatus
		,isnull(estatusPlaza.IDUsuario,0) as IDUsuario
		,isnull(estatusPlaza.FechaReg,'1990-01-01') FechaReg
        ,isnull(estatus.configuracion,'') as ConfiguracionStatus
		,ROW_NUMBER()over(partition by plazas.IDPlaza 
							ORDER by plazas.IDPlaza, estatusPlaza.FechaReg  desc) as [ROW]
	from @tempPlazas plazas
		left join RH.tblEstatusPlazas estatusPlaza on estatusPlaza.IDPlaza = plazas.IDPlaza 
		left join [App].[tblCatalogosGenerales] estatus with (nolock) on estatus.IDCatalogoGeneral = estatusPlaza.IDEstatus and estatus.IDTipoCatalogo = @IDTipoCatalogoEstatusPlazas

	IF OBJECT_ID('tempdb..#TempPlazas') IS NOT NULL DROP TABLE #TempPlazas

	select 
		p.IDPlaza
		,p.IDCliente
		,p.Cliente
		,p.Codigo		
		,p.ParentId
		,p.ParentCodigo
		,p.TotalPosiciones	 
		,p.PosicionesDisponibles	 
		,p.PosicionesOcupadas	
		,estatus.IDEstatusPlaza 
		,estatus.IDEstatus
		,estatus.Estatus
		,estatus.IDUsuario 
		,estatus.FechaReg as FechaRegEstatus
        ,(	
			select *
			from (
				select *,
				case 
					when IDTipoConfiguracionPlaza = 'PosicionJefe' then '' 
					when IDTipoConfiguracionPlaza = 'Departamento' then (select Descripcion from RH.tblCatDepartamentos where IDDepartamento = Valor) 
					when IDTipoConfiguracionPlaza = 'Sucursal' then (select Descripcion from RH.tblCatSucursales where IDSucursal = Valor) 
					when IDTipoConfiguracionPlaza = 'Prestaciones' then (select Descripcion from RH.tblCatTiposPrestaciones where IDTipoPrestacion = Valor) 
					when IDTipoConfiguracionPlaza = 'RegistroPatronal' then (select Descripcion from RH.tblCatRegPatronal where IDRegPatronal = Valor) 
					when IDTipoConfiguracionPlaza = 'Empresa' then (select Descripcion from RH.tblEmpresa where IDEmpresa = Valor) 
					when IDTipoConfiguracionPlaza = 'CentroCosto' then (select Descripcion from RH.tblCatCentroCosto where IDCentroCosto = Valor) 
					when IDTipoConfiguracionPlaza = 'Area' then (select Descripcion from RH.tblCatArea where IDArea = Valor) 
					when IDTipoConfiguracionPlaza = 'Division' then (select Descripcion from RH.tblCatDivisiones where IDDivision = Valor) 
					when IDTipoConfiguracionPlaza = 'Region' then (select Descripcion from RH.tblCatRegiones where IDRegion = Valor) 
					when IDTipoConfiguracionPlaza = 'ClasificacionCorporativa' then (select Descripcion from RH.tblCatClasificacionesCorporativas where IDClasificacionCorporativa = Valor) 
				else '' end as Descripcion
				from OPENJSON(Configuraciones, '$')
				with (
					IDTipoConfiguracionPlaza varchar(max),
					PosicionJefe int,
					Valor int
				)
			) info
			for json auto
		) as Configuraciones
		,p.IDPuesto
        ,(
            select IDPuesto,  JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
            from RH.tblCatPuestos
            where IDPuesto = p.IDPuesto
            for json auto, WITHOUT_ARRAY_WRAPPER
        ) as Puesto
        ,estatus.ConfiguracionStatus
		,ISNULL(p.IDNivelSalarial,0) IDNivelSalarial
		,p.DescripcionPublicaVacante
	into #TempPlazas
	from @tempPlazas p
		left join @tempEstatusPlazas estatus on estatus.IDPlaza = p.IDPlaza and estatus.[ROW] = 1
    where ( @StringFiltroEstatus='' or estatus.IDEstatus  in ( Select item from App.Split(@StringFiltroEstatus,',')) )
	 and (@query is null or p.Descripcion like +'%'+@query+'%') 

	 select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempPlazas

	select @TotalRegistros = cast(COUNT([IDPlaza]) as decimal(18,2)) from #TempPlazas		
	
	select
		*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
        , cast(@TotalRegistros  as int ) as TotalRows
	from #TempPlazas
	 order by  
            case when @orderByColumn = 'Codigo'			and @orderDirection = 'asc'		then Codigo end ,
            case when @orderByColumn = 'Codigo'			and @orderDirection = 'desc'		then Codigo end desc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

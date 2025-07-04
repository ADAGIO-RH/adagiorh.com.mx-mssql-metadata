USE [p_adagioRHSakata]
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

	Si se modifica el result set de este sp es necesario aplicar el cambio en el sp [RH].[spIUPlaza]
    Si se modifica el result set de este sp tambien es necesario aplicar el cambio en el sp [RH].[spIPlazasImportacion]

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
2022-30-12			Alejandro Paredes	Se agrego la columna ParentCodigo
2024-07-17			Alejandro Paredes   Agrega traduccion a clasificaciones corporativas
***************************************************************************************************/
CREATE proc [RH].[spBuscarPlazas] (
	@IDPlaza int = 0
	,@IDCliente int = 0
	,@ParentId int = 0
	,@IDUsuario int
    ,@StringFiltroEstatus varchar(100)= ''
    ,@Filtro varchar(255) = null
    ,@IDReferencia int  = null
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
        ,@IDOrganigrama int
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


    select @IDOrganigrama =IDOrganigrama from rh.tblCatOrganigramas s where s.Filtro=@Filtro AND S.IDReferencia   =@IDReferencia;

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
        PosicionesCanceladas	int,		
        IDPuesto int,
        Configuraciones nvarchar(max),   
		IDNivelSalarial int,
        NombreNivelSalarial varchar(100),
        NivelSalarial int,
		DescripcionPublicaVacante varchar(max),
        EsAsistente bit,        
        IDNivelEmpresarial int,
        NombreNivelEmpresarial varchar(255),
        OrdenNivelEmpresarial int        
	)
    
    	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query =  '""' then '""'
				else '"*'+@query + '*"' end


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
        ,isnull(p.PosicionesCanceladas,0) 
        ,p.IDPuesto		
        ,p.Configuraciones 
		,ISNULL(tTabSalarial.IDNivelSalarial,0) IDNivelSalarial
        ,isnull(tTabSalarial.Nombre,'') as NombreNivelSalarial 
        ,ISNULL(tTabSalarial.Nivel,0) NivelSalarial
		,p.DescripcionPublicaVacante
        ,ISNULL(p.EsAsistente,0)         
        ,p.IDNivelEmpresarial
        ,catNivelesEmpresariales.Nombre [NombreNivelEmpresarial]
        ,catNivelesEmpresariales.Orden [OrdenNivelEmpresarial]
	from [RH].[tblCatPlazas] p with (nolock)
        left join rh.tblTabuladorSalarial tTabSalarial on tTabSalarial.IDNivelSalarial=p.IDNivelSalarial
        LEFT JOIN RH.[tblCatNivelesEmpresariales] catNivelesEmpresariales on catNivelesEmpresariales.IDNivelEmpresarial=p.IDNivelEmpresarial    
		join [RH].[tblCatClientes] c with (nolock) on c.IDCliente = p.IDCliente
		join [RH].[TblCatPuestos] puesto with(nolock) on puesto.IDPuesto = p.IDPuesto
        -- left join RH.tblCatOrganigramas cato on cato.IDOrganigrama= p.IDOrganigrama
		left join [RH].[tblCatPlazas] p2 with(nolock) on p.ParentId = p2.IDPlaza
        
	where (p.IDPlaza = @IDPlaza or isnull(@IDPlaza, 0) = 0)
		and  (p.IDCliente = @IDCliente or isnull(@IDCliente, 0) = 0)
		and  (p.ParentId = @ParentId or isnull(@ParentId, 0) = 0)
        and (@query = '""' or contains(p.Codigo, @query) or  contains(puesto.Traduccion, @query)) 
        and   (P.IDOrganigrama =@IDOrganigrama OR (ISNULL(@Filtro,'')='' and isnull(@IDReferencia,0)=0 ))

 
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
        ,p.PosicionesCanceladas
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

					when IDTipoConfiguracionPlaza = 'PosicionJefe' then isnull((
                        select  'Posicion: '+ posicion.Codigo +' - ' + isnull(JSON_VALUE(puesto.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('es-mx', '-','')), 'Descripcion')) ,'')+  ' Empleado: '+ 
                                case when empleado.ClaveEmpleado is null then 
                                    'No asignado' else   isnull(empleado.ClaveEmpleado,'')+ ' - ' + isnull(empleado.NOMBRECOMPLETO,'') end 
                        
                        From rh.tblCatPosiciones posicion 
                        inner join rh.tblCatPlazas plaza on plaza.IDPlaza = posicion.IDPlaza
                        inner join rh.tblCatPuestos puesto on puesto.IDPuesto=plaza.IDPuesto
                        left join rh.tblEmpleadosMaster empleado on empleado.IDEmpleado =posicion.IDEmpleado
                        where posicion.IDPosicion=Valor
                    ),'')
					when IDTipoConfiguracionPlaza = 'Departamento' then isnull((select UPPER (JSON_VALUE(dep.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) from RH.tblCatDepartamentos dep where dep.IDDepartamento = Valor),'') 
					when IDTipoConfiguracionPlaza = 'Sucursal' then isnull((select suc.Descripcion from RH.tblCatSucursales suc where suc.IDSucursal = Valor),'') 
					when IDTipoConfiguracionPlaza = 'Prestaciones' then isnull((select UPPER (JSON_VALUE(tpres.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) from RH.tblCatTiposPrestaciones tpres where tpres.IDTipoPrestacion = Valor),'') 
					when IDTipoConfiguracionPlaza = 'RegistroPatronal' then isnull((select reg.RegistroPatronal from RH.tblCatRegPatronal reg where reg.IDRegPatronal = Valor),'') 
					when IDTipoConfiguracionPlaza = 'Empresa' then isnull((select emp.NombreComercial from RH.tblEmpresa emp where emp.IDEmpresa = Valor),'') 
					when IDTipoConfiguracionPlaza = 'CentroCosto' then isnull((select UPPER (JSON_VALUE(cent.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) from RH.tblCatCentroCosto cent where cent.IDCentroCosto = Valor),'') 
					when IDTipoConfiguracionPlaza = 'Area' then isnull((select  UPPER (JSON_VALUE(area.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) from RH.tblCatArea area where area.IDArea = Valor),'') 
					when IDTipoConfiguracionPlaza = 'Division' then isnull((select UPPER (JSON_VALUE(divs.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) from RH.tblCatDivisiones divs where divs.IDDivision = Valor),'') 
					when IDTipoConfiguracionPlaza = 'Region' then isnull((select UPPER (JSON_VALUE(tregions.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))) from RH.tblCatRegiones tregions where tregions.IDRegion = Valor),'') 
					--when IDTipoConfiguracionPlaza = 'ClasificacionCorporativa' then isnull((select clasf.Descripcion from RH.tblCatClasificacionesCorporativas clasf where clasf.IDClasificacionCorporativa = Valor),'') 
					when IDTipoConfiguracionPlaza = 'ClasificacionCorporativa' then isnull((select ISNULL(JSON_VALUE(clasf.Traduccion, FORMATMESSAGE('$.%s.%s', '' + LOWER(REPLACE(@IDIdioma, '-', '')) + '', 'Descripcion')), '') from RH.tblCatClasificacionesCorporativas clasf where clasf.IDClasificacionCorporativa = Valor),'') 
                    when IDTipoConfiguracionPlaza = 'Perfil' then isnull((select perfil.Descripcion from Seguridad.tblCatPerfiles  perfil where perfil.IDPerfil=Valor),'')                                                        
                    when IDTipoConfiguracionPlaza = 'TipoNomina' then isnull((select tNomina.Descripcion from Nomina.tblCatTipoNomina  tNomina where tNomina.IDTipoNomina=Valor),'')                                 
                    
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
		,p.IDNivelSalarial IDNivelSalarial
        ,p.NombreNivelSalarial
        ,p.NivelSalarial
		,p.DescripcionPublicaVacante
        ,p.EsAsistente        
        ,ISNULL(p.IDNivelEmpresarial,0) AS IDNivelEmpresarial
        ,ISNULL(p.NombreNivelEmpresarial,'') AS NombreNivelEmpresarial
        ,ISNULL(p.OrdenNivelEmpresarial,0) AS OrdenNivelEmpresarial
	into #TempPlazas
	from @tempPlazas p
		left join @tempEstatusPlazas estatus on estatus.IDPlaza = p.IDPlaza and estatus.[ROW] = 1
    where ( @StringFiltroEstatus='' or estatus.IDEstatus  in ( Select item from App.Split(@StringFiltroEstatus,',')) )
	--  and (@query is null or p.Descripcion like +'%'+@query+'%' or p.Codigo like +'%'+@query+'%'  ) 
    
     
     and (estatus.IDEstatus <> 5) -- ESTATUS DE ELIMINADO

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

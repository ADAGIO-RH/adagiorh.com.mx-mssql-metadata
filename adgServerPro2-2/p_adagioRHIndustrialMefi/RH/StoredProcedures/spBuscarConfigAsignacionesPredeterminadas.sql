USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--[RH].[spBuscarConfigAsignacionesPredeterminadas] @IDConfigAsignacionPredeterminada=16 , @IDUsuario =1

CREATE proc [RH].[spBuscarConfigAsignacionesPredeterminadas](
	@IDConfigAsignacionPredeterminada int = 0
	,@IDUsuario int 
    ,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'IDConfigAsignacionPredeterminada'
	,@orderDirection varchar(4) = 'asc'
) as

DECLARE 
     @TotalPaginas int = 0
    ,@TotalRegistros int 
	,@IDIdioma varchar(20)
    
	;

select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'IDConfigAsignacionPredeterminada' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'asc' else @orderDirection end 

	set @query = case 
					when @query is null then '""' 
					when @query = '' then '""'
					when @query =  '""' then '""'
				else '"'+@query + '*"' end

    if OBJECT_ID('tempdb..#TempConfigAsignacionPredeterminadaFiltros') is not null drop table #TempConfigAsignacionPredeterminadaFiltros;
	IF OBJECT_ID('tempdb..#TempConfigAsignacionPredeterminada') IS NOT NULL DROP TABLE #TempConfigAsignacionPredeterminada  


	select 
		cap.IDConfigAsignacionPredeterminada
		,isnull(JSON_VALUE(d.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),'Sin asignar') as Departamento
		,isnull(cap.IDDepartamento,0) as IDDepartamento 
		,isnull(s.Descripcion,'SIN ASIGNAR') as Sucursal
		,isnull(cap.IDSucursal,0) as IDSucursal
		,isnull(JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),'SIN ASIGNAR') as Puesto
		,isnull(cap.IDPuesto,0) as IDPuesto
		--,isnull(cc.Descripcion,'SIN ASIGNAR') as ClasificacionCorporativa
		,isnull(JSON_VALUE(cc.Traduccion, FORMATMESSAGE('$.%s.%s', LOWER(REPLACE(@IDIdioma, '-', '')), 'Descripcion')),'SIN ASIGNAR') as ClasificacionCorporativa
		,isnull(cap.IDClasificacionCorporativa,0) as IDClasificacionCorporativa
		,isnull(JSON_VALUE(div.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')),'Sin asignar') as Division
		,isnull(cap.IDDivision,0) as IDDivision
        ,isnull(cl.NombreComercial,'SIN ASIGNAR') as Cliente
		,isnull(cap.IDCliente,0) as IDCliente
        ,isnull(a.Descripcion,'SIN ASIGNAR') as Area
		,isnull(cap.IDAreas,0) as IDAreas
        ,isnull(ctoc.Descripcion,'SIN ASIGNAR') as CentroCostos
		,isnull(cap.IDCentroCostos,0) as IDCentroCostos
        ,isnull(rs.RazonSocial,'SIN ASIGNAR') as RazonSocial
		,isnull(cap.IDRazonSocial,0) as IDRazonSocial
        ,isnull(r.Descripcion,'SIN ASIGNAR') as Region
		,isnull(cap.IDRegiones,0) as IDRegiones
        ,isnull(rp.RegistroPatronal,'SIN ASIGNAR') as RegPatronal
		,isnull(cap.IDRegPatronal,0) as IDRegPatronal
        ,isnull(tp.Descripcion,'SIN ASIGNAR') as TipoPrestaciones
		,isnull(cap.IDTipoPrestaciones,0) as IDTipoPrestaciones
		,isnull(tn.Descripcion,'SIN ASIGNAR') as TipoNomina
		,isnull(cap.IDTipoNomina,0) as IDTipoNomina
		,cap.IDsJefe
		,Jefes = ISNULL( STUFF(  
		   (   SELECT ', '+ CONVERT(NVARCHAR(100), NOMBRECOMPLETO)   
			FROM RH.tblEmpleadosMaster with (nolock)
			WHERE IDEmpleado in (select cast(rtrim(ltrim(item)) as int) from app.Split(cap.IDsJefe,','))  
			ORDER BY NOMBRECOMPLETO  asc  
			FOR xml path('')  
		   )  
		   , 1  
		   , 1  
		   , ''), 'JEFES NO DEFINIDOS')  
		,cap.IDsLectores
		,Lectores = ISNULL( STUFF(  
		   (   SELECT ', '+ CONVERT(NVARCHAR(100), Lector)   
			FROM Asistencia.tblLectores with (nolock)
			WHERE IDLector in (select cast(rtrim(ltrim(item)) as int) from app.Split(cap.IDsLectores,','))  
			ORDER BY Lector  asc  
			FOR xml path('')  
		   )  
		   , 1  
		   , 1  
		   , ''), 'LECTORES NO DEFINIDOS')  
		,cap.IDsSupervisores
		,Supervisores = ISNULL( STUFF(  
		   (   SELECT ', '+ CONVERT(NVARCHAR(100), NOMBRECOMPLETO)   
			FROM RH.tblEmpleadosMaster with (nolock)
			WHERE IDEmpleado in (select cast(rtrim(ltrim(item)) as int) from app.Split(cap.IDsSupervisores,','))  
			ORDER BY NOMBRECOMPLETO  asc  
			FOR xml path('')  
		   )  
		   , 1  
		   , 1  
		   , ''), 'SUPERVISORES NO DEFINIDOS')  
		,isnull(cap.Factor,0) as Factor
		,isnull(cap.IDUsuario,0) as IDUsuario
        ,ROW_NUMBER()OVER(ORDER BY p.IDPuesto ASC)  AS ROWNUMBER  
        into #TempConfigAsignacionPredeterminada
	from [RH].[tblConfigAsignacionesPredeterminadas] cap with (nolock)
		left join RH.tblCatDepartamentos d on d.IDDepartamento = cap.IDDepartamento
		left join RH.tblCatSucursales s on s.IDSucursal = cap.IDSucursal
		left join RH.tblCatPuestos p on p.IDPuesto = cap.IDPuesto
		left join RH.tblCatClasificacionesCorporativas cc on cc.IDClasificacionCorporativa = cap.IDClasificacionCorporativa
		left join RH.tblCatDivisiones div on div.IDDivision = cap.IDDivision
		left join Nomina.tblCatTipoNomina tn on tn.IDTipoNomina = cap.IDTipoNomina
		left join RH.tblCatClientes cl on cl.IDCliente = cap.IDCliente
		left join RH.tblCatArea a on a.IDArea = cap.IDAreas
		left join RH.tblCatCentroCosto ctoc on ctoc.IDCentroCosto = cap.IDCentroCostos
		left join RH.tblCatRazonesSociales rs on rs.IDRazonSocial = cap.IDRazonSocial
		left join RH.tblCatRegiones r on r.IDRegion = cap.IDRegiones
		left join RH.tblCatRegPatronal rp on rp.IDRegPatronal = cap.IDRegPatronal
		left join RH.tblCatTiposPrestaciones tp on tp.IDTipoPrestacion = cap.IDTipoPrestaciones
	where (cap.IDConfigAsignacionPredeterminada = @IDConfigAsignacionPredeterminada or @IDConfigAsignacionPredeterminada = 0)
	ORDER by IDConfigAsignacionPredeterminada

    	select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from #TempConfigAsignacionPredeterminada

	select @TotalRegistros = cast(COUNT([IDConfigAsignacionPredeterminada]) as decimal(18,2)) from #TempConfigAsignacionPredeterminada		
	
	select	*
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from #TempConfigAsignacionPredeterminada
	order by 	
	case when @orderByColumn = 'IDConfigAsignacionPredeterminada'			and @orderDirection = 'asc'		then IDConfigAsignacionPredeterminada end,			
		case when @orderByColumn = 'IDConfigAsignacionPredeterminada'			and @orderDirection = 'desc'	then IDConfigAsignacionPredeterminada end desc,		
		IDConfigAsignacionPredeterminada asc
	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
GO

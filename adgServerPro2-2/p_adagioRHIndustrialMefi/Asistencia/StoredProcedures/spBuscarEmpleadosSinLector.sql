USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Buscar los colaboradores que no tienen lectores asignados
** Autor			: Joseph Román
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-05-10			Aneudy Abreu	Se agregó el parámetro @IDUsuario y el JOIN a la tabla de 
									Seguridad.tblDetalleFiltrosEmpleadosUsuarios
***************************************************************************************************/
CREATE PROCEDURE [Asistencia].[spBuscarEmpleadosSinLector]  --@IDLector = 1, @IDUsuario = 1  
(    
	 @FechaIni date = '1900-01-01',    
	 @Fechafin date = '9999-12-31',    
	 @IDUsuario int = 0,    
	 @EmpleadoIni Varchar(20) = '0',    
	 @EmpleadoFin Varchar(20) = 'ZZZZZZZZZZZZZZZZZZZZ',    
	 @IDTipoNomina int = 0,    
	 @dtFiltros [Nomina].[dtFiltrosRH] READONLY,    
	 @IDLector int    
	,@PageNumber	int = 1
	,@PageSize		int = 2147483647
	,@query			varchar(100) = '""'
	,@orderByColumn	varchar(50) = 'ClaveEmpleado'
	,@orderDirection varchar(4) = 'asc'
)    
AS    
BEGIN    
 SET FMTONLY OFF;


	declare  
	   @TotalPaginas int = 0
	   ,@TotalRegistros int
	   ,@empleados [RH].[dtEmpleados]
	   ,@Conjuncion varchar(3) = 'AND'
	   ,@IDIdioma varchar(20)
	   ,@QuerySelect Varchar(Max) = ''
	   ,@QueryFrom Varchar(Max) = ''
	   ,@QueryWhere Varchar(Max) = ''
	;
 
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	if (isnull(@PageNumber, 0) = 0) set @PageNumber = 1;
	if (isnull(@PageSize, 0) = 0) set @PageSize = 2147483647;

	if object_id('tempdb..#tempFiltros') is not null drop table #tempFiltros;

	select *
	INTO #tempFiltros
	from @dtFiltros

	delete #tempFiltros
	where Value is null or Value = ''

	
	if (isnull(@EmpleadoIni,'0') = '0' and isnull(@EmpleadoFin,'ZZZZZZZZZZZZZZZZZZZZ') = 'ZZZZZZZZZZZZZZZZZZZZ')
	begin
		SET @EmpleadoIni = isnull((Select top 1 cast(item as Varchar(20)) from App.Split((Select top 1 Value from #tempFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')
		SET @EmpleadoFin = isnull((Select top 1 cast(item as Varchar(20)) from App.Split((Select top 1 Value from #tempFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZZZZZ')
	end;

	if exists(select top 1 1 from #tempFiltros where Catalogo= 'Conjuncion' and LEN([Value]) > 0)
	begin
		select @Conjuncion=Value from #tempFiltros where Catalogo= 'Conjuncion'
	end

	if (@Conjuncion not in ('OR', 'AND'))
	begin
		set @Conjuncion = 'AND'
	end

	select
		 @orderByColumn	 = case when @orderByColumn	 is null then 'Fecha' else @orderByColumn  end 
		,@orderDirection = case when @orderDirection is null then  'desc' else @orderDirection end 

	set @query = case 
		when @query is null then '""' 
		when @query = '' then '""'
		when @query = '""' then '""'
	else '"'+@query + '*"' end


  SET @QuerySelect = N'  
   select  e.*  
   from RH.tblEmpleadosMaster    e
	inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = e.IDEmpleado and dfe.IDUsuario ='+Cast(@IDUsuario as Varchar(100))

  SET @QueryWhere = N'
  WHERE (E.ClaveEmpleado BETWEEN '''+@EmpleadoIni+''' AND '''+@EmpleadoFin+''' ) 
   AND E.IDEmpleado not in (Select IDEmpleado from Asistencia.tblLectoresEmpleados WITH(NOLOCK) WHERE IDLector = '+CAST( @IDLector as varchar(100))+')
   AND E.Vigente = 1 ' +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Empleados')						THEN @Conjuncion +' ((E.IDEmpleado in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Empleados''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Departamentos')					THEN @Conjuncion +' ((E.IDDepartamento in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Departamentos''),'',''))))  ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Sucursales')						THEN @Conjuncion +' ((E.IDSucursal in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Sucursales''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Puestos')						THEN @Conjuncion +' ((E.IDPuesto in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Puestos''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Prestaciones')					THEN @Conjuncion +' ((E.IDTipoPrestacion in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Prestaciones''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Clientes')						THEN @Conjuncion +' ((E.IDCliente in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Clientes''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'RazonesSociales')				THEN @Conjuncion +' ((E.IdEmpresa in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''RazonesSociales''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'RegPatronales')					THEN @Conjuncion +' ((E.IDRegPatronal in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''RegPatronales''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Divisiones')						THEN @Conjuncion +' ((E.IDDivision in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Divisiones''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'CentrosCostos')					THEN @Conjuncion +' ((E.IDCentroCosto in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''CentrosCostos''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Areas')					        THEN @Conjuncion +' ((E.IDArea in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Areas''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'Regiones')					    THEN @Conjuncion +' ((E.IDRegion in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''Regiones''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'CentrosCostos')				    THEN @Conjuncion +' ((E.IDCentroCosto in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''CentrosCostos''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'TiposNomina')					THEN @Conjuncion +' ((E.IDTipoNomina in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''TiposNomina''),'','')))) ' ELSE '' END +
   CASE WHEN EXISTS(Select top 1 1 from #tempFiltros where Catalogo = 'TiposContratacion')				THEN @Conjuncion +' ((E.IDTipoContrato in (Select item from App.Split((Select top 1 Value from #tempFiltros where Catalogo = ''TiposContratacion''),'','')))) ' ELSE '' END +
   CASE WHEN @query = '""'	THEN '' ELSE  N'and (contains(E.*,'''+ @query+''')) ' END
   
   print @querySelect + @QueryWhere

   insert into @empleados
   exec (@querySelect + @QueryWhere)


   select @TotalPaginas =CEILING( cast(count(*) as decimal(20,2))/cast(@PageSize as decimal(20,2)))
	from @empleados

	select @TotalRegistros = COUNT(IDEmpleado) from @empleados		

	select 
		IDEmpleado    
		,ClaveEmpleado    
		,NOMBRECOMPLETO    
		,Puesto    
		,Departamento    
		,Sucursal    
		,0 as IDLector    
		,'Ninguno' as Lector 
		,TotalPaginas = case when @TotalPaginas = 0 then 1 else @TotalPaginas end
		,ISNULL(@TotalRegistros, 0) as TotalRegistros
	from @empleados
	order by 
		case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'asc'		then ClaveEmpleado end,			
		case when @orderByColumn = 'ClaveEmpleado'			and @orderDirection = 'desc'	then ClaveEmpleado end desc,		
		ClaveEmpleado asc

	OFFSET @PageSize * (@PageNumber - 1) ROWS
    FETCH NEXT @PageSize ROWS ONLY OPTION (RECOMPILE);
   


END
GO

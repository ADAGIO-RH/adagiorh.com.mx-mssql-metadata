USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spReporteBasicoObjetivosKPISExcel](
	@dtFiltros [Nomina].[dtFiltrosRH] readonly,
	@IDUsuario int 
) as
	SET FMTONLY OFF;  

	declare  
		@IDIdioma varchar(20)
		,@IDJefe int
		,@dtEmpleados [RH].[dtEmpleados]
		
		,@IDTipoNomina int
		,@ClaveEmpleadoInicial varchar(255)
		,@ClaveEmpleadoFinal varchar(255)
		,@IDCicloMedicionObjetivo int
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	IF OBJECT_ID('tempdb..#TempObjetivosEmpleados') IS NOT NULL DROP TABLE #TempObjetivosEmpleados; 
	IF OBJECT_ID('tempdb..#TempJefesEmpleados') IS NOT NULL DROP TABLE #TempJefesEmpleados; 
	
	select @ClaveEmpleadoInicial = CASE WHEN ISNULL(Value,'') = '' THEN '0' ELSE  Value END from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'
	select @ClaveEmpleadoFinal = CASE WHEN ISNULL(Value,'') = '' THEN 'ZZZZZZZZZZZZZZZZZZZZ' ELSE  Value END from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'
	SET @IDTipoNomina = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'TipoNomina'),'0'),','))
	SET @IDCicloMedicionObjetivo = (Select top 1 CAST(ITEM as int) from App.Split(isnull((select value from @dtFiltros where catalogo = 'IDCicloMedicionObjetivo'),'0'),','))    
    -- SET @IDCicloMedicionObjetivo=1

    insert into @dtEmpleados
	EXEC [RH].[spBuscarEmpleados] @IDTipoNomina = @IDTipoNomina,
                                  @EmpleadoIni = @ClaveEmpleadoInicial,
                                  @EmpleadoFin = @ClaveEmpleadoFinal,
                                  @dtFiltros = @dtFiltros,
                                  @IDUsuario = @IDUsuario
    SELECT JE.*, e.ClaveEmpleado, e.NOMBRECOMPLETO, ROW_NUMBER()OVER(Partition by je.IDEmpleado order by e.Vigente desc, isnull(Nivel, 1), je.IDEmpleado) RN
	INTO #TempJefesEmpleados
    FROM @dtEmpleados E
        INNER JOIN RH.tblJefesEmpleados JE ON JE.IDJefe=E.IDEmpleado

	select 
		e.ClaveEmpleado as [CLAVE COLABORADOR]
		,e.NOMBRECOMPLETO as [COLABORADOR]
		,e.Departamento as [DEPARTAMENTO]
		,e.Sucursal as [SUCURSAL]
		,e.Puesto as [PUESTO]
		,e.Area as [AREA]
		,e.Division as [DIVISION]

		,ISNULL(jefe.ClaveEmpleado,'SIN ASIGNAR') as [CLAVE JEFE]
		,ISNULL(jefe.NOMBRECOMPLETO,'SIN ASIGNAR') as [JEFE]
        			
		,OE.Nombre AS [OBJETIVO]
		,OE.Descripcion
		,JSON_VALUE(tmo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as TipoMedicionObjetivo 
				
		,oe.Objetivo as [ESPERADO]
		,oe.Actual
		,oe.Peso as [PESO]
		,oe.PorcentajeAlcanzado as [% ALCANZADO]
		
		,JSON_VALUE(eo.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Estatus 
		,coalesce(u.Nombre, '')+' '+coalesce(u.Apellido, '') as Usuario
        ,case when isnull(eM.Vigente, 0) = 1 then 'SI' else 'NO' end [VIGENTE HOY]
	from Evaluacion360.tblObjetivosEmpleados oe
		join [Evaluacion360].[tblCatTiposMedicionesObjetivos] tmo on tmo.IDTipoMedicionObjetivo = OE.IDTipoMedicionObjetivo
		join @dtEmpleados e on e.IDEmpleado = oe.IDEmpleado
        join RH.tblEmpleadosMaster eM on eM.IDEmpleado = e.IDEmpleado
		join Evaluacion360.tblCatEstatusObjetivosEmpleado eo on eo.IDEstatusObjetivoEmpleado = oe.IDEstatusObjetivoEmpleado
		join Seguridad.tblUsuarios u with (nolock) on u.IDUsuario = oe.IDUsuarioCreo
		left join #TempJefesEmpleados jefe on jefe.IDEmpleado = oe.IDEmpleado and jefe.RN = 1
	where (OE.IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo or isnull(@IDCicloMedicionObjetivo, 0) = 0)
	order by e.ClaveEmpleado
GO

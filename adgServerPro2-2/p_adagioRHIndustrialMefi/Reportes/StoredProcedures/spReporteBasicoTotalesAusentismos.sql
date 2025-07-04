USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Reportes].[spReporteBasicoTotalesAusentismos] (
	@dtFiltros Nomina.dtFiltrosRH readonly            
	,@IDUsuario int = 1
) as
	
	declare 
		@IDIdioma Varchar(5)  
		,@IdiomaSQL varchar(100) = null  
		,@dtEmpleados RH.dtEmpleados
		,@IDCliente int
		,@IDTipoNomina int
		,@FechaIni Date
		,@FechaFin Date
		,@IDTurno int
		,@EmpleadoIni varchar(20)
		,@EmpleadoFin varchar(20)
		,@SoloIncidencias bit = 0
		,@TipoVigente int = 1

	SET @IDTipoNomina	= isnull((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')),0)
	SET @FechaIni		= isnull((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')),getdate())
	SET @FechaFin		= isnull((Select top 1 cast(item as date) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')),getdate())
	SET @IDTurno		= isnull((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'IDTurno'),',')),0)
	SET @EmpleadoIni	= isnull((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')    
	SET @EmpleadoFin	= isnull((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoFinal'),',')),'ZZZZZZZZZZZZZZZZZZZZ')     
	SET @SoloIncidencias= isnull((Select top 1 case when [Value] = 'True' then 1 else 0 end  from @dtFiltros where Catalogo = 'SoloIncidencias'),0)
	SET @TipoVigente	= isnull((Select top 1 cast(item as int) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoVigente'),',')),1)
  
	SET DATEFIRST 7;  
  
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX') 
  
	select @IdiomaSQL = [SQL]  
	from app.tblIdiomas with (nolock)  
	where IDIdioma = @IDIdioma  
  
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)  
	begin  
		set @IdiomaSQL = 'Spanish' ;  
	end  
    
	SET LANGUAGE @IdiomaSQL; 

	if (@TipoVigente = 1)
	begin
		insert @dtEmpleados  
		exec [RH].[spBuscarEmpleados]   
		 @FechaIni		= @FechaIni           
		,@FechaFin		= @FechaFin    
		,@EmpleadoIni	= @EmpleadoIni
		,@EmpleadoFin	= @EmpleadoFin
		,@IDTipoNomina	= @IDTipoNomina         
		,@IDUsuario		= @IDUsuario                
		,@dtFiltros		= @dtFiltros 
	end else 	
	if (@TipoVigente in (2,3))
	begin
		insert @dtEmpleados  
		exec [RH].[spBuscarEmpleadosMaster]   
			 @FechaIni		= @FechaIni           
			,@FechaFin		= @FechaFin    
			,@EmpleadoIni	= @EmpleadoIni
			,@EmpleadoFin	= @EmpleadoFin
			,@IDTipoNomina	= @IDTipoNomina         
			,@IDUsuario		= @IDUsuario                
			,@dtFiltros		= @dtFiltros 

	end;

	if (@TipoVigente = 2)
	begin
		delete from @dtEmpleados where isnull(Vigente,0) = 1
	end
	

	if object_id('tempdb..#tempAusentismos')	is not null drop table #tempAusentismos 
	if object_id('tempdb..#tempData')		is not null drop table #tempData

	select distinct 
		INC.IDIncidencia,
		replace(replace(replace(replace(replace(Substring(INC.IDIncidencia,0,21)+'_'+INC.Descripcion,' ','_'),'-',''),'.',''),'(',''),')','') as INCIDENCIA,
		INC.Orden as Orden
	into #tempAusentismos
	from (select 
			 I.IDIncidencia
			,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Descripcion
			,1 as Orden
		from Asistencia.tblCatIncidencias I with (nolock) 
			where --ISNULL(I.EsAusentismo,0) = 1
			 I.IDIncidencia <> 'I'
		UNION
		select 
			 I.IDIncidencia +'_'+ CI.Codigo
			,JSON_VALUE(I.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) +'_'+ CI.Nombre
			,0 as Orden
		from Asistencia.tblCatIncidencias I with (nolock) 
			cross apply IMSS.tblCatClasificacionesIncapacidad CI
			where ISNULL(I.EsAusentismo,0) = 1
			and I.IDIncidencia = 'I'
		) INC 

		
	Select
		e.ClaveEmpleado		as CLAVE,
		e.NOMBRECOMPLETO	as NOMBRE,
		e.Empresa			as [RAZON SOCIAL],
		e.Sucursal			as SUCURSAL,
		e.Departamento		as DEPARTAMENTO,
		e.Puesto			as PUESTO,
		e.Division			as DIVISION,
		e.CentroCosto		as CENTRO_COSTO,
		A.IDIncidencia		,
		A.INCIDENCIA,
		A.ORDEN,
		COUNT(*) as TOTALAUSENTISMOS
	into #tempData
	from @dtEmpleados E
		inner join Asistencia.tblIncidenciaEmpleado IE with(nolock)
			on E.IDEmpleado = IE.IDEmpleado
		left join Asistencia.tblIncapacidadEmpleado INCEmpleado with(nolock)
			on IE.IDIncapacidadEmpleado = INCEmpleado.IDIncapacidadEmpleado
		left join IMSS.tblCatClasificacionesIncapacidad CINC with(nolock)
			on CINC.IDClasificacionIncapacidad = INCEmpleado.IDTipoIncapacidad
		inner join #tempAusentismos A with(nolock)
			on A.IDIncidencia = IE.IDIncidencia + CASE WHEN CINC.Codigo IS NOT NULL THEN +'_'+ CINC.Codigo ELSE '' END
	WHERE IE.Fecha BETWEEN @FechaIni and @FechaFin
	and ISNULL(IE.Autorizado,0) = 1
	Group by e.ClaveEmpleado
		,e.NOMBRECOMPLETO,
		e.Empresa,
		e.Sucursal ,
		e.Departamento,
		e.Puesto,
		e.Division,
		e.CentroCosto,
		e.CentroCosto,
		A.IDIncidencia,
		A.INCIDENCIA,
		A.ORDEN
	ORDER BY e.ClaveEmpleado ASC


	DECLARE @cols AS VARCHAR(MAX),
		@query1  AS VARCHAR(MAX),
		@query2  AS VARCHAR(MAX),
		@colsAlone AS VARCHAR(MAX)
	;

	SET @cols = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(A.Incidencia)+',0) AS '+ QUOTENAME(A.Incidencia)
				FROM #tempAusentismos A
				GROUP BY A.Incidencia, A.Orden
				ORDER BY A.Orden, A.INCIDENCIA
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(A.Incidencia)
				FROM #tempAusentismos A
				GROUP BY A.Incidencia, A.Orden
				ORDER BY A.Orden, A.INCIDENCIA
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	set @query1 = 'SELECT CLAVE,NOMBRE, SUCURSAL, DEPARTAMENTO, PUESTO, [RAZON SOCIAL], ' + @cols + ' from 
				(
					select CLAVE
						,Nombre
						, SUCURSAL
						, DEPARTAMENTO
						, PUESTO
						, [RAZON SOCIAL]
						, INCIDENCIA
						, isnull(TOTALAUSENTISMOS,0) as TOTALAUSENTISMOS
					from #tempData
			   ) x'


	set @query2 = '
				pivot 
				(
					 SUM(TOTALAUSENTISMOS)
					for INCIDENCIA in (' + @colsAlone + ')
				) p 
				order by CLAVE
				'

	--select len(@query1) +len( @query2) 
	--print( @query1 + @query2) 	
	exec( @query1 + @query2)
GO

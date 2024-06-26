USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	NO MOVER 
	MODIFICADO PARA GDL PLAZA
	JOSEPH ROMAN 2021-07-28
*/

	--declare  
	--	@dtFiltros Nomina.dtFiltrosRH            
	--	,@IDUsuario int = 1
	--;

	--	insert @dtFiltros(Catalogo,[Value])
	--	values('Clientes','1')
CREATE proc [Reportes].[spReporteBasicoTotalesAusentismosgdlplaza] (
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
  
	select top 1 @IDIdioma = dp.Valor  
	from Seguridad.tblUsuarios u with (nolock)  
		Inner join App.tblPreferencias p with (nolock)  
			on u.IDPreferencia = p.IDPreferencia  
		Inner join App.tblDetallePreferencias dp with (nolock)  
			on dp.IDPreferencia = p.IDPreferencia  
		Inner join App.tblCatTiposPreferencias tp with (nolock)  
			on tp.IDTipoPreferencia = dp.IDTipoPreferencia  
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'  
  
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
		INC.Orden as Orden,
		INC.IDTipoIncapacidad,
		INC.IDRiesgoIncapacidad
	into #tempAusentismos
	from (select 
			 I.IDIncidencia
			,I.Descripcion
			,1 as Orden
			,0 as IDTipoIncapacidad 
			,0 as IDRiesgoIncapacidad
		from Asistencia.tblCatIncidencias I with (nolock) 
			where ISNULL(I.EsAusentismo,0) = 1  and I.IDIncidencia<>'I'  and   ( isnull((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ausentismos'),',')),'0')='0' or I.IDIncidencia in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ausentismos'),',')))  
		UNION
		select 
			 I.IDIncidencia
			,I.Descripcion
			,1 as Orden
			,0 as IDTipoIncapacidad 
			,0 as IDRiesgoIncapacidad
		from Asistencia.tblCatIncidencias I with (nolock) 
			where ISNULL(I.EsAusentismo,0) = 0   and   ( isnull((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Incidencias'),',')),'0')='0' or I.IDIncidencia in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Incidencias'),',')))  
		UNION
		select 
			 I.IDIncidencia --+'_'+ CI.Codigo
			,I.Descripcion +'_'+ CASE WHEN CI.Codigo = '01' and CTI.Codigo= '01' THEN 'RT_ATB'
									  WHEN CI.Codigo = '01' and CTI.Codigo= '02' THEN 'RT_ATY'
									  WHEN CI.Codigo = '01' and CTI.Codigo= '03' THEN 'RT_EP'
									   WHEN CI.Codigo = '02' THEN 'EG'	
									   WHEN CI.Codigo = '03' THEN 'MT'	
									   END
									   
			,0 as Orden
			,CI.IDTIpoIncapacidad  as IDTipoIncapacidad
			, CASE WHEN CI.IDTIpoIncapacidad = 1 THEN CTI.IDTipoRiesgoIncapacidad 
				ELSE 0
				END as IDRiesgoIncapacidad
		from Asistencia.tblCatIncidencias I with (nolock) 
			cross apply sat.tblCatTiposIncapacidad CI
			cross apply imss.tblCatTipoRiesgoIncapacidad CTI
			where   I.IDIncidencia= 'I' and ( isnull((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ausentismos'),',')),'0')='0' or I.IDIncidencia in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ausentismos'),',')))
		UNION
		select 
			 I.IDIncidencia --+'_'+ CI.Codigo
			,I.Descripcion 
			,0 as Orden
			,0  as IDTipoIncapacidad
			,0as IDRiesgoIncapacidad
		from Asistencia.tblCatIncidencias I with (nolock) 
			cross apply sat.tblCatTiposIncapacidad CI
			cross apply imss.tblCatTipoRiesgoIncapacidad CTI
			where   I.IDIncidencia= 'I' and ( isnull((Select top 1 item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ausentismos'),',')),'0')='0' or I.IDIncidencia in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ausentismos'),',')))

		) INC 
		
		
	Select
		e.IDEmpleado		as IDEMPLEADO,
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
		left join imss.tblCatTipoRiesgoIncapacidad CTRI with(nolock)
			on CTRI.IDTipoRiesgoIncapacidad = INCEmpleado.IDTipoRiesgoIncapacidad 
		left join Sat.tblCatTiposIncapacidad CINC  with(nolock)
			on INCEmpleado.IDTipoIncapacidad = CINC.IDTIpoIncapacidad
		inner join #tempAusentismos A with(nolock)
			on A.IDIncidencia = IE.IDIncidencia --+ CASE WHEN CINC.Codigo IS NOT NULL THEN +'_'+ CINC.Codigo ELSE '' END
			and A.IDTipoIncapacidad = isnull(INCEmpleado.IDTipoIncapacidad,0)
			and (a.IDRiesgoIncapacidad = isnull(CTRI.IDTipoRiesgoIncapacidad,0))
	WHERE IE.Fecha BETWEEN @FechaIni and @FechaFin
	and ISNULL(IE.Autorizado,0) = 1
	Group by E.IDEmpleado 
		,e.ClaveEmpleado
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

	insert into #tempData(IDEMPLEADO, CLAVE, NOMBRE, [RAZON SOCIAL], SUCURSAL,DEPARTAMENTO, PUESTO, DIVISION,CENTRO_COSTO,IDIncidencia,A.INCIDENCIA,A.ORDEN, TOTALAUSENTISMOS)
	select distinct IDEMPLEADO
	, CLAVE
	, NOMBRE
	, [RAZON SOCIAL]
	, SUCURSAL
	,DEPARTAMENTO
	, PUESTO
	, DIVISION
	,CENTRO_COSTO
	,'I'
	,'I_INCAPACIDAD'
	,0
	,(SELECT COUNT(*) FROM Asistencia.tblIncidenciaEmpleado WHERE IDEMPLEADO = D.IDEMPLEADO and IDIncidencia = 'I'and autorizado = 1 and Fecha between @FechaIni and @FechaFin)
	from #tempData d --where INCIDENCIA = 'I_INCAPACIDAD'		 
																	
																	
	DECLARE @cols AS VARCHAR(MAX),									 
		@query1  AS VARCHAR(MAX),
		@query2  AS VARCHAR(MAX),
		@colsAlone AS VARCHAR(MAX)
	;

	SET @cols = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(A.Incidencia)+',0) AS '+ QUOTENAME(A.Incidencia)
				FROM #tempAusentismos A
				WHERE A.IDIncidencia in (Select  item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ausentismos'),','))or A.IDIncidencia in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Incidencias'),','))
				GROUP BY A.Incidencia, A.Orden
				ORDER BY A.Orden, A.INCIDENCIA
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(A.Incidencia)
				FROM #tempAusentismos A
				WHERE A.IDIncidencia in (Select  item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ausentismos'),','))or A.IDIncidencia in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Incidencias'),','))
				GROUP BY A.Incidencia, A.Orden
				ORDER BY A.Orden, A.INCIDENCIA
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	set @query1 = 'SELECT CLAVE,NOMBRE,  ' + @cols + ' from 
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

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reportes].[spTotalDeSolicitudesPorEstadoDeProceso]  
	@dtFiltros Nomina.dtFiltrosRH readonly
    ,@IDUsuario   int  
AS
	DECLARE 
		@cols AS VARCHAR(MAX),
		@query1  AS VARCHAR(MAX),
		@query2  AS VARCHAR(MAX),
		@colsAlone AS VARCHAR(MAX),
		@IDIdioma varchar(20),
		@IDTipoCatalogoEstatusPosiciones int = 5
	;

	if object_id('tempdb..#tempDataPlazas') is not null drop table #tempDataPlazas
	if object_id('tempdb..#tempData') is not null drop table #tempData

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	
	declare @tempEstatusPosiciones as table (
		IDPlaza int,
		IDPosicion int,
		IDEstatus int,
		Estatus varchar(255),
		Reclutador varchar(500),
		[ROW] int
	)

	SET @cols = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')))+',0) AS '+ QUOTENAME(Descripcion)
				from Reclutamiento.tblCatEstatusProceso 
				order by Orden asc
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')))
				from Reclutamiento.tblCatEstatusProceso 
				order by Orden asc
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	select	
		p.IDPlaza,
		p.Codigo as CodigoPlaza,
		JSON_VALUE(puesto.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) as Puesto,
		(
			select 
				isnull((select suc.Descripcion from RH.tblCatSucursales suc where suc.IDSucursal = config.Valor), '[SIN ASIGNAR]') 
			from OPENJSON(p.Configuraciones, '$') 
			with (
				IDTipoConfiguracionPlaza varchar(max), 
				Valor int
			) as config
			where IDTipoConfiguracionPlaza = 'Sucursal'
		) as Sucursal,
		JSON_VALUE(ep.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Estatus
	INTO #tempDataPlazas
	from RH.tblCatPlazas p 
		join RH.tblCatPuestos puesto on puesto.IDPuesto = p.IDPuesto
		join Reclutamiento.tblCandidatoPlaza cp on cp.IDPlaza = p.IDPlaza
		join Reclutamiento.tblCatEstatusProceso ep on ep.IDEstatusProceso = cp.IDProceso
	
	insert @tempEstatusPosiciones
	select 
		plazas.IDPlaza
		,posiciones.IDPosicion
		,isnull(estatusPosiciones.IDEstatus,0) AS IDEstatus
		,isnull(estatus.Catalogo,'Sin estatus') AS Estatus
		,isnull(e.NOMBRECOMPLETO, 'SIN RECLUTADOR') as Reclutador
		,ROW_NUMBER()over(partition by posiciones.IDPosicion 
							ORDER by posiciones.IDPosicion, estatusPosiciones.FechaReg  desc) as [ROW]
	from #tempDataPlazas plazas
		join RH.tblCatPosiciones posiciones on posiciones.IDPlaza = plazas.IDPlaza
		left join RH.tblEstatusPosiciones estatusPosiciones on estatusPosiciones.IDPosicion = posiciones.IDPosicion 
		left join RH.tblEmpleadosMaster e on e.IDEmpleado = estatusPosiciones.IDReclutador
		left join [App].[tblCatalogosGenerales] estatus with (nolock) on estatus.IDCatalogoGeneral = estatusPosiciones.IDEstatus and estatus.IDTipoCatalogo = @IDTipoCatalogoEstatusPosiciones

	select distinct
		Puesto,
		Sucursal,
		CodigoPlaza,
		p.Estatus,
		Reclutador
	INTO #tempData
	from #tempDataPlazas p
		join @tempEstatusPosiciones estatus on estatus.IDPlaza = p.IDPlaza
	where estatus.ROW = 1

	set @query1 = 'SELECT Reclutador,Puesto as PLAZA,SUCURSAL,CodigoPlaza AS [CÓDIGO DE LA PLAZA], ' + @cols + ' from 
				(
					select 
						Reclutador,
						 Puesto,
						 Sucursal,
						 CodigoPlaza,
						 Estatus
					from #tempData
			   ) x'

	set @query2 = '
				pivot 
				(
					 COUNT(Estatus)
					for Estatus in (' + @colsAlone + ')
				) p 
				'
	exec(@query1 + @query2)
GO

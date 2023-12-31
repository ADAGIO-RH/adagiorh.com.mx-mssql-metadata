USE [p_adagioRHFabricasSelectas]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [Reportes].[spTotalDeSolicitudesPorEstadoDeProceso]  
	-- Add the parameters for the stored procedure here
	@dtFiltros Nomina.dtFiltrosRH readonly
    ,@IDUsuario   int  
AS
	DECLARE 
		@cols AS VARCHAR(MAX),
		@query1  AS VARCHAR(MAX),
		@query2  AS VARCHAR(MAX),
		@colsAlone AS VARCHAR(MAX),
		@IDIdioma varchar(20)
	;

	if object_id('tempdb..#tempData') is not null drop table #tempData

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	SET @cols = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(Descripcion)+',0) AS '+ QUOTENAME(Descripcion)
				from Reclutamiento.tblCatEstatusProceso 
				order by Orden asc
				FOR XML PATH(''), TYPE
				).value('.', 'VARCHAR(MAX)') 
			,1,1,'');

	SET @colsAlone = STUFF((SELECT ','+ QUOTENAME(Descripcion)
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
		ep.Descripcion as Estatus
	INTO #tempData
	from RH.tblCatPlazas p
		join RH.tblCatPuestos puesto on puesto.IDPuesto = p.IDPuesto
		join Reclutamiento.tblCandidatoPlaza cp on cp.IDPlaza = p.IDPlaza
		join Reclutamiento.tblCatEstatusProceso ep on ep.IDEstatusProceso = cp.IDProceso
	
	set @query1 = 'SELECT Puesto as PLAZA,SUCURSAL,CodigoPlaza AS [CÓDIGO DE LA PLAZA], ' + @cols + ' from 
				(
					select 
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

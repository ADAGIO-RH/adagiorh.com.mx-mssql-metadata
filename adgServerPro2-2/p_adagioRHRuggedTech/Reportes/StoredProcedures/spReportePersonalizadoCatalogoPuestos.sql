USE [p_adagioRHRuggedTech]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc Reportes.spReportePersonalizadoCatalogoPuestos as	
	DECLARE  
		@IDIdioma Varchar(5)        
	   ,@IdiomaSQL varchar(100) = null
		,@IDUsuario int=1
	;   

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')    
        
	select @IdiomaSQL = [SQL]        
	from app.tblIdiomas with (nolock)        
	where IDIdioma = @IDIdioma        
        
	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)        
	begin        
		set @IdiomaSQL = 'Spanish' ;        
	end        
          
	SET LANGUAGE @IdiomaSQL;   

begin -- DatosExtras puestos
		if object_id('tempdb..#tempCatDatosExtraPuestos')	is not null drop table #tempCatDatosExtraPuestos
		if object_id('tempdb..##tempDatosExtraPuestos')	is not null drop table ##tempDatosExtraPuestos
		if object_id('tempdb..#tempDatosExtraPuestosValores')	is not null drop table #tempDatosExtraPuestosValores


		select 
			IDDatoExtra, 
			JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) as Nombre
		INTO #tempCatDatosExtraPuestos
		from App.tblCatDatosExtras
		where IDTipoDatoExtra = 'puestos'

		--select *
		--from #tempDatosExtraPuestos

		select Nombre, IDReferencia as IDPuesto, Valor
		INTO #tempDatosExtraPuestosValores
		from #tempCatDatosExtraPuestos de
			left join App.tblValoresDatosExtras v on v.IDDatoExtra = de.IDDatoExtra

		DECLARE @colsExtraPuestos AS VARCHAR(MAX),
			@query1ExtraPuestos  AS VARCHAR(MAX),
			@query2ExtraPuestos  AS VARCHAR(MAX),
			@colsAloneExtraPuestos AS VARCHAR(MAX)
		;

		SET @colsExtraPuestos = STUFF((SELECT ',' +' ISNULL('+ QUOTENAME(c.Nombre)+',0) AS '+ QUOTENAME(c.Nombre)
					FROM #tempCatDatosExtraPuestos c
					ORDER BY c.Nombre
					FOR XML PATH(''), TYPE
					).value('.', 'VARCHAR(MAX)') 
				,1,1,'');

				print @colsExtraPuestos

		SET @colsAloneExtraPuestos = STUFF((SELECT ','+ QUOTENAME(c.Nombre)
					FROM #tempCatDatosExtraPuestos c
					ORDER BY c.Nombre
					FOR XML PATH(''), TYPE
					).value('.', 'VARCHAR(MAX)') 
				,1,1,'');

		set @query1ExtraPuestos = 'SELECT IDPuesto ' + coalesce(','+@colsExtraPuestos, '') + ' 
						into ##tempDatosExtraPuestos
						from 
					(
						select IDPuesto
							,Nombre
							,Valor
						from #tempDatosExtraPuestosValores
					) x'

		set @query2ExtraPuestos = '
					pivot 
					(
							MAX(Valor)
						for Nombre in (' + coalesce(@colsAloneExtraPuestos, 'NO_INFO')  + ')
					) p 
					order by IDPuesto
					'

		--select len(@query1) +len( @query2) 

		exec( @query1ExtraPuestos + @query2ExtraPuestos) 
	end

select 
	puesto.Codigo
	,JSON_VALUE(puesto.Traduccion, FORMATMESSAGE('$.%s.%s', 'esmx', 'Descripcion')) as Descripcion_Español
	,JSON_VALUE(puesto.Traduccion, FORMATMESSAGE('$.%s.%s', 'enus', 'Descripcion')) as Descripcion_Ingles
	,puesto.SueldoBase
	,puesto.TopeSalarial
	--,puesto.IDOcupacion
	,o.Descripcion as Ocupacion
	,extraPuestos.*
	,[Utilerias].[fnHTMLStr](puesto.DescripcionPuesto) as DescripcionPuesto
	--,puesto.Traduccion
from RH.tblCatPuestos puesto
		left join ##tempDatosExtraPuestos extraPuestos on extraPuestos.IDPuesto = puesto.IDPuesto
		left join STPS.tblCatOcupaciones o on o.IDOcupaciones = puesto.IDOcupacion
GO

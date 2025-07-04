USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc App.spBuscarCatAplicacionesDocsWebSite as
	select 
		IDAplicacion as id,
		Descripcion as title,
		DescripcionDocs as [description],
		Orden as [order],
		--Icon as icon,
		null as icon,
		[Url],
		null as span,
		JSON_QUERY(Traduccion) as translation,
		'/modules/'+TRANSLATE(replace(LOWER(Descripcion), ' ', '-'), 
			  'ñáéíóúàèìòùãõâêîôôäëïöüçÑÁÉÍÓÚÀÈÌÒÙÃÕÂÊÎÔÛÄËÏÖÜÇ ', 
			  'naeiouaeiouaoaeiooaeioucNAEIOUAEIOUAOAEIOOAEIOUC_') as href
	from App.tblCatAplicaciones
	order by Orden asc
	for json auto, INCLUDE_NULL_VALUES
GO

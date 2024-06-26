USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Docs].[spBuscador]-- 1
(
	@IDUsuario int 
)
AS
BEGIN
	
		
	if OBJECT_ID('tempdb..#tempAprobadores') is not null drop table #tempAprobadores;

	select * ,ROW_NUMBER()OVER(Partition by IDDocumento order by IDAprobadorDocumento)RN
	into #tempAprobadores
	from Docs.tblAprobadoresDocumentos ad
	where( ad.Aprobacion = 0
	OR ad.Aprobacion = 2)
	and ad.Secuencia = (select MAX(Secuencia) from Docs.tblAprobadoresDocumentos where IDDocumento = ad.IDDocumento)

	if OBJECT_ID('tempdb..#tempExpirados') is not null drop table #tempExpirados;

	select * 
	into #tempExpirados
	from Docs.tblCarpetasDocumentos
	where( (ValidoHasta <= getdate()) and Expira = 1)


	Select 
	 docs.IDItem
	,docs.TipoItem
	,docs.IDParent
	--,(select top 1 Nombre from Docs.tblCarpetasDocumentos where IDItem = docs.IDParent ) as Parent
	,Parent.Nombre as Parent
	,docs.Nombre
	,docs.FilePath 
	,docs.[Descripcion] 
	,docs.[Version] 
	,docs.[PalabrasClave] 
	,docs.[Comentario] 
	,isnull(docs.[ValidoDesde],'1900-01-01') as [ValidoDesde]
	,isnull(docs.[ValidoHasta],'9999-12-31') as [ValidoHasta] 
	,isnull(docs.[Expira],0) as [Expira] 
	,isnull(docs.[DiasAntesCaducidad],0) as  [DiasAntesCaducidad]
	,isnull(docs.[IDTipoDocumento],0) as [IDTipoDocumento] 
	,isnull(td.[Descripcion],'') as [TipoDocumento] 
	,isnull(docs.[Icono], case when docs.TipoItem = 0 then 'fa fa-folder-open-o' else 'fa fa-file-o' end) as [Icono]
	,isnull(docs.[IDAutor],0) as [IDAutor]
	,isnull(docs.[IDPublicador],0) as [IDPublicador]
	,isnull(docs.[FechaCreacion],getdate()) as [FechaCreacion]
	,isnull(docs.[FechaUltimaActualizacion],getdate()) as [FechaUltimaActualizacion]
	,isnull(docs.[Visualizar],0) as  [Visualizar]
	,isnull(docs.[Descargar],0) as [Descargar] 
	,CAST(CASE WHEN isnull(df.[IDDocumentoFavorito],0) = 0 THEN 0 ELSE 1 END as BIT) as [Favorito] 
	,isnull(docs.[Color],'#000') as [Color]
	,ROW_NUMBER()Over(Order by docs.IDItem asc) as ROWNUMBER
	from Docs.tblCarpetasDocumentos docs
		left join docs.tblCatTiposDocumento td
			on docs.IDTipoDocumento = td.IDTipoDocumento
		left join docs.tblDocumentosFavoritos df
			on df.IDDocumento = docs.IDItem
			and df.IDUsuario = @IDUsuario
		left join Docs.tblCarpetasDocumentos Parent
			on docs.IDParent = Parent.IDItem
		
	where  (docs.IDItem in (select IDDocumento from  Docs.tblDetalleFiltrosDocumentosUsuarios where IDUsuario = @IDUsuario))
	and docs.TipoItem = 1
	and (docs.IDItem not in (select IDDocumento from #tempAprobadores))
	and docs.IDItem not in((select IDItem from #tempExpirados))
	order by Parent.Nombre,docs.Nombre
	--and (((Expira = 1) and getdate() > ( dateadd(DAY,-(DiasAntesCaducidad),[ValidoHasta]))) OR Expira =  0)
END
GO

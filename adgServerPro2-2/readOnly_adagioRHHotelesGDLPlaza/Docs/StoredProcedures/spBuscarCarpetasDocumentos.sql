USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Docs].[spBuscarCarpetasDocumentos]
(
	@IDItem int = 0
)
AS
BEGIN
	Select 
	IDItem
	,TipoItem
	,IDParent
	,Nombre
	,FilePath 
	,[Descripcion] 
	,[Version] 
	,[PalabrasClave] 
	,[Comentario] 
	,isnull([ValidoDesde],'1900-01-01') as [ValidoDesde]
	,isnull([ValidoHasta],'9999-12-31') as [ValidoHasta] 
	,isnull([Expira],0) as [Expira] 
	,isnull([DiasAntesCaducidad],0) as  [DiasAntesCaducidad]
	,isnull([IDTipoDocumento],0) as [IDTipoDocumento] 
	,isnull([Icono], case when TipoItem = 0 then 'fa fa-folder-open-o' else 'fa fa-file-o' end) as [Icono]
	,isnull([IDAutor],0) as [IDAutor]
	,isnull([IDPublicador],0) as [IDPublicador]
	,isnull([FechaCreacion],getdate()) as [FechaCreacion]
	,isnull([FechaUltimaActualizacion],getdate()) as [FechaUltimaActualizacion]
	,isnull([Visualizar],0) as  [Visualizar]
	,isnull([Descargar],0) as [Descargar] 
	,isnull([Color],'#000') as [Color]
	,ROW_NUMBER()Over(Order by IDItem asc) as ROWNUMBER
	from Docs.tblCarpetasDocumentos
	where ((IDItem = @IDItem) or (Isnull(@IDItem,0) = 0))
END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Docs].[spBuscarCarpetas](
	@IDItem int = 0
)
AS
BEGIN

SET FMTONLY OFF;
	

	Select 
	 s.IDItem
	,s.TipoItem
	,s.IDParent
	,s.Nombre
	,s.FilePath 
	,s.[Descripcion] 
	,s.[Version] 
	,s.[PalabrasClave] 
	,s.[Comentario] 
	,isnull(s.[ValidoDesde],'1900-01-01') as [ValidoDesde]
	,isnull(s.[ValidoHasta],'9999-12-31') as [ValidoHasta] 
	,isnull(s.[Expira],0) as [Expira] 
	,isnull(s.[DiasAntesCaducidad],0) as  [DiasAntesCaducidad]
	,isnull(s.[IDTipoDocumento],0) as [IDTipoDocumento] 
	,isnull(s.[Icono], case when s.TipoItem = 0 then 'fa fa-folder-open-o' else 'fa fa-file-o' end) as [Icono]
	,isnull(s.[IDAutor],0) as [IDAutor]
	,isnull(u.Cuenta+' - '+u.Nombre+' '+u.Apellido,'') as [Autor]
	,isnull(s.[IDPublicador],0) as [IDPublicador]
	,isnull(ua.Cuenta+' - '+ua.Nombre+' '+ua.Apellido,'') as [Publicador]
	,isnull(s.[FechaCreacion],getdate()) as [FechaCreacion]
	,isnull(s.[FechaUltimaActualizacion],getdate()) as [FechaUltimaActualizacion]
	,isnull(s.[Visualizar],0) as  [Visualizar]
	,isnull(s.[Descargar],0) as [Descargar] 
	,isnull(s.[Color],'#000') as [Color]
	from Docs.tblCarpetasDocumentos s
		left join Seguridad.tblUsuarios u
			on s.IDAutor = u.IDUsuario
		left join Seguridad.tblUsuarios ua
			on s.IDPublicador = ua.IDUsuario
	where ((s.IDItem = @IDItem) or (Isnull(@IDItem,0) = 0))
		
END
GO

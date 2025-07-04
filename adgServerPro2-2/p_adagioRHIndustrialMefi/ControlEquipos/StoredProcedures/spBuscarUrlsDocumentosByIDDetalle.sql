USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [ControlEquipos].[spBuscarUrlsDocumentosByIDDetalle](
	@IDUsuario int
	,@IDDetalleArticulo int
)
as
begin
	select 
		IDUrlDocumentos,
		IDDetalleArticulo,
		[Url],
		NombreDocumento
	from ControlEquipos.tblUrlsDocumentosDetallesArticulos
	where IDDetalleArticulo = @IDDetalleArticulo
	order by IDUrlDocumentos asc
end
GO

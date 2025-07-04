USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [ControlEquipos].[spBorrarUrlDocumento](
	@IDUsuario int
	,@IDUrlDocumentos int
)
as
begin
	begin try
		if exists(select top 1 1 from ControlEquipos.tblUrlsDocumentosDetallesArticulos where IDUrlDocumentos = @IDUrlDocumentos)
		begin
			delete from ControlEquipos.tblUrlsDocumentosDetallesArticulos where IDUrlDocumentos = @IDUrlDocumentos
		end
	end try
	begin catch
		declare @error varchar(100);
		set @error = 'Ha ocurrido un error al intentar borrar'
		raiserror(@error, 16, 1)
	end catch
end
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [ControlEquipos].[spIUrlDocumento](
	@IDUsuario int
	,@IDDetalleArticulo int
	,@Url varchar(max)
	,@NombreDocumento varchar(max)
)
as
begin
	begin try
		declare @error varchar(100)
		begin tran Idocumento
			insert into ControlEquipos.tblUrlsDocumentosDetallesArticulos(IDDetalleArticulo, [Url], NombreDocumento)
			values(@IDDetalleArticulo, @Url, @NombreDocumento)
		if @@ROWCOUNT = 1
			commit tran Idocumento
		else
			rollback tran Idocumento
			
	end try
	begin catch
		set @error = 'Ha ocurrido un error al registrar la URL del documento'
		raiserror(@error, 16, 1)
	end catch
end
GO

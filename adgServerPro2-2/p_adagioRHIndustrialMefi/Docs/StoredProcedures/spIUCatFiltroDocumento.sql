USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Docs].[spIUCatFiltroDocumento](
	 @IDCatFiltroDocumento int = 0	
	,@IDDocumento int			
	,@Nombre varchar(255)	
	,@IDUsuarioCreo int		
) as

	if (ISNULL(@IDCatFiltroDocumento,0) = 0)
	begin
		insert Docs.tblCatFiltrosDocumentos(IDDocumento,Nombre,IDUsuarioCreo)
		values (@IDDocumento,@Nombre,@IDUsuarioCreo)

		set @IDCatFiltroDocumento = @@IDENTITY
	end else
	begin
		update Docs.tblCatFiltrosDocumentos
			set Nombre = @Nombre
		where IDCatFiltroDocumento = @IDCatFiltroDocumento
	end;

	exec [Docs].[spBuscarCatFiltrosDocumentos] @IDCatFiltroDocumento = @IDCatFiltroDocumento, @IDDocumento = @IDDocumento
GO

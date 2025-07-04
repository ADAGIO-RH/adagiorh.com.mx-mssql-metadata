USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Comunicacion].[spBorrarAviso](
    @IDAviso    int = 0
    ,@IDUsuario int
)
as
	begin try
		delete from Comunicacion.tblEmpleadosAvisos where IDAviso= @IDAViso
        delete from Comunicacion.tblFiltrosAvisos where IDAviso= @IDAviso
        delete from Comunicacion.tblAvisos where IDAviso= @IDAviso

	end try
	begin catch
		exec [App].[spObtenerError] 
			 @IDUsuario = @IDUsuario,
			 @CodigoError = '0302002';
		return 0;
	end catch;
GO

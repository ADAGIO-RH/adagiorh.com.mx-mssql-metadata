USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Comedor].[spBorrarCatCategorias](@IDCategoria int = 0
											   ,@IDUsuario      int
											   )
as
	begin try
		delete [Comedor].[TblCatCategorias]
		where 
			  [IDCategoria] = @IDCategoria;
	end try
	begin catch
		exec [App].[Spobtenererror] 
			 @IDUsuario = @IDUsuario,
			 @CodigoError = '0302002';
		return 0;
	end catch;
GO

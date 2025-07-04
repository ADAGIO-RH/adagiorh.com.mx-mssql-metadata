USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [Resguardo].[spBorrarArticulo](
	@IDArticulo int
	,@IDUsuario int
) as
	BEGIN TRY  
		delete from [Resguardo].[tblCatPropiedadesArticulos] where TipoReferencia = 1 and IDReferencia = @IDArticulo
		delete from [Resguardo].[tblHistorial] where IDArticulo = @IDArticulo

		DELETE [Resguardo].[tblArticulos] WHERE IDArticulo = @IDArticulo
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
GO

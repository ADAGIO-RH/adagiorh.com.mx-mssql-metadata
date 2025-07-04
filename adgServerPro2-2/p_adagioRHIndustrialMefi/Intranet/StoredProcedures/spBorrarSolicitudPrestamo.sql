USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Intranet].[spBorrarSolicitudPrestamo] (
	@IDSolicitudPrestamo int,
	@IDUsuario int
) as

	BEGIN TRY  
		DELETE [Intranet].[tblSolicitudesPrestamos] WHERE IDSolicitudPrestamo = @IDSolicitudPrestamo
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
GO

USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Intranet].[spBuscarEstatusSolicitudesPrestamos] (
	@IDEstatusSolicitudPrestamo int = 0
) as
	select
		IDEstatusSolicitudPrestamo
		,Nombre
		,CssClass
	from [Intranet].[tblCatEstatusSolicitudesPrestamos]
	where (IDEstatusSolicitudPrestamo = @IDEstatusSolicitudPrestamo or isnull(@IDEstatusSolicitudPrestamo, 0) = 0)
GO

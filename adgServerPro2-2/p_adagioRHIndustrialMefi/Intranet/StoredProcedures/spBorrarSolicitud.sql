USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Intranet].[spBorrarSolicitud](
	 @IDSolicitud	int		
	,@IDUsuario				int		
) as
	delete from  [Intranet].[tblSolicitudesEmpleado]
	where IDSolicitud = @IDSolicitud
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [App].[IAdjuntoNotificacion](
	@IDEnviarNotificacionA int,
	@FileName varchar(255),
	@Extension varchar(10),
	@Data  varchar(max)
) as
begin
	if (isnull(@Data, '') = '')
		return 

	insert App.tblAdjuntosNotificaciones(IDEnviarNotificacionA, [FileName], Extension, [Data])
	select @IDEnviarNotificacionA, @FileName, @Extension, @Data
end
GO

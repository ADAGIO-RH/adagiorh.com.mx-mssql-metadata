USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [App].[ILogErrorEnEnvioNotificacion](
	@IDEnviarNotificacionA int
	,@Mensaje nvarchar(max)
) as

	insert into  [App].TblLogErroresEnEnvioNotificaciones(IDEnviarNotificacionA,Mensaje)
	select @IDEnviarNotificacionA,@Mensaje
GO

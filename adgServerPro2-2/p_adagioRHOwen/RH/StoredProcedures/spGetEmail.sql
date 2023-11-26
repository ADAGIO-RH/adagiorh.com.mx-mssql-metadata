USE [p_adagioRHOwen]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create   proc RH.spGetEmail(
	@IDEmpleado int = 0,
    @IDUsuario int = 0,
	@IDTipoNotificacion nvarchar(max)= null
) as

	select 
		[Utilerias].[fnGetCorreoEmpleado](@IDEmpleado, @IDUsuario,@IDTipoNotificacion) as Email
GO

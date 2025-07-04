USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [RH].[spBuscarNotasEmpleado](
	@IDNotaEmpleado int = 0		
	,@IDEmpleado int = 0			
	,@IDUsuario int		
) as
	
	select
		 ne.IDNotaEmpleado
		,ne.IDEmpleado
		,ne.Fecha
		,ne.Nota
		,ne.IDUsuario
		,u.Nombre as Usuario
		,ne.FechaHoraReg
	from RH.tblNotasEmpleados ne
		join Seguridad.tblUsuarios u on ne.IDUsuario = u.IDUsuario
	where (ne.IDNotaEmpleado = @IDNotaEmpleado or @IDNotaEmpleado = 0)
		and (ne.IDEmpleado = @IDEmpleado or @IDEmpleado = 0)
GO

USE [p_adagioRHCSMPresupuesto]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



create proc RH.spBuscarPosicionActualEmpleado(
	@IDEmpleado int,
	@IDUsuario int
) as

	select 
		IDPosicion
	from RH.tblCatPosiciones
	where IDEmpleado = @IDEmpleado
GO

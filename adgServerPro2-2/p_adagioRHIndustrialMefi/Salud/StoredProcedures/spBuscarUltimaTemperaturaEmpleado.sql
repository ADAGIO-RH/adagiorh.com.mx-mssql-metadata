USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc Salud.spBuscarUltimaTemperaturaEmpleado(
	@IDEmpleado int,
	@IDUsuario int
) as
	--declare 
	--	@IDEmpleado int = 1279
	--;

	select top 1 *
	from Salud.tblTemperaturaEmpleado with (nolock)
	where IDEmpleado = @IDEmpleado
	order by FechaHora desc
GO

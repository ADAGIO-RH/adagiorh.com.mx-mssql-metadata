USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc ControlEquipos.spBorrarArticuloPorPuesto(
	@IDArticulosPorPuesto int = 0
	,@IDUsuario int
) as

	delete ControlEquipos.tblArticulosPorPuesto
	where IDArticulosPorPuesto = @IDArticulosPorPuesto
GO

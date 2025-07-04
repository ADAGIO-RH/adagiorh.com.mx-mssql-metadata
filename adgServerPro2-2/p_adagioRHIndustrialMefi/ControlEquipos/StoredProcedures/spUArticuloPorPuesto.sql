USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [ControlEquipos].[spUArticuloPorPuesto](
	@IDArticulosPorPuesto int
	,@IDUsuario int
	,@Cantidad int
)
as
begin
	if exists (select top 1 1 from ControlEquipos.tblArticulosPorPuesto where IDArticulosPorPuesto = @IDArticulosPorPuesto)
	begin
		update ControlEquipos.tblArticulosPorPuesto
			set
				Cantidad = @Cantidad
		where IDArticulosPorPuesto = @IDArticulosPorPuesto
	end else
	begin
		raiserror('No existe este artículo por puesto', 16, 1)
		return
	end
end
GO

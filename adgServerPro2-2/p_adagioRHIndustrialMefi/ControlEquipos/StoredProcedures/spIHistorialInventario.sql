USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc ControlEquipos.spIHistorialInventario(
	@IDArticulo int
	,@IDUsuario int
	,@Cantidad int
	,@TipoMovimiento varchar(3)
	,@Razon varchar(max)
	,@IDsDetalleArticulo varchar(max)
)
as
begin
	declare @CantidadAnterior int
	select @CantidadAnterior = Cantidad from ControlEquipos.tblArticulos where IDArticulo = @IDArticulo

	insert into ControlEquipos.tblHistorialInventario(IDArticulo, IDUsuario, Fecha,Cantidad, CantidadAnterior,CantidadActual, TipoMovimiento, Razon, IDsDetalleArticulo)
	values(@IDArticulo, @IDUsuario, getdate(), @Cantidad,@CantidadAnterior, (@CantidadAnterior+@Cantidad ) , @TipoMovimiento, @Razon, @IDsDetalleArticulo)

	exec ControlEquipos.spActualizarInventarios
	@IDUsuario = @IDUsuario
	,@IDArticulo = @IDArticulo
end
GO

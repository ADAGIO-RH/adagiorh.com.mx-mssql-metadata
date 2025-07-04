USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [ControlEquipos].[spBorrarDetalleArticulos](
	@IDDetalleArticulo int,
    @IDUsuario int
)
as
begin
	declare @ID_CAT_ESTATUS_ARTICULO_ASIGNADO int = 2, @ID_CAT_ESTATUS_ARTICULO_REPARACION_MANTENIMIENTO int = 10, @IDArticulo int;
	declare @tblestatus table(
		IDEstatusArticulo int,
		IDCatEstatusArticulo int
	)
	select @IDArticulo = IDArticulo from ControlEquipos.tblDetalleArticulos where IDDetalleArticulo = @IDDetalleArticulo
	insert into @tblestatus
	select top 1 IDEstatusArticulo, IDCatEstatusArticulo from ControlEquipos.tblEstatusArticulos where IDDetalleArticulo = @IDDetalleArticulo order by IDEstatusArticulo desc
	if exists(select top 1 1 from ControlEquipos.tblDetalleArticulos where IDDetalleArticulo = @IDDetalleArticulo)
	begin
		if exists(select top 1 1 from @tblestatus where IDCatEstatusArticulo = @ID_CAT_ESTATUS_ARTICULO_ASIGNADO order by IDEstatusArticulo desc)
		begin
			raiserror('No puedes eliminar un detalle de artículo mientras está asignado a un colaborador',16,1);
			return;
		end
		if exists(select top 1 1 from @tblestatus where IDCatEstatusArticulo = @ID_CAT_ESTATUS_ARTICULO_REPARACION_MANTENIMIENTO order by IDEstatusArticulo desc)
		begin
			raiserror('No puedes eliminar un detalle de artículo en reparación o mantenimiento',16,1);
			return;
		end
		delete from [ControlEquipos].[tblValoresPropiedades] where IDDetalleArticulo = @IDDetalleArticulo
		delete from [ControlEquipos].[tblEstatusArticulos] where IDDetalleArticulo = @IDDetalleArticulo
		delete from [ControlEquipos].[tblDetalleArticulos] where IDDetalleArticulo = @IDDetalleArticulo

	exec ControlEquipos.spIHistorialInventario
		@IDArticulo = @IDArticulo
		,@IDUsuario= @IDUsuario
		,@Cantidad = -1
		,@TipoMovimiento = 'OUT'
		,@Razon = 'Detalle dado de baja'
		,@IDsDetalleArticulo = @IDDetalleArticulo
	end
end
GO

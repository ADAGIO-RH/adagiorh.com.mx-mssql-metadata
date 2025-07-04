USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [ControlEquipos].[BorrarMetodoDepreciacion](
	@IDMetodoDepreciacion int,
	@IDUsuario int
)
as
begin
	declare @Count int, @ErrorMessage varchar(max);

	select @Count = count(IDMetodoDepreciacion) 
	from ControlEquipos.tblArticulos 
	where IDMetodoDepreciacion = @IDMetodoDepreciacion

	if exists(select top 1 1 from ControlEquipos.tblMetodoDepreciacion where IDMetodoDepreciacion = @IDMetodoDepreciacion)
	begin
		if @Count > 0
		begin
			set @ErrorMessage = 'No puedes borrar este método de depreciación porque existen al menos ' + cast(@Count as varchar(10)) + ' artículos que usan este método';
			raiserror(@ErrorMessage, 16, 1)
			return
		end else
		begin
			delete from ControlEquipos.tblMetodoDepreciacion where IDMetodoDepreciacion = @IDMetodoDepreciacion
		end
	end
end
GO

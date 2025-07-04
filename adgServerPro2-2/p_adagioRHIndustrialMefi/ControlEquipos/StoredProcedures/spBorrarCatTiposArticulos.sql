USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [ControlEquipos].[spBorrarCatTiposArticulos](
	@IDTipoArticulo int
)
as
begin
	declare @CantidadArticulos int = (select count(IDArticulo) from ControlEquipos.tblArticulos where IDTipoArticulo = @IDTipoArticulo)
	--select @CantidadArticulos as articulos
	--return
	if exists(select top 1 1 from ControlEquipos.tblCatTiposArticulos where IDTipoArticulo = @IDTipoArticulo)
	begin
		if @CantidadArticulos > 0
		begin
			declare @error varchar(200) = 'Existen ' + cast(@CantidadArticulos as varchar(10)) + ' artículo(s) relacionado(s) a este tipo de artículo, por lo tanto no puedes borrar este tipo de artículo hasta que borres todos los artículos relacionados a este tipo de artículo'
			raiserror(@error, 16, 1)
			return
		end
		-- Eliminamos el registro
		delete from ControlEquipos.tblCatPropiedades where IDTipoArticulo = @IDTipoArticulo
		delete from ControlEquipos.tblCatTiposArticulos where IDTipoArticulo = @IDTipoArticulo
	end
end


/*
exec ControlEquipos.spBorrarCatTiposArticulos @IDTipoArticulo = 0

--select * from ControlEquipos.tblCatTipoArticulo
--select * from ControlEquipos.tblCatTiposArticulos
*/
GO

USE [p_adagioRHOwenSLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [ControlEquipos].[spBorrarCatPropiedades](
	@IDPropiedad int
)
as
begin
	if exists(select top 1 1 from ControlEquipos.tblCatPropiedades where IDPropiedad = @IDPropiedad)
	begin
		--eliminar registro
		delete from ControlEquipos.tblCatPropiedades where IDPropiedad = @IDPropiedad
	end
	--else
	--begin
	--	raiserror('El registro no existe', 16, 1)
	--	return
	--end
end

/*
select * from ControlEquipos.tblCatPropiedades
exec [ControlEquipos].[spBorrarCatPropiedades] @IDPropiedad = 0

*/
GO

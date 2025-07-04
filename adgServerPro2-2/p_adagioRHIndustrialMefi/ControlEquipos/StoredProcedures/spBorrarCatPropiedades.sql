USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [ControlEquipos].[spBorrarCatPropiedades](
	@IDPropiedad int,
	@ConfirmarEliminar bit = 0,
	@IDUsuario int
)
as
begin
	begin try
		declare @Mensaje varchar(max), @TotalValores int;

		if(((select count(*) from ControlEquipos.tblValoresPropiedades where IDPropiedad = @IDPropiedad) > 0) and @ConfirmarEliminar = 0)
		begin
			select @TotalValores = count(*) from ControlEquipos.tblValoresPropiedades where IDPropiedad = @IDPropiedad

			select 
			'Esta propiedad es usada  ' + cast(@TotalValores as varchar) + 
                CASE WHEN @TotalValores = 1 THEN ' una vez y se eliminará  ¿Desea continuar?'
                     ELSE ' veces y serán eliminados todos los registros ¿Desea continuar?' END AS Mensaje
			,1 as TipoRespuesta
            RETURN
		end
		else
		begin
			if exists(select top 1 1 from ControlEquipos.tblCatPropiedades where IDPropiedad = @IDPropiedad)
			begin
				delete from ControlEquipos.tblValoresPropiedades where IDPropiedad = @IDPropiedad
				delete from ControlEquipos.tblCatPropiedades where IDPropiedad = @IDPropiedad

				SELECT 'Propiedad eliminada correctamente.' as Mensaje
						,0 as TipoRespuesta
				RETURN;
			end
		end
	end try
	begin catch
		SELECT 'Ocurrio un error no controlado' as Mensaje
               ,-1 as TipoRespuesta
	end catch
	
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

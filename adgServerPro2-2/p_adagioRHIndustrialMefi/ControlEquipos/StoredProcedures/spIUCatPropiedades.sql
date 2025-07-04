USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [ControlEquipos].[spIUCatPropiedades](
	@IDPropiedad int = null
	,@IDInputType varchar(100)
	,@IDTipoArticulo int
	,@Traduccion varchar(max)
	,@Data varchar(max) = '""'
	,@Orden int
	,@IDUsuario int 
)
as
begin
	declare @IDIdioma varchar(20), @RecalcularOrden int = 0
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	begin try
		if ((@Orden is null) or (@Orden = 0))
		begin
		   select @Orden=isnull(Max(isnull(Orden,0))+1,1) from ControlEquipos.tblCatPropiedades where IDTipoArticulo = @IDTipoArticulo
		end else
		  set @RecalcularOrden = 1;
		
		if not exists(select top 1 1 from ControlEquipos.tblCatPropiedades where IDPropiedad = @IDPropiedad)
		begin
			begin tran Crear
				insert into ControlEquipos.tblCatPropiedades(IDInputType, IDTipoArticulo, Traduccion, [Data], Orden)
				values(@IDInputType, @IDTipoArticulo, @Traduccion, @Data, @Orden)

				if @@ROWCOUNT = 1
					commit tran Crear
				else
					rollback tran Crear
		end
		else
		begin
			begin tran Actualizar
				update ControlEquipos.tblCatPropiedades
				set
					Traduccion = @Traduccion,
					[Data]     = @Data,
					Orden      = @Orden
				where IDPropiedad = @IDPropiedad

				if @@ROWCOUNT = 1
					commit tran Actualizar
				else
					rollback tran Actualizar
		end
	end try
	begin catch
		ROLLBACK TRAN
		declare @error varchar(max) = ERROR_MESSAGE();
		raiserror(@error, 16,1);
	end catch
end


/**
exec [ControlEquipos].[spIUCatPropiedades]
	@IDPropiedad = 0
	,@IDInputType = 'Numero'
	,@TipoReferencia = 0
	,@IDReferencia = 2
	,@Traduccion = '{"esmx":{"Nombre":"asdfg"},"enus":{"Nombre":"asdfg"}}'
	,@Data = '""'
	,@Valor = null
	,@Activo = 1
	,@IDPropiedadOriginal = null
	,@IDUsuario = 1


exec [ControlEquipos].[spBuscarCatPropiedades] @IDReferencia = 1

*/
GO

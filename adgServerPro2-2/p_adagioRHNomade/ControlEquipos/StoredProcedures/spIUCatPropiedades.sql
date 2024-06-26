USE [p_adagioRHNomade]
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
	,@IDUsuario int = 1
)
as
begin
	declare @IDIdioma varchar(20)
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	begin try
		if not exists(select top 1 1 from ControlEquipos.tblCatPropiedades where IDPropiedad = @IDPropiedad)
		begin
			begin tran Crear
				insert into ControlEquipos.tblCatPropiedades(IDInputType, IDTipoArticulo, Traduccion, [Data])
				values(@IDInputType, @IDTipoArticulo, @Traduccion, @Data)

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
					[Data]     = @Data
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

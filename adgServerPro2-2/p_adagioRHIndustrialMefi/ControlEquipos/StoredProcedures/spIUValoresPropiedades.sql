USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [ControlEquipos].[spIUValoresPropiedades](
	@IDValorPropiedad int null,
	@IDPropiedad int,
	@IDDetalleArticulo int,
	@IDUsuario int,
	@Valor varchar(200)
)
as
begin
	declare @IDIdioma varchar(20)
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	begin try
		if not exists(select top 1 1 from ControlEquipos.tblValoresPropiedades where IDValorPropiedad = @IDValorPropiedad)
		begin
			begin tran Crear
				insert into ControlEquipos.tblValoresPropiedades(IDPropiedad, IDDetalleArticulo, valor)
				values(@IDPropiedad, @IDDetalleArticulo, @Valor)

				if @@ROWCOUNT = 1
					commit tran Crear
				else 
					rollback tran Crear
		end
		else
		begin
			begin tran Actualizar
				update ControlEquipos.tblValoresPropiedades
				set
					Valor = @Valor
				where IDValorPropiedad = @IDValorPropiedad

				if @@ROWCOUNT = 1
					commit tran Actualizar
				else
					rollback tran Actualizar
		end
	end try
	begin catch
	ROLLBACK TRAN
		declare @Error varchar(max) = ERROR_MESSAGE()
		raiserror(@Error, 16,1)
	end catch
end
GO

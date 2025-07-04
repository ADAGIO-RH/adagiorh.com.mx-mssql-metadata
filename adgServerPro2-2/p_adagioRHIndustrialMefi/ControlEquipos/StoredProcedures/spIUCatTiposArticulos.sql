USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [ControlEquipos].[spIUCatTiposArticulos](
	@IDTipoArticulo int = null
	,@IDUsuario int = 0
	,@Traduccion varchar(max)
	,@Codigo varchar(max)
	,@Etiquetar bit = 1
	,@PrefijoEtiqueta varchar(100)
	,@LongitudEtiqueta int
    ,@IDCatEstatusTipoArticulo int = 1
)
as
begin
	declare @IDIdioma varchar(20)
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	set @Etiquetar = case when @Etiquetar = 0 then 1 else @Etiquetar end

	begin try
		if exists(select top 1 1 from ControlEquipos.tblCatTiposArticulos where PrefijoEtiqueta = @PrefijoEtiqueta) and ISNULL(@IDTipoArticulo, 0) = 0
			begin
				declare @PrefijoRepetido varchar(max) = 'EL prefijo de etiqueta ' + @PrefijoEtiqueta + ' ya pertenece a otro tipo de artículo, ingresa un prefijo de etiqueta diferente.'
				raiserror(@PrefijoRepetido, 16,1)
				return
			end
		if exists(select top 1 1 from ControlEquipos.tblCatTiposArticulos where Codigo = @Codigo) and ISNULL(@IDTipoArticulo, 0) = 0
			begin
				declare @CodigoRepetido varchar(max) = 'EL código ' + @Codigo + ' ya pertenece a otro tipo de artículo, ingresa un código diferente.'
				raiserror(@CodigoRepetido, 16,1)
				return
			end
		if not exists(select top 1 1 from ControlEquipos.tblCatTiposArticulos where IDTipoArticulo = @IDTipoArticulo)
			begin
				begin tran Creando
					insert into ControlEquipos.tblCatTiposArticulos(Traduccion, Codigo, Etiquetar, PrefijoEtiqueta, LongitudEtiqueta,IDCatEstatusTipoArticulo)
					values(@Traduccion, UPPER(@Codigo), @Etiquetar, UPPER(@PrefijoEtiqueta), @LongitudEtiqueta, @IDCatEstatusTipoArticulo)

					if @@ROWCOUNT = 1
						commit tran Creando
					else
						rollback tran Creando
			end
		else
			begin
				begin tran Actualizando
					update ControlEquipos.tblCatTiposArticulos
					set
						Traduccion       = @Traduccion,
						Codigo           = UPPER(@Codigo),
						Etiquetar        = @Etiquetar,
						PrefijoEtiqueta  = UPPER(@PrefijoEtiqueta),
						LongitudEtiqueta = @LongitudEtiqueta,
                        IDCatEstatusTipoArticulo=@IDCatEstatusTipoArticulo
					where IDTipoArticulo = @IDTipoArticulo

					if @@ROWCOUNT = 1
						commit tran Actualizando
					else 
						rollback tran Actualizando
			end
	end try
	begin catch
		declare @Error varchar(max) = ERROR_MESSAGE()
		raiserror(@Error, 16,1)
	end catch
end

/*
select * from ControlEquipos.tblCatTiposArticulos

*/
GO

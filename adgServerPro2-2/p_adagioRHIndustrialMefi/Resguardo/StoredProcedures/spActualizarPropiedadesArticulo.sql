USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Resguardo].[spActualizarPropiedadesArticulo](
	@IDArticulo int,
	@IDUsuario int
) as
	declare  
		@IDTipoArticulo int 
	;

	select top 1 @IDTipoArticulo = IDTipoArticulo
	from Resguardo.tblArticulos
	where IDArticulo = @IDArticulo

	insert into [Resguardo].[tblCatPropiedadesArticulos](TipoReferencia,IDReferencia,IDTipoPropiedad,Nombre,CopiadaDelIDPropiedad)
	select 1 as TipoReferencia,@IDArticulo as IDReferencia,cta.IDTipoPropiedad,cta.Nombre,cta.IDPropiedad
	from [Resguardo].[tblCatPropiedadesArticulos] cta with (nolock)
		left join [Resguardo].[tblCatPropiedadesArticulos] ctaArticulo on ctaArticulo.TipoReferencia = 1 and ctaArticulo.IDReferencia = @IDArticulo
				and ctaArticulo.IDTipoPropiedad = cta.IDTipoPropiedad and ctaArticulo.Nombre = cta.Nombre
	where cta.TipoReferencia = 0 and cta.IDReferencia = @IDTipoArticulo and ctaArticulo.IDPropiedad is null
GO

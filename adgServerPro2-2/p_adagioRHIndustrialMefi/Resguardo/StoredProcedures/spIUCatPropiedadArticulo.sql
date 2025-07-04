USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [Resguardo].[spIUCatPropiedadArticulo](
	 @IDPropiedad int = 0
	,@IDTipoPropiedad int 
	,@Nombre varchar(100)
	,@TipoReferencia int 
	,@IDReferencia int
	,@Varios	varchar(max)
	,@IDUsuario int
) as

	declare 
		@NombreOriginal varchar(max)
	;

	select 
		@Nombre  = ltrim(rtrim(upper(@Nombre)))
		,@Varios = ltrim(rtrim(upper(@Varios)))

	if (@IDPropiedad = 0)
	begin
		insert [Resguardo].[tblCatPropiedadesArticulos](IDTipoPropiedad,Nombre,TipoReferencia,IDReferencia,Varios)
		values(@IDTipoPropiedad,@Nombre,@TipoReferencia,@IDReferencia,@Varios)

		set @IDPropiedad = @@IDENTITY
	end else
	begin
		/* Actualizar todas las propiedades de los artículos*/
		if (@TipoReferencia = 0)
		begin
			select 
				@NombreOriginal = Nombre
			from [Resguardo].[tblCatPropiedadesArticulos]
			where IDPropiedad = @IDPropiedad 

			update [Resguardo].[tblCatPropiedadesArticulos]
				set Nombre = @Nombre
			where TipoReferencia = 1 and Nombre = @NombreOriginal 
		end

		update [Resguardo].[tblCatPropiedadesArticulos]
			set 
				IDTipoPropiedad	= @IDTipoPropiedad 
				,Nombre			= @Nombre
				,TipoReferencia = @TipoReferencia
				,IDReferencia	= @IDReferencia
				,Varios			= @Varios
		where IDPropiedad = @IDPropiedad 
	end

	exec [Resguardo].[spBuscarCatPropiedadesArticulos] 
	 @IDPropiedad = @IDPropiedad
	,@IDUsuario	  = @IDUsuario
GO

USE [p_adagioRHEnimsa]
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

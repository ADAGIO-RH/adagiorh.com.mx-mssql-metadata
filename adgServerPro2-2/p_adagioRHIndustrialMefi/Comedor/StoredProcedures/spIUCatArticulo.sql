USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Comedor].[spIUCatArticulo](@IDArticulo					int = 0
									   ,@IDTipoArticulo				int
									   ,@Nombre						varchar(255)
									   ,@Descripcion				varchar(500)
									   ,@PrecioCosto				money
									   ,@PrecioEmpleado				money
									   ,@PrecioPublico				money
									   ,@HoraDisponibilidadInicio	time
									   ,@HoraDisponibilidadFin		time
									   ,@VentaIndividual			bit
									   ,@Disponible					bit
									   ,@dtOpcionesArticulo [Comedor].[dtOpcionesArticulos] readonly
									   ,@IdsRestaurantes			varchar(max)
									   ,@IDCategoria				int = 0
									   ,@IDUsuario					int
									)
as
	select 
		@Nombre = upper(@Nombre)
		,@Descripcion = upper(@Descripcion)
		,@IDCategoria = case when @IDCategoria = 0 then null else @IDCategoria end
	;

	if(isnull(@IDArticulo,0) = 0)
	begin
		insert into [Comedor].[tblCatArticulos](
			[IDTipoArticulo]
			,[Nombre]
			,[Descripcion]
			,[PrecioCosto]
			,[PrecioEmpleado]
			,[PrecioPublico]
			,[HoraDisponibilidadinicio]
			,[HoraDisponibilidadfin]
			,[VentaIndividual]
			,[Disponible]
			,[IdsRestaurantes]	
			,[IDCategoria]
		)
		select 
			@IDTipoArticulo
			,@Nombre
			,@Descripcion
			,@PrecioCosto
			,@PrecioEmpleado
			,@PrecioPublico
			,@HoraDisponibilidadInicio
			,@HoraDisponibilidadFin
			,@VentaIndividual
			,@Disponible
			,@IdsRestaurantes	
			,@IDCategoria
		;

		set @IDArticulo = @@Identity
	end
	else
	begin
		update [Comedor].[tblCatArticulos]
		set 
			[IDTipoArticulo]	= @IDTipoArticulo,
			[Nombre]			= @Nombre,
			[Descripcion]		= @Descripcion,
			[PrecioCosto]		= @PrecioCosto,
			[PrecioEmpleado]	= @PrecioEmpleado,
			[PrecioPublico]		= @PrecioPublico,
			[HoraDisponibilidadinicio]	= @HoraDisponibilidadInicio,
			[HoraDisponibilidadfin]		= @HoraDisponibilidadFin,
			[VentaIndividual]			= @VentaIndividual,
			[Disponible]				= @Disponible,
			[IdsRestaurantes]			= @IdsRestaurantes,
			[IDCategoria]				= @IDCategoria
		where 
			[IDArticulo] = @IDArticulo;
	end;

		MERGE [Comedor].[tblOpcionesArticulo] AS TARGET
		USING @dtOpcionesArticulo as SOURCE
		on TARGET.IDOpcionArticulo = SOURCE.IDOpcionArticulo
			and TARGET.[IDArticulo] = @IDArticulo
		WHEN MATCHED THEN
			update 
				set 
					TARGET.[Nombre] = SOURCE.[Nombre]
					,TARGET.[PrecioExtra] = SOURCE.[PrecioExtra]
					,TARGET.[Disponible] = SOURCE.[Disponible]
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDOpcionArticulo, IDArticulo, Nombre, PrecioExtra, Disponible)
			values(SOURCE.IDOpcionArticulo,@IDArticulo,SOURCE.Nombre, SOURCE.PrecioExtra, SOURCE.Disponible)
		WHEN NOT MATCHED BY SOURCE and TARGET.[IDArticulo] = @IDArticulo THEN 
		DELETE;

		select @IDArticulo as IDArticulo
GO

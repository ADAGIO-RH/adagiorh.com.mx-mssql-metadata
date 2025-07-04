USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Comedor].[spIUCatMenu](
	@IDMenu						int = 0
	,@IDTipoMenu                int
	,@Nombre                    varchar(255)
	,@Descripcion               varchar(500)
	,@PrecioCosto               money
	,@PrecioEmpleado            money
	,@PrecioPublico             money
	,@DisponibilidadPorFecha    bit
	,@FechaDisponibilidadInicio date
	,@FechaDisponibilidadFin    date
	,@Disponible                bit
	,@MenuDelDia				bit	 = 0
	,@HistorialDisponibilidad	bit  = 0
	,@dtDetalleMenu [Comedor].[dtDetalleMenu] readonly
	,@IDUsuario                 int
	,@IdsRestaurantes varchar(max)
)
as
	select 
		@Nombre = upper(@Nombre)
		,@Descripcion = upper(@Descripcion);

	if(isnull(@IDMenu,0) = 0)
	begin
		insert into [Comedor].[tblCatMenus](
			[IDTipoMenu]
			,[Nombre]
			,[Descripcion]
			,[Preciocosto]
			,[Precioempleado]
			,[Preciopublico]
			,[DisponibilidadPorFecha]
			,[FechaDisponibilidadInicio]
			,[FechaDisponibilidadFin]
			,[Disponible]
			,MenuDelDia				
			,HistorialDisponibilidad	
			,[IdsRestaurantes]	
		)
		select 
			@IDTipoMenu
			,@Nombre
			,@Descripcion
			,@PrecioCosto
			,@PrecioEmpleado
			,@PrecioPublico
			,@DisponibilidadPorFecha
			,@FechaDisponibilidadInicio
			,@FechaDisponibilidadFin
			,@Disponible
			,@MenuDelDia				
			,@HistorialDisponibilidad	
			,@IdsRestaurantes	
		;
	set @IDMenu = @@Identity
	end;
	else
	begin
		update [Comedor].[tblCatMenus]
		set 
			[IDTipoMenu]	= @IDTipoMenu,
			[Nombre]		= @Nombre,
			[Descripcion]	= @Descripcion,
			[PrecioCosto]	= @PrecioCosto,
			[PrecioEmpleado]= @PrecioEmpleado,
			[PrecioPublico] = @PrecioPublico,
			[DisponibilidadPorFecha]	= @DisponibilidadPorFecha,
			[FechaDisponibilidadInicio] = @FechaDisponibilidadInicio,
			[FechaDisponibilidadFin]	= @FechaDisponibilidadFin,
			[Disponible]				= @Disponible,
			MenuDelDia					= @MenuDelDia,				
			HistorialDisponibilidad		= @HistorialDisponibilidad,	
			[IdsRestaurantes]			= @IdsRestaurantes
		where 
			[IDMenu] = @IDMenu;
	end;

	MERGE [Comedor].[tblDetalleMenu] AS TARGET
	USING @dtDetalleMenu as SOURCE
	on TARGET.IDDetalleMenu = SOURCE.IDDetalleMenu
		and TARGET.IDMenu = @IDMenu
	WHEN MATCHED THEN
		update 
			set 
				TARGET.Cantidad = SOURCE.Cantidad
				,TARGET.PrecioExtra = SOURCE.PrecioExtra
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT(IDMenu,IDArticulo,Cantidad,PrecioExtra)
		values(@IDMenu,SOURCE.IDArticulo,SOURCE.Cantidad, SOURCE.PrecioExtra)
	WHEN NOT MATCHED BY SOURCE and TARGET.[IDMenu] = @IDMenu THEN 
	DELETE;

	select @IDMenu as IDMenu
GO

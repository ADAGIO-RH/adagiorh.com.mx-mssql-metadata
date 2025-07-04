USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2024-02-21			Justin Davila		Correccion de relacion de tablas para IDGenero de
										ControlEquipos.tblArticulos a ControlEquipos.tblDetalleArticulos
										Join con RH.tblCatGeneros para descripcion del genero
2024-03-27			Justin Davila		Replicacion de registros con el campo Cantidad > 1
2024-04-01			Justin Davila		Correccion de registros que se replicaban mas veces de las requeridas
2024-04-03			Justin Davila		Correccion de articulos asignados replicados
2024-04-29			Justin Davila		Agregamos campo IDContratoEmpleado cara corregir bug
***************************************************************************************************/
CREATE   proc [ControlEquipos].[spBuscarDetallesPorPuestoIDEmpleado](
	@IDEmpleado int,
	@IDUsuario int
)
as
begin
	declare @IDPuesto int, @IDIdioma varchar(20), @PageSize int = 2147483647, @PageNumber int = 1, @Cantidad INT, @Counter INT, @i int;
	SELECT @IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	select @IDPuesto = IDPuesto from RH.tblEmpleadosMaster where IDEmpleado = @IDEmpleado
	--set @IDPuesto = 452
	--select @IDPuesto

	if object_id('tempdb..#tempArticulosPorPuesto') is not null drop table #tempArticulosPorPuesto;
	if object_id('tempdb..#tempDetallesAsignadosAColaborador') is not null drop table #tempDetallesAsignadosAColaborador;

	declare @tblArticulosPorPuesto table(
		IDArticulosPorPuesto int,
		IDPuesto int,
		Puesto varchar(500),
		IDTipoArticulo int,
		TipoArticulo varchar(500),
		IDArticulo int,
		Articulo varchar(200),
		Cantidad int,
		DescripcionArticulo VARCHAR(MAX),
		FechaHora datetime
	);
	declare @tblDetallesAsignadosAColaborador table(
		IDArticulo int,
		IDTipoArticulo int,
		IDDetalleArticulo int,
		TipoArticulo varchar(500),
		Etiqueta varchar(20),
		Nombre varchar(200),
		Descripcion varchar(max),
		Costo decimal(10,2),
		IDEstatusArticulo int,
		IDCatEstatusArticulo int,
		IDContratoEmpleado int,
		Estatus varchar(100),
		Empleados varchar(max),
		FechaHora dateTime,
		TieneCaducidad bit,
		UsoCompartido bit,
		IDGenero varchar(3),
		Genero varchar(15),
		Propiedades varchar(max),
		TotalPaginas int,
		TotalRegistros int
	)

	insert into @tblArticulosPorPuesto(IDArticulosPorPuesto, IDPuesto, Puesto, IDTipoArticulo, TipoArticulo, IDArticulo, Articulo, Cantidad, DescripcionArticulo, FechaHora)
	exec ControlEquipos.spBuscarArticulosPorPuesto
		@IDArticulosPorPuesto = 0,
		@IDPuesto = @IDPuesto,
		@IDUsuario = @IDUsuario

	select @i = min(IDArticulosPorPuesto) from @tblArticulosPorPuesto
	while exists(select top 1 1 from @tblArticulosPorPuesto where IDArticulosPorPuesto >= @i)
	begin
		select @Cantidad = Cantidad from @tblArticulosPorPuesto where IDArticulosPorPuesto = @i
		select @Counter = COUNT(IDArticulosPorPuesto) from @tblArticulosPorPuesto where IDArticulosPorPuesto = @i
		--select @Cantidad as Cantidad, @Counter as Counter

		while @Counter < @Cantidad
		begin
			insert into @tblArticulosPorPuesto(IDArticulosPorPuesto,IDPuesto ,Puesto,IDTipoArticulo,TipoArticulo,IDArticulo,Articulo,Cantidad,DescripcionArticulo,FechaHora)
			select top 1 IDArticulosPorPuesto,IDPuesto ,Puesto,IDTipoArticulo,TipoArticulo,IDArticulo,Articulo,Cantidad,DescripcionArticulo,FechaHora from @tblArticulosPorPuesto where IDArticulosPorPuesto = @i
			set @Counter = @Counter + 1
		end
		select @i = min(IDArticulosPorPuesto) from @tblArticulosPorPuesto where IDArticulosPorPuesto > @i
	end

	insert into @tblDetallesAsignadosAColaborador(IDArticulo, IDTipoArticulo, IDDetalleArticulo, TipoArticulo, Etiqueta, Nombre, Descripcion, Costo, IDEstatusArticulo, IDCatEstatusArticulo, IDContratoEmpleado, Estatus, Empleados, FechaHora, TieneCaducidad, UsoCompartido, IDGenero, Genero, Propiedades, TotalPaginas, TotalRegistros)
	exec [ControlEquipos].[spBuscarDetallesArticulosByIDEmpleado]
		@IDEmpleado = @IDEmpleado 
		, @IDUsuario = @IDUsuario 	
		, @PageNumber = @PageNumber
		, @PageSize = @PageSize

	select *,
			ROW_NUMBER() over(partition by IDArticulo order by IDArticulosPorPuesto) as RN
	into #tempArticulosPorPuesto
	from @tblArticulosPorPuesto
	
	select *,
			ROW_NUMBER() over(partition by IDArticulo order by IDArticulo) as RN
	into #tempDetallesAsignadosAColaborador
	from @tblDetallesAsignadosAColaborador

	--select * from #tempArticulosPorPuesto
	--select * from #tempDetallesAsignadosAColaborador
	--return

	select 
		app.IDArticulosPorPuesto,
		ISNULL(IDPuesto,0) as IDPuesto,
		Puesto,
		app.IDArticulo,
		a.IDTipoArticulo,
		ISNULL(colaborador.IDDetalleArticulo, 0) as IDDetalleArticulo,
		UPPER(JSON_VALUE(ta.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre'))) as TipoArticulo,
		ISNULL(colaborador.Etiqueta, ta.PrefijoEtiqueta + 'XXXX') as Etiqueta,
		a.Nombre,
		ISNULL(a.Descripcion, '') as Descripcion,
		ISNULL(colaborador.IDEstatusArticulo, 0) as IDEstatusArticulo,
		ISNULL(IDCatEstatusArticulo, 0) as IDCatEstatusArticulo,
		ISNULL(Estatus, '') as Estatus,
		ISNULL(Empleados, '[]') as Empleados,
		ISNULL(app.FechaHora, getdate()) as FechaHora,
		ISNULL(a.UsoCompartido, 0) as UsoCompartido,
		ISNULL(CAST(colaborador.IDGenero as varchar(3)), 'N/A') as IDGenero,
		ISNULL(JSON_VALUE(cg.Traduccion, FORMATMESSAGE('$.%s.%s', '' + lower(replace(@IDIdioma, '-','')) + '', 'Descripcion')), 'N/A') as Genero,
		ISNULL(
			Propiedades, 
			(
				select 
	   				JSON_VALUE(cp.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Nombre')) AS [NombrePropiedad],
	   				CASE
	   				WHEN ISJSON(cp.[Data]) = 1 THEN
	   					(
	   						SELECT JSON_VALUE(item.Value, '$.Nombre') 
	   						FROM OPENJSON(cp.[Data]) AS item
	   						WHERE JSON_VALUE(item.Value, '$.ID') = vp.Valor
	   					)
	   				ELSE
	   					ISNULL(vp.Valor,'') -- o cualquier otro valor por defecto que desees cuando [Data] no sea un JSON válido
	   				END AS [ValorPropiedad]
	   			from [ControlEquipos].[tblCatPropiedades] cp
	   				left join [ControlEquipos].[tblValoresPropiedades] vp on vp.IDPropiedad = cp.IDPropiedad and vp.IDDetalleArticulo = da.IDDetalleArticulo
	   			where cp.IDTipoArticulo = app.IDTipoArticulo
	   			for json auto
			)
		) as Propiedades
	FROM #tempArticulosPorPuesto app
		join ControlEquipos.tblArticulos a on a.IDArticulo = app.IDArticulo
		join ControlEquipos.tblCatTiposArticulos ta on ta.IDTipoArticulo = a.IDTipoArticulo
		left join #tempDetallesAsignadosAColaborador colaborador on colaborador.IDArticulo = app.IDArticulo and colaborador.RN = app.RN
		left join ControlEquipos.tblDetalleArticulos da on da.IDDetalleArticulo = colaborador.IDDetalleArticulo
		left join RH.tblCatGeneros cg on cg.IDGenero = da.IDGenero
	order by colaborador.IDArticulo desc
end
GO

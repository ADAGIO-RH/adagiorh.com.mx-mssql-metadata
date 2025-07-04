USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Actualiza un detalle de artículo y sus propiedades
** Autor			: ISAAC JUSTIN DAVILA SAPIENS
** Email			: jdavila@adagio.com.mx
** FechaCreacion	: Fecha
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2024-02-09			ANEUDY ABREU		Cambia update de propiedades por un MERGE para que las nuevos propiedades
										se puedan insertar
2024-02-20			Justin Davila		Agregamos el update del IDGenero a la tabla ControlEquipos.tblDetalleArticulos
2024-03-07			Justin Davila		Agregamos el campo Costo en la tabla ControlEquipos.tblDetalleArticulos y al 
										data table[ControlEquipos].[dtDetalleArticulos]
2024-03-11			Justin Davila		Correccion del @tempMerge para actualizar los Detalles correspondientes en el
										segundo merge, agregamos campo IDDetalleArticulo al dtIDsEstatusArticulo
2024-03-14			Justin Davila		Correccion de actualizacion de propiedades de manera masiva y un solo articulo
2024-03-21			Justin Davila		Agregamos los campos IDUnidadDeTiempo, IDCatTipoCaducidad y Tiempo
2024-05-16			Justin Davila		Agregamos validacion de IDCatEstatusArticulo para no actualizar el campo Empleados
										que tengan colaboradores dentro
2024-06-10			Justin Davila		Validamos campos de IDCatTipoCaducidad e IDUnidadDeTiempo para evitar error en merge
***************************************************************************************************/
CREATE  proc [ControlEquipos].[spUDetalleArticulos](	
	@IDUsuario int 
	,@IDCatEstatusArticulo int
	,@dtDetalleArticulos [ControlEquipos].[dtDetalleArticulos] readonly
	,@dtIDsEstatusArticulo [ControlEquipos].[dtIDsEstatusArticulo] readonly
)
as	
begin
	declare @IDIdioma varchar(20), @jsonPropiedaes nvarchar(max), @IDEstatusArticulo int, @i int, @Empleados varchar(max);
	declare @ID_CAT_ESTATUS_ARTICULO_ASIGNADO INT = 2, @ID_CAT_ESTATUS_ARTICULO_DEVUELTO int = 6
	declare @tempMerge as table(
		IDDetalleArticulo int NULL,
		IDArticulo int NULL,
		Etiqueta varchar(12) NULL,
		FechaCaducidad date NULL,
		FechaAlta date NULL,
		IDGenero char(1) null,
		Costo decimal(10, 2) null,
		JsonPropiedades nvarchar(max) NULL,
		IDUnidadDeTiempo int,
		IDCatTipoCaducidad int,
		Tiempo int,
		IDEstatusArticulo int
	)
	declare @dtPropiedades as table(
            IDValorPropiedad int, 
            IDPropiedad int , 
            Valor varchar(max),
            IDDetalleArticulo int 
                
        )
	;
	SELECT @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	if object_id('tempdb..#tempValoresPropiedades') is not null drop table #tempValoresPropiedades;
	SELECT @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx') 

	MERGE INTO @tempMerge AS target
	USING (SELECT * FROM @dtDetalleArticulos) AS source
		ON target.IDDetalleArticulo = source.IDDetalleArticulo
	WHEN MATCHED THEN
		UPDATE SET
			target.IDArticulo = source.IDArticulo,
			target.Etiqueta = source.Etiqueta,
			--target.FechaCaducidad = source.FechaCaducidad,
			target.FechaAlta = source.FechaAlta,
			target.IDGenero = source.IDGenero,
			target.Costo = source.Costo,
			target.JsonPropiedades = source.JsonPropiedades,
			target.IDUnidadDeTiempo = source.IDUnidadDeTiempo,
			target.IDCatTipoCaducidad = source.IDCatTipoCaducidad,
			target.Tiempo = source.Tiempo
	WHEN NOT MATCHED THEN
		INSERT (
			IDDetalleArticulo,
			IDArticulo,
			Etiqueta,
			--FechaCaducidad,
			FechaAlta,
			IDGenero,
			Costo,
			JsonPropiedades,
			IDUnidadDeTiempo,
			IDCatTipoCaducidad,
			Tiempo
		)
		VALUES (
			source.IDDetalleArticulo,
			source.IDArticulo,
			source.Etiqueta,
			--source.FechaCaducidad,
			source.FechaAlta,
			source.IDGenero,
			source.Costo,
			source.JsonPropiedades,
			source.IDUnidadDeTiempo,
			source.IDCatTipoCaducidad,
			source.Tiempo
		);
		--select * from @tempMerge
		--return

	MERGE INTO @tempMerge AS target
	USING (SELECT * FROM @dtIDsEstatusArticulo) AS source
	ON target.IDDetalleArticulo = source.IDDetalleArticulo
	WHEN NOT MATCHED THEN
		INSERT (IDEstatusArticulo)
		VALUES (source.IDEstatusArticulo)
	WHEN MATCHED THEN
		UPDATE SET
			TARGET.IDEstatusArticulo = source.IDEstatusArticulo
	;

	update @tempMerge
		set IDUnidadDeTiempo = null
	where IDUnidadDeTiempo = 0
	update @tempMerge
		set IDCatTipoCaducidad = null
	where IDCatTipoCaducidad = 0
	--select * from @tempMerge

	--select * from @tempMerge
	
    select @i = min(IDDetalleArticulo) from @tempMerge


    WHILE exists(select top 1 1 from @tempMerge where IDDetalleArticulo >= @i)
    BEGIN
        select @jsonPropiedaes = JsonPropiedades from @tempMerge where IDDetalleArticulo=@i
            
        insert into @dtPropiedades (IDValorPropiedad,IDPropiedad,Valor,IDDetalleArticulo)
        select 
            IDValorPropiedad, 
            IDPropiedad, 
            Valor, 
            @i
        from OPENJSON(@jsonPropiedaes)
            WITH  (
                IDValorPropiedad int N'$.IDValorPropiedad',
                IDPropiedad int N'$.IDPropiedad',
                Valor varchar(max) N'$.Valor',
                IDDetalleArticulo int N'$.IDDetalleArticulo'			
            ) info        
        
        --select * from @dtPropiedades
		--return

		select @IDEstatusArticulo = IDEstatusArticulo from @tempMerge where IDDetalleArticulo = @i

		merge ControlEquipos.tblDetalleArticulos as target
		using @tempMerge as source
		on target.IDDetalleArticulo = @i and
			target.IDDetalleArticulo = source.IDDetalleArticulo
		when matched then
			update
				set target.IDGenero = source.IDGenero,
				target.Costo = source.Costo,
				target.IDUnidadDeTiempo = source.IDUnidadDeTiempo,
				target.IDCatTipoCaducidad = source.IDCatTipoCaducidad,
				target.Tiempo = source.Tiempo
		;

		MERGE ControlEquipos.tblValoresPropiedades AS TARGET
		USING @dtPropiedades as SOURCE
			on 
				TARGET.IDPropiedad = SOURCE.IDPropiedad and
				TARGET.IDDetalleArticulo = SOURCE.IDDetalleArticulo 
		WHEN MATCHED THEN
			update
				set TARGET.Valor = SOURCE.Valor
		WHEN NOT MATCHED BY TARGET THEN
			INSERT(IDPropiedad, Valor,IDDetalleArticulo)
			values(SOURCE.IDPropiedad, SOURCE.Valor,SOURCE.IDDetalleArticulo)
		;

		select IDValorPropiedad,
			   ROW_NUMBER() over(partition by IDPropiedad, IDDetalleArticulo order by IDDetalleArticulo) as RN
		into #tempValoresPropiedades
		from ControlEquipos.tblValoresPropiedades where IDDetalleArticulo = @i

		delete from ControlEquipos.tblValoresPropiedades where IDValorPropiedad in (select IDValorPropiedad from #tempValoresPropiedades where RN > 1)

		if @IDCatEstatusArticulo <> @ID_CAT_ESTATUS_ARTICULO_ASIGNADO and @IDCatEstatusArticulo <> @ID_CAT_ESTATUS_ARTICULO_DEVUELTO
		begin
			EXEC [ControlEquipos].[spIUEstatusArticulos]
				@IDUsuario = @IDUsuario,
				@IDCatEstatusArticulo = @IDCatEstatusArticulo,
				@IDEstatusArticulo = @IDEstatusArticulo,
				@IDDetalleArticulo = @i,	
				@IDsEmpleados = '[]'
		end
		else
		begin
			select @Empleados = Empleados from ControlEquipos.tblEstatusArticulos where IDEstatusArticulo = @IDEstatusArticulo
			EXEC [ControlEquipos].[spIUEstatusArticulos]
				@IDUsuario = @IDUsuario,
				@IDCatEstatusArticulo = @IDCatEstatusArticulo,
				@IDEstatusArticulo = @IDEstatusArticulo,
				@IDDetalleArticulo = @i,	
				@IDsEmpleados = @Empleados
		end
		
		delete from @dtPropiedades
		drop table #tempValoresPropiedades
        select @i = min(IDDetalleArticulo) from @tempMerge where IDDetalleArticulo > @i
    END;

end
GO

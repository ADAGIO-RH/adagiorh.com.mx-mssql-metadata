USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [ControlEquipos].[spIEstatusArticulos](
	@IDUsuario int,
	@IDCatEstatusArticulo int,	
	@JsonDetalleArticulos varchar(max),
	@IDEmpleado int,
	@Notas varchar(500)
)
as
begin
	declare @IDIdioma varchar(20) = App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	, @ID_CAT_ESTATUS_ARTICULOS_ASIGNADO int = 2	
     ,@ID_CAT_ESTATUS_ARTICULOS_DEVUELTO int = 6
	 ,@tempIDCatEstatusArticulo int
	 ,@tempIDEstatusArticulo int
	 ,@length int
	 ,@JSON varchar(max)	
	 ,@EmpleadosActualesJSON varchar(max)
	 ,@articulosNombre varchar(max)
     ,@message VARCHAR(max)
	 ,@EmpleadoADesasignar varchar(max)
	 ;	

    declare @estatusArticulos as table (                
        Empleados varchar(max),         
        FechaHora datetime,
        IDDetalleArticulo int,
		IDCatEstatusArticulo int     
    );
        
    insert into @estatusArticulos(Empleados, FechaHora, IDDetalleArticulo, IDCatEstatusArticulo)
	select 
		 Empleados
		,FechaHora
		,IDDetalleArticulo
		,IDCatEstatusArticulo 
	from (
		 select 
			e.Empleados
			,e.FechaHora
			,da.IDDetalleArticulo
			,e.IDCatEstatusArticulo 
			,ROW_NUMBER() OVER (PARTITION BY da.IDDetalleArticulo ORDER BY FechaHora desc) AS RowNum
		from OpenJSON(@JsonDetalleArticulos)  WITH (  IDDetalleArticulo int )  da
			inner join ControlEquipos.tblDetalleArticulos dta on dta.IDDetalleArticulo=da.IDDetalleArticulo
			inner join ControlEquipos.tblEstatusArticulos e on e.IDDetalleArticulo=da.IDDetalleArticulo
	) info
	where info.RowNum = 1

	select top 1
		@EmpleadosActualesJSON = Empleados,
		@tempIDCatEstatusArticulo = IDCatEstatusArticulo
	from @estatusArticulos

	if (
		@IDCatEstatusArticulo = @ID_CAT_ESTATUS_ARTICULOS_ASIGNADO 
		and
		EXISTS (
			SELECT *
			FROM OPENJSON(@EmpleadosActualesJSON) with(
				IDEmpleado int
			)
			WHERE IDEmpleado = @IDEmpleado
		) 
		and @tempIDCatEstatusArticulo = @ID_CAT_ESTATUS_ARTICULOS_ASIGNADO
	)
	begin
		select @articulosNombre=string_agg(dta.Etiqueta,', ') from @estatusArticulos ea
        inner join ControlEquipos.tblDetalleArticulos   dta on dta.IDDetalleArticulo=ea.IDDetalleArticulo
        INNER JOIN ControlEquipos.tblArticulos A ON A.IDArticulo = dta.IDArticulo;
        set @message= CONCAT('Los articulos (',@articulosNombre,') ya estan asignados a este colaborador');
        RAISERROR(@message  ,16,1);
        return ;
	end
	
 --   select *, @IDEmpleado from @estatusArticulos
	--return
    IF @IDCatEstatusArticulo in (@ID_CAT_ESTATUS_ARTICULOS_DEVUELTO )
    begin
        --select 'AQUI SE QUITA EL EMPLEADO QUE ANTERIORMENTE ESTABA ASIGNADO'
		select @EmpleadoADesasignar = ISNULL(
			CASE
				WHEN EXISTS (
					SELECT 1 
					FROM OPENJSON(Empleados) 
					WHERE JSON_VALUE(value, '$.IDEmpleado') = CAST(@IDEmpleado AS VARCHAR(MAX))
				) 
				THEN 
					(
						select *
						from (
							SELECT *
							FROM OPENJSON(Empleados) with(
								IDEmpleado int
							)
							WHERE IDEmpleado = @IDEmpleado
						) info
						FOR JSON AUTO
					)
				ELSE Empleados
			END,'[]')
		from @estatusArticulos
		UPDATE @estatusArticulos
			SET Empleados = ISNULL(
				CASE
					WHEN EXISTS (
						SELECT 1 
						FROM OPENJSON(Empleados) 
						WHERE JSON_VALUE(value, '$.IDEmpleado') = CAST(@IDEmpleado AS VARCHAR(MAX))
					) 
					THEN 
					-- TODO: Probar con varios colaboradores
						(
							select *
							from (
								SELECT *
								FROM OPENJSON(Empleados) with(
									IDEmpleado int
								)
								WHERE IDEmpleado != @IDEmpleado
							) info
							FOR JSON AUTO
						)
						--'[' + 
						--STUFF((
						--	SELECT ',' + value
						--	FROM OPENJSON(Empleados)
						--	WHERE JSON_VALUE(value, '$.IDEmpleado') != CAST(@IDEmpleado AS VARCHAR(MAX))
						--	FOR XML PATH('')
						--), 1, 1, '') +
						--']'
					ELSE Empleados
				END,'[]')--,
						--PuedeModificar=1;
    end else
	IF @IDCatEstatusArticulo in (@ID_CAT_ESTATUS_ARTICULOS_ASIGNADO )
    BEGIN   
		--select 'Aqui se asignan los articulos'
        UPDATE @estatusArticulos
			SET Empleados = 
				CASE
					WHEN NOT EXISTS (
						SELECT 1 
						FROM OPENJSON(Empleados) 
						WHERE JSON_VALUE(value, '$.IDEmpleado') = CAST(@IDEmpleado AS VARCHAR(MAX))
					) 
					THEN JSON_MODIFY(Empleados, 'append $', JSON_QUERY('{"IDEmpleado":' + CAST(@IDEmpleado AS VARCHAR(MAX)) + '}'))
					ELSE Empleados
				END
				--PuedeModificar=CASE
				--	WHEN EXISTS (SELECT 1 FROM OPENJSON(Empleados) WHERE JSON_VALUE(value, '$.IDEmpleado') = CAST(@IDEmpleado AS VARCHAR(MAX))) THEN 
				--		case when IDCatEstatusArticulo in (@ID_CAT_ESTATUS_ARTICULOS_DEVUELTO)--EXISTS (SELECT 1 FROM OPENJSON(Empleados) WHERE JSON_VALUE(value, '$.IDEmpleado') = CAST(@IDEmpleado AS VARCHAR(MAX)))
				--		then 1
				--		else 0
				--		end
				--	WHEN not EXISTS (SELECT 1 FROM OPENJSON(Empleados) WHERE JSON_VALUE(value, '$.IDEmpleado') = CAST(@IDEmpleado AS VARCHAR(MAX))) THEN 1
				--	ELSE 0
				--END
		END
	--if exists(select top 1 1 from @estatusArticulos where IDCatEstatusArticulo <> @ID_CAT_ESTATUS_ARTICULOS_DEVUELTO)
	--	update @estatusArticulos set PuedeModificar = 1
	--select * from @estatusArticulos
	--return
    --IF exists(select top 1 1 from @estatusArticulos where PuedeModificar = 0)
    --BEGIN
        
    --    select @articulosNombre=string_agg(Nombre,',') from @estatusArticulos ea
    --    inner join ControlEquipos.tblDetalleArticulos   dta on dta.IDDetalleArticulo=ea.IDDetalleArticulo
    --    INNER JOIN ControlEquipos.tblArticulos A ON A.IDArticulo = dta.IDArticulo;
    --    set @message= CONCAT('Los articulos (',@articulosNombre,') ya estan asignados a este colaborador');
    --    RAISERROR(@message  ,16,1);
    --    return ;
    --end


	select top 1 
		@tempIDCatEstatusArticulo = IDCatEstatusArticulo, 
		@tempIDEstatusArticulo = IDEstatusArticulo, 
		@JSON = Empleados 
	from ControlEquipos.tblEstatusArticulos 
	where IDDetalleArticulo in (select IDDetalleArticulo from @estatusArticulos) 
	order by IDEstatusArticulo desc
	
	--select top 1 
	--	IDCatEstatusArticulo, 
	--	IDEstatusArticulo, 
	--	Empleados 
	--from ControlEquipos.tblEstatusArticulos 
	--where IDDetalleArticulo in (select IDDetalleArticulo from @estatusArticulos) 
	--order by IDEstatusArticulo desc

	set @length = (SELECT COUNT(*) FROM OPENJSON(@JSON))

	--select @EmpleadoADesasignar
	--select @length
	--return

	if(@length > 1 and @IDCatEstatusArticulo = @ID_CAT_ESTATUS_ARTICULOS_DEVUELTO)
	begin
		--update ControlEquipos.tblEstatusArticulos
		--set IDCatEstatusArticulo = @ID_CAT_ESTATUS_ARTICULOS_DEVUELTO
		--where IDEstatusArticulo = @tempIDEstatusArticulo

		INSERT INTO ControlEquipos.tblEstatusArticulos (IDCatEstatusArticulo,FechaHora,Empleados,IDUsuario,IDDetalleArticulo, Notas)    
		select @ID_CAT_ESTATUS_ARTICULOS_DEVUELTO,GETDATE(),@EmpleadoADesasignar,@IDUsuario,IDDetalleArticulo, @Notas  from @estatusArticulos

		INSERT INTO ControlEquipos.tblEstatusArticulos (IDCatEstatusArticulo,FechaHora,Empleados,IDUsuario,IDDetalleArticulo)    
		select @ID_CAT_ESTATUS_ARTICULOS_ASIGNADO,GETDATE(),Empleados,@IDUsuario,IDDetalleArticulo  from @estatusArticulos
	end
	else if @IDCatEstatusArticulo = @ID_CAT_ESTATUS_ARTICULOS_DEVUELTO
	begin
		INSERT INTO ControlEquipos.tblEstatusArticulos (IDCatEstatusArticulo,FechaHora,Empleados,IDUsuario,IDDetalleArticulo, Notas)    
		select @IDCatEstatusArticulo,GETDATE(),@EmpleadoADesasignar,@IDUsuario,IDDetalleArticulo, @Notas  from @estatusArticulos
	end
	else
	begin
		INSERT INTO ControlEquipos.tblEstatusArticulos (IDCatEstatusArticulo,FechaHora,Empleados,IDUsuario,IDDetalleArticulo, Notas)    
		select @IDCatEstatusArticulo,GETDATE(),Empleados,@IDUsuario,IDDetalleArticulo, @Notas  from @estatusArticulos
	end

    DECLARE @i int 
    select  @i=min(IDDetalleArticulo) from @estatusArticulos;

    WHILE exists(select top 1 1  from @estatusArticulos where IDDetalleArticulo >= @i)
    BEGIN                        
        
        declare @IDArticulo int;

        select @IDArticulo= da.IDArticulo  from ControlEquipos.tblDetalleArticulos da            
        where da.IDDetalleArticulo=@i;

        exec ControlEquipos.spActualizarInventarios
            @IDUsuario = @IDUsuario
            ,@IDArticulo = @IDArticulo
        select @i = min(IDDetalleArticulo) from @estatusArticulos where IDDetalleArticulo > @i
    END;
        		
end
GO

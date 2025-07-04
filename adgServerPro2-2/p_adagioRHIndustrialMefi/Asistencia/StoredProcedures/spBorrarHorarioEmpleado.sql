USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spBorrarHorarioEmpleado](
     @IDEmpleado int 
    ,@FechaIni date
    ,@FechaFin date
    ,@IDUsuario int 
    ,@ConfirmadoEliminar   bit  = 0
) as

    declare @total int = 0
		,@Fechas [App].[dtFechas] 
		,@CALENDARIO0002 bit = 0 --No Modificar calendario de días anteriores(Permite modificar el día actual)'
		,@CALENDARIO0003 bit = 0 --No Modificar calendraio de mañana en adelante')
		,@DIAS_MODIFICAR_CALENDARIO int = 0 -- Cantidad de días previos para modificar Calendario
		,@DIAS_MODIFICAR_CALENDARIO_DIAS int = 0
		,@DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA date
	;

	BEGIN -- Permisos de calendario
		if exists(select top 1 1 
			from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'CALENDARIO0002')
		begin
			set @CALENDARIO0002 = 1
		end;

		if exists(select top 1 1 
			from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'CALENDARIO0003')
		begin
			set @CALENDARIO0003 = 1
		end;

		if exists(select top 1 1 
			from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'DIAS_MODIFICAR_CALENDARIO')
		begin
			set @DIAS_MODIFICAR_CALENDARIO = 1

			select @DIAS_MODIFICAR_CALENDARIO_DIAS = CAST(isnull(cpe.[Data], 0) as int)
			from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'DIAS_MODIFICAR_CALENDARIO'
		end;
	END

	if (@DIAS_MODIFICAR_CALENDARIO = 1)
	begin
		set @DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA = DATEADD(DAY, @DIAS_MODIFICAR_CALENDARIO_DIAS * -1, GETDATE())

		if (@FechaIni < @DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA)
		begin
			select 0 as ID
				,FORMATMESSAGE('No tienes permiso para eliminar horarios mayores a %d dias previos.', @DIAS_MODIFICAR_CALENDARIO_DIAS) as Mensaje
				,-1 as TipoRespuesta
			return;
		end
	end

	insert into @Fechas(Fecha)
    SELECT d
    FROM
    (
	 SELECT d = DATEADD(DAY, rn - 1, @FechaIni)
	 FROM 
	 (
	   SELECT TOP (DATEDIFF(DAY, @FechaIni, @FechaFin) +1) 
		rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
	   FROM sys.all_objects AS s1
	   CROSS JOIN sys.all_objects AS s2
	   -- on my system this would support > 5 million days
	   ORDER BY s1.[object_id]
	 ) AS x
    ) AS y;

	DELETE from @Fechas
	where (Fecha < case when @CALENDARIO0002 = 1 then cast(GETDATE() as date) else '1900-01-01' end)
		or (Fecha < case when @CALENDARIO0003 = 1 then cast(dateadd(day,1,GETDATE()) as date) else '1900-01-01' end)

    select @total=COUNT(*)
    from Asistencia.tblHorariosEmpleados he
		join @Fechas fecha on fecha.Fecha = he.Fecha
    WHERE IDEmpleado = @IDEmpleado 
   -- and Fecha BETWEEN @FechaIni and @FechaFin

   DECLARE @result VARCHAR(MAX)
	SELECT @result ='['+ STUFF(
            ( select ','+ a.JSON
							from Asistencia.tblHorariosEmpleados he
							join @Fechas fecha on fecha.Fecha = he.Fecha
							Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select he.* For XML Raw)) ) a
							where he.IDEmpleado = @IDEmpleado 
												FOR xml path('')
            )
            , 1
            , 1
            , ''
						)
						+']'
--select @result

	if (@total > 0)
    BEGIN
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblHorariosEmpleados]','[Asistencia].[spBorrarHorarioEmpleado]','DELETE','',@result

		delete he
		from Asistencia.tblHorariosEmpleados he
			join @Fechas fecha on fecha.Fecha = he.Fecha
		WHERE IDEmpleado = @IDEmpleado 
			--and ie.Fecha BETWEEN @FechaIni and @FechaFin

		select 0 as ID
			,'Se eliminó '+ cast(@total as varchar(100)) +' registros de horario.' as Mensaje
			,0 as TipoRespuesta
		return;
    end else
    BEGIN
		select 0 as ID
			,'El empleado no tiene horarios en el rango de fecha seleccionado.' as Mensaje
			,0 as TipoRespuesta
		return;
    end;
GO

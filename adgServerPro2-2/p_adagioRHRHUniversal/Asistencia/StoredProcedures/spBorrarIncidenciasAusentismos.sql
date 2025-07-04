USE [p_adagioRHRHUniversal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Incidencias empleados
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-05-22
** Paremetros		: 
				 @IDIncidenciaEmpleado int 
				,@IDEmpleado		   int 
				,@IDUsuario		   int 
				,@ConfirmadoEliminar   bit  = 0
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2021-11-05			Aneudy Abreu	Se agregó validación para el permiso @DIAS_MODIFICAR_CALENDARIO
2023-09-08          Julio Castillo  Se aisló la evaluacion de fechas para Incapacidades. Esto valida
                                    permisos de calendario y permite borrar desde cualquier dia de la
                                    incapacidad seleccionada en el calendario. Se agrego un if exists 
                                    para avisar si no tiene permiso. 
***************************************************************************************************/
CREATE proc [Asistencia].[spBorrarIncidenciasAusentismos] (
	@IDIncidenciaEmpleado	int 
    ,@IDEmpleado			int 
    ,@FechaIni				date = null
    ,@FechaFin				date = null
    ,@IDUsuario				int 
    ,@ConfirmadoEliminar	bit  = 0
) as
	declare @IDIncapacidadEmpleado int = 0
		,@TotalDiasIncapacidad int = 0
		,@TotalIncidencias int = 0
		,@IDIncidencia varchar(10)
		,@Incidencia varchar(255)
		,@FechaIncapacidad date
		,@Fechas [App].[dtFechas] 
		,@CALENDARIO0002 bit = 0 --No Modificar calendario de días anteriores(Permite modificar el día actual)'
		,@CALENDARIO0003 bit = 0 --No Modificar calendraio de mañana en adelante')
		,@DIAS_MODIFICAR_CALENDARIO int = 0 -- Cantidad de días previos para modificar Calendario
		,@DIAS_MODIFICAR_CALENDARIO_DIAS int = 0
		,@DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA date
        ,@FechaIniIncapacidad DATE
        ,@FechaFinIncapacidad DATE
	    ,@IDIdioma varchar(225);     
        
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')
	  
	DECLARE @OldJSON Varchar(Max),
			@NewJSON Varchar(Max);

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

    select @IDIncidencia = ie.IDIncidencia
			,@Incidencia = i.Descripcion
			,@FechaIni = case when @FechaIni is null then ie.Fecha else @FechaIni end
    from [Asistencia].[tblIncidenciaEmpleado] ie
		join [Asistencia].[tblCatIncidencias] i on i.IDIncidencia = ie.IDIncidencia
    where ie.IDIncidenciaEmpleado = @IDIncidenciaEmpleado

	set @FechaFin = isnull(@FechaFin,@FechaIni)

	if (@DIAS_MODIFICAR_CALENDARIO = 1)
	begin
		set @DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA = DATEADD(DAY, @DIAS_MODIFICAR_CALENDARIO_DIAS * -1, GETDATE())

		if (@FechaIni < @DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA)
		begin
			select @IDIncidenciaEmpleado as ID
				,FORMATMESSAGE('No tienes permiso para eliminar %s mayores a %d dias previos.', @Incidencia, @DIAS_MODIFICAR_CALENDARIO_DIAS) as Mensaje
				,-1 as TipoRespuesta
			return;
		end
	end

	

	if (@IDIncidencia = 'I')
    BEGIN
    
        select top 1 @IDIncapacidadEmpleado = ie.IDIncapacidadEmpleado
		from [Asistencia].[tblIncidenciaEmpleado] ie
		where ie.IDIncidenciaEmpleado = @IDIncidenciaEmpleado and ie.IDIncidencia = 'I'

		select @FechaIniIncapacidad = Fecha,@FechaFinIncapacidad = DATEADD(day,Duracion-1,Fecha)
		from Asistencia.tblIncapacidadEmpleado
		where IDIncapacidadEmpleado = @IDIncapacidadEmpleado

        insert into @Fechas(Fecha)
        SELECT d
        FROM (
            SELECT d = DATEADD(DAY, rn - 1, @FechaIniIncapacidad)
            FROM (
                SELECT TOP 
                    (DATEDIFF(DAY, @FechaIniIncapacidad, @FechaFinIncapacidad) +1) rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
                FROM sys.all_objects AS s1
                CROSS JOIN sys.all_objects AS s2
                -- on my system this would support > 5 million days
                ORDER BY s1.[object_id]
            ) AS x
            ) AS y;
	        -- select * from Asistencia.tblCatIncidencias

	    DELETE from @Fechas
	    where (Fecha < case when @CALENDARIO0002 = 1 then cast(GETDATE() as date) else '1900-01-01' end)
		or (Fecha < case when @CALENDARIO0003 = 1 then cast(dateadd(day,1,GETDATE()) as date) else '1900-01-01' end)
		
        
        

		if not exists (
			select top 1 1
			from @Fechas
			where Fecha = @FechaIni
		)
		BEGIN
			select @IDIncidenciaEmpleado as ID
				,'No tienes permiso para eliminar esta Incapacidad.' as Mensaje
				,-1 as TipoRespuesta
			return;
		END

		if (
			((select count(*) 
				from [Asistencia].[tblIncidenciaEmpleado]
				where IDIncapacidadEmpleado = @IDIncapacidadEmpleado) = 1) or @ConfirmadoEliminar = 1)
		BEGIN
			select @OldJSON = a.JSON from [Asistencia].[tblIncidenciaEmpleado] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDIncapacidadEmpleado = @IDIncapacidadEmpleado and IDIncidencia = 'I'
		
			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblIncidenciaEmpleado]','[Asistencia].[spBorrarIncidenciasAusentismos]','DELETE','',@OldJSON

			delete from [Asistencia].[tblIncidenciaEmpleado] 
			where IDIncapacidadEmpleado = @IDIncapacidadEmpleado and IDIncidencia = 'I'

			select @OldJSON = a.JSON from [Asistencia].[tblIncapacidadEmpleado] b
			Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
			WHERE b.IDIncapacidadEmpleado = @IDIncapacidadEmpleado	
		
			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblIncapacidadEmpleado]','[Asistencia].[spBorrarIncidenciasAusentismos]','DELETE','',@OldJSON

			delete from [Asistencia].[tblIncapacidadEmpleado]
			where IDIncapacidadEmpleado = @IDIncapacidadEmpleado	

			select @IDIncidenciaEmpleado as ID
				,'Incapacidad eliminada correctamente.' as Mensaje
				,0 as TipoRespuesta
			return;
		end else
		BEGIN
			select @TotalDiasIncapacidad = count(*)
			from [Asistencia].[tblIncidenciaEmpleado]
			where IDIncapacidadEmpleado = @IDIncapacidadEmpleado

			select @IDIncidenciaEmpleado as ID
				,'Esta incapacidad tiene '+cast(@TotalDiasIncapacidad as varchar)+' eventos más que serán elimiandos.' as Mensaje
				,1 as TipoRespuesta

			return;  
		END;
	END ELSE
    BEGIN

        declare @IDPapeleta int 
        select @IDPapeleta=IDPapeleta from Asistencia.tblIncidenciaEmpleado where IDIncidenciaEmpleado=@IDIncidenciaEmpleado

        IF  @IDPapeleta <> 0 
        BEGIN         
            IF(@ConfirmadoEliminar=0 )
            BEGIN
            

                declare @htmltemplate varchar (max)             
                declare @rowtemple VARCHAR(max)
                declare @body  VARCHAR(max)
                set @htmltemplate =N'<table class="tbldialog_resumen">
                                <tr>
                                    <th colspan="3" >
                                        <div style="text-align: center;"><b>Información Detallada</b></div>
                                    </th>
                                </tr>
                                <tr>                                
                                    <th><b>Evento</b></th>
                                    <th><b>Fecha</b></th>                                                                                                        
                                </tr>             
                                %s               
                            </table> <br> <b>¿Quiere eliminar los eventos mostrados?</b>'
                set @rowtemple=' <tr><th>%s</th><th>%s</th></tr>'
                SELECT @body=STRING_AGG(FORMATMESSAGE(@rowtemple,(JSON_VALUE(i.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) + CASE WHEN isnull(Autorizado,0) = 1 THEN ' - AUT.' ELSE '' END), CONVERT(varchar,ie.Fecha,103)),'')
                    FROM Asistencia.tblIncidenciaEmpleado  ie
                inner join Asistencia.tblCatIncidencias  i on i.IDIncidencia = ie.IDIncidencia
                where IDPapeleta=@IDPapeleta

                

                select @IDIncidenciaEmpleado as ID
				    ,FORMATMESSAGE(@htmltemplate,@body) as Mensaje
				    ,2 as TipoRespuesta
                return;
            END ELSE
            BEGIN
                SELECT @OldJSON ='['+ STUFF(
                    ( select ','+ a.JSON
                            from [Asistencia].[tblIncidenciaEmpleado] ie
                                join @Fechas fecha on fecha.Fecha = ie.Fecha
                            Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select IE.* For XML Raw)) ) a
                            where ie.IDEmpleado = @IDEmpleado 
                            and ie.IDIncidencia  = @IDIncidencia
                                                FOR xml path('')
                    ),1,1,'') +']'            
                EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblIncidenciaEmpleado]','[Asistencia].[spBorrarIncidenciasAusentismos]','DELETE','',@OldJSON            

                delete ie from [Asistencia].[tblIncidenciaEmpleado] ie                
                WHERE IDPapeleta=@IDPapeleta

                delete from Asistencia.tblPapeletas where IDPapeleta=@IDPapeleta

                IF(@IDIncidencia = 'V') 
                BEGIN
                    IF EXISTS(Select top 1 1 from app.tblConfiguracionesGenerales CG where IDConfiguracion = 'RefactorizacionVacaciones' and Valor = 1)
                    BEGIN                   
                    EXEC [Asistencia].[spSchedulerGeneracionVacaciones]  @IDEmpleado = @IDEmpleado, @IDUsuario = @IDUsuario
                    END
                END

                select @IDIncidenciaEmpleado as ID
                ,'Eventos eliminados correctamente.' as Mensaje
                ,0 as TipoRespuesta

            return;
            END            
        END ELSE
        begin 
              insert into @Fechas(Fecha)
            SELECT d
            FROM (
                SELECT d = DATEADD(DAY, rn - 1, @FechaIni)
                FROM (
                    SELECT TOP 
                        (DATEDIFF(DAY, @FechaIni, @FechaFin) +1) rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
                    FROM sys.all_objects AS s1
                    CROSS JOIN sys.all_objects AS s2
                    -- on my system this would support > 5 million days
                    ORDER BY s1.[object_id]
                ) AS x
                ) AS y;
                -- select * from Asistencia.tblCatIncidencias

            DELETE from @Fechas
            where (Fecha < case when @CALENDARIO0002 = 1 then cast(GETDATE() as date) else '1900-01-01' end)
            or (Fecha < case when @CALENDARIO0003 = 1 then cast(dateadd(day,1,GETDATE()) as date) else '1900-01-01' end)

            if  exists (
                select top 1 1
                from @Fechas
                where Fecha = @FechaIni
            )
            BEGIN
                select @TotalIncidencias=count(*)
                from [Asistencia].[tblIncidenciaEmpleado]
                where IDEmpleado = @IDEmpleado and Fecha between @FechaIni and @FechaFin
                    and IDIncidencia  = @IDIncidencia
            

                SELECT @OldJSON ='['+ STUFF(
                    ( select ','+ a.JSON
                                    from [Asistencia].[tblIncidenciaEmpleado] ie
                                        join @Fechas fecha on fecha.Fecha = ie.Fecha
                                    Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select IE.* For XML Raw)) ) a
                                    where ie.IDEmpleado = @IDEmpleado 
                                    and ie.IDIncidencia  = @IDIncidencia
                                                        FOR xml path('')
                    )
                    , 1
                    , 1
                    , ''
                                )
                                +']'
                
                EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblIncidenciaEmpleado]','[Asistencia].[spBorrarIncidenciasAusentismos]','DELETE','',@OldJSON
                
                delete ie
                from [Asistencia].[tblIncidenciaEmpleado] ie
                    join @Fechas fecha on fecha.Fecha = ie.Fecha
                where IDEmpleado = @IDEmpleado 
                    --and Fecha between @FechaIni and @FechaFin
                    and IDIncidencia  = @IDIncidencia


                IF(@IDIncidencia = 'V') 
                BEGIN
                    IF EXISTS(Select top 1 1 from app.tblConfiguracionesGenerales CG where IDConfiguracion = 'RefactorizacionVacaciones' and Valor = 1)
                    BEGIN                   
                    EXEC [Asistencia].[spSchedulerGeneracionVacaciones]  @IDEmpleado = @IDEmpleado, @IDUsuario = @IDUsuario
                    END
                END

                --if (@FechaIni is not null and @FechaFin is not null)
                --BEGIN
                --end else
                --BEGIN
                --	select @TotalIncidencias = 1;

                --	delete from [Asistencia].[tblIncidenciaEmpleado]
                --	where IDIncidenciaEmpleado = @IDIncidenciaEmpleado
                --end;

                select @IDIncidenciaEmpleado as ID
                    ,cast(@TotalIncidencias as varchar)+' Incidencia(s) ['+@IDIncidencia+'] eliminada(s) correctamente.' as Mensaje
                    ,0 as TipoRespuesta

                return;
            END
        END      
	end;
    
	select @IDIncidenciaEmpleado as ID
			,'No se encontró ninguna incidencia o no tienes permiso para eliminar ['+cast(@IDIncapacidadEmpleado as varchar)+'].' as Mensaje
			,-1 as TipoRespuesta
GO

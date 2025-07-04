USE [p_adagioRHAC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Crear, Actualizar Incidencias de empleados (Principal)
** Autor			: Aneudy
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-05-16 

** Notas: Temp table #tempResponse - TipoRespuesta
	 -1 - Sin respuesta
	  0 - Creados
	  1 - EsperaDeConfirmación   
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
 CREATE   proc [Asistencia].[spIUIncidenciaEmpleado](
	@IDIncidenciaEmpleado	int
	,@IDEmpleado			int	
	,@IDIncidencia			varchar(10)
	,@FechaIni				date 
	,@FechaFin				date     
	,@Dias					varchar(20) = NULL
	,@TiempoSugerido		time
	,@TiempoAutorizado		time
	,@Comentario			nvarchar(max)
	,@ComentarioTextoPlano	nvarchar(max)
	,@CreadoPorIDUsuario	int 
	,@Autorizado			bit 
	,@ConfirmarActualizar	bit = 0
    ,@TipoRespuesta         int = 0 OUTPUT
    ,@IDPapeleta  int = null
 ) as
	SET DATEFIRST 7;

    select @IDPapeleta =iif(@IDPapeleta= 0,null ,@IDPapeleta)

    declare  
		 @FechaHoraAutorizacion		datetime	 
		--,@FechaHoraCreacion		datetime
		,@AutorizadoPor				int 
		,@Incidencia				varchar(255)
		,@Fechas					[App].[dtFechasFull]
		,@Fechas1DescansoPorSemana	[App].[dtFechasFull]

		,@FechaIniSemana			date 
		,@FechaFinSemana			date

		,@IDIdioma					Varchar(5)
		,@IdiomaSQL					varchar(100) = null
		,@Mensaje					nvarchar(max)
		,@EsAusentismo				bit
		,@CALENDARIO0002			bit = 0 --No Modificar calendario de días anteriores(Permite modificiar el día actual)'
		,@CALENDARIO0003			bit = 0 --No Modificar calendraio de mañana en adelante'
		,@CALENDARIO0005			bit = 0 --Solo puede agregar 1 descanso por semana.
		,@CALENDARIO0007			bit = 0 --El usuario puede modificar su propio calendario de incidencias.
		,@DIAS_MODIFICAR_CALENDARIO int = 0 -- Cantidad de días previos para modificar Calendario
		,@DIAS_MODIFICAR_CALENDARIO_DIAS int = 0
		,@DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA date
        ,@CALENDARIO0003_totalEliminados int 
        ,@CALENDARIO0002_totalEliminados int
        ,@DIAS_DEFAULT VARCHAR(MAX) ='1,2,3,4,5,6,7'
        ;
	    
	DECLARE @OldJSON Varchar(Max),
			@NewJSON Varchar(Max);

    select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @CreadoPorIDUsuario, 'esmx'), '-',''))
    if OBJECT_ID('tempdb..#tempTblRevisionRangosFechas') is not null drop table #tempTblRevisionRangosFechas

	BEGIN -- Permisos de calendario
		if exists(select top 1 1 
			from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @CreadoPorIDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'CALENDARIO0002')
		begin
			set @CALENDARIO0002 = 1
		end;

		if exists(select top 1 1 
			from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @CreadoPorIDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'CALENDARIO0003')
		begin
			set @CALENDARIO0003 = 1
		end;

		if exists(select top 1 1 
			from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @CreadoPorIDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'CALENDARIO0005')
		begin
			set @CALENDARIO0005 = 1
		end;

		if exists(select top 1 1 
			from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @CreadoPorIDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'CALENDARIO0007')
		begin
			set @CALENDARIO0007 = 1
		end;

		if exists(select top 1 1 
			from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @CreadoPorIDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'DIAS_MODIFICAR_CALENDARIO')
		begin
			set @DIAS_MODIFICAR_CALENDARIO = 1

			select @DIAS_MODIFICAR_CALENDARIO_DIAS = CAST(isnull(cpe.[Data], 0) as int)
			from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @CreadoPorIDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'DIAS_MODIFICAR_CALENDARIO'
		end;
	END

	select @EsAusentismo = EsAusentismo,
			@Incidencia = JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion'))
	from [Asistencia].[tblCatIncidencias] with (nolock)
	where IDIncidencia = @IDIncidencia

	if (@DIAS_MODIFICAR_CALENDARIO = 1)
	begin
		set @DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA = DATEADD(DAY, @DIAS_MODIFICAR_CALENDARIO_DIAS * -1, GETDATE())

		if (@FechaIni < @DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA)
		begin
			select 
				0 as ID
				,0 as TipoEvento
				,FORMATMESSAGE('No tienes permiso para crear %s mayores a %d dias previos.', @Incidencia, @DIAS_MODIFICAR_CALENDARIO_DIAS)  as Mensaje
				,-1 as TipoRespuesta
            
            set @TipoRespuesta=-1

			return;
		end
	end
    
	if (@CALENDARIO0007 = 0)
	begin
		if (@IDEmpleado = (isnull((SELECT IDEmpleado from Seguridad.tblUsuarios where IDUsuario = @CreadoPorIDUsuario),0)))
		begin
			select 
				0 as ID
				,0 as TipoEvento
				,FORMATMESSAGE('No tienes permiso para modificar su propio calendario.')  as Mensaje
				,-1 as TipoRespuesta
                
                set @TipoRespuesta=-1
			return;
		end
	end

    -- IF NOT EXISTS(Select IDempleado from [Utilerias].[fnBuscarFiltrosEmpleadosIfSupervisorYJefeEmpleados](@CreadoPorIDUsuario) where IDEmpleado = @IDEmpleado)
    -- BEGIN
    --     -- RAISERROR('No tiene permiso para procesar la solicitud. Por favor, contacte a su asesor de soporte', 16, 1)
    --     select 
	-- 			0 as ID
	-- 			,0 as TipoEvento
	-- 			,FORMATMESSAGE('No tiene permiso para procesar la solicitud. Por favor, contacte a su asesor de soporte.')  as Mensaje
	-- 			,-1 as TipoRespuesta
                
    --             set @TipoRespuesta=-1
	-- 		return;
    --     RETURN
    -- END

    IF(@FechaIni=@FechaFin)
    BEGIN
        SET @Dias = @DIAS_DEFAULT
    END

    IF((ISNULL(@Dias,'') = ''))
    BEGIN
        	select 
				0 as ID
				,0 as TipoEvento
				,FORMATMESSAGE('Selecciona al menos un día de la semana.')  as Mensaje
				,-1 as TipoRespuesta
                
                set @TipoRespuesta=-1
			return;
    END


	

    select @FechaHoraAutorizacion	= case WHEN @Autorizado = 1 then getdate() else null end
	     ,@AutorizadoPor			= case WHEN @Autorizado = 1 then @CreadoPorIDUsuario else null end
	     ,@Comentario				= case WHEN len(@Comentario) > 0 then @Comentario else null end
	     ,@ComentarioTextoPlano		= case WHEN len(@ComentarioTextoPlano) > 0 then @ComentarioTextoPlano else null end
	;

	select @IDIdioma = lower(replace(App.fnGetPreferencia('Idioma', @CreadoPorIDUsuario, 'esmx'), '-',''))

    select @IdiomaSQL = [SQL]
    from app.tblIdiomas with (nolock)
    where IDIdioma = @IDIdioma


	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
    begin
	   set @IdiomaSQL = 'Spanish' ;
    end
  
    SET LANGUAGE @IdiomaSQL;

	insert into @Fechas(Fecha)
	exec [App].[spListaFechas]
		@FechaIni = @FechaIni
		,@FechaFin = @FechaFin

	select  
		 @FechaIniSemana= dateadd(dd,1,DATEADD(dd, -(DATEPART(dw, @FechaIni)-1), @FechaIni)) --[WeekStart]
		,@FechaFinSemana= dateadd(dd,1,DATEADD(dd, 7-(DATEPART(dw, @FechaFin)), @FechaFin) ) --[WeekEnd]
	
	insert @Fechas1DescansoPorSemana(Fecha)
	exec [App].[spListaFechas]
		@FechaIni = @FechaIniSemana
		,@FechaFin = @FechaFinSemana

    if (@IDIncidenciaEmpleado = 0)
    begin
	
    
        SELECT Fechas.*
             ,CASE WHEN Fecha < CASE WHEN @CALENDARIO0002 = 1 THEN CAST(GETDATE() AS DATE) ELSE '1900-01-01' END 
                        OR 
                        Fecha < CASE WHEN @CALENDARIO0003 = 1 THEN CAST(DATEADD(DAY,1,GETDATE()) AS DATE) ELSE '1900-01-01' END
                    THEN 0
                    ELSE 1
                    END AS Valid
            INTO #tempTblRevisionRangosFechas
        FROM @Fechas Fechas


		DELETE from @Fechas
		where DATEPART(dw,Fecha) NOT in (SELECT cast(item as int) from [App].[Split](@Dias,',') )
			or (Fecha < case when @CALENDARIO0002 = 1 then cast(GETDATE() as date) else '1900-01-01' end)
			or (Fecha < case when @CALENDARIO0003 = 1 then cast(dateadd(day,1,GETDATE()) as date) else '1900-01-01' end)



        IF EXISTS(
            		SELECT TOP 1 1 
                     FROM #tempTblRevisionRangosFechas
                     WHERE Valid = 0					              
			 )
        BEGIN
            SELECT
				 0 as ID
				,0 as TipoEvento
				,FORMATMESSAGE('No tienes permiso para modificar el calendario en alguna de las fechas seleccionadas.')  as Mensaje
				,-1 as TipoRespuesta
                
                set @TipoRespuesta=-1
            RETURN    
           
        END

		IF (
			(EXISTS (SELECT TOP 1 1 
					FROM [Asistencia].[tblIncidenciaEmpleado] ei with (nolock) 
						JOIN @Fechas f on ei.Fecha =  f.Fecha
						JOIN [Asistencia].[tblCatIncidencias] i with (nolock) on ei.IDIncidencia = i.IDIncidencia
					 WHERE ei.IDEmpleado = @IDEmpleado 
                       AND ei.Fecha BETWEEN @FechaIni AND @FechaFin
					   --AND ei.IDIncidencia <> @IDIncidencia 
					   AND i.EsAusentismo = @EsAusentismo
					 )
             ) 
             AND (@ConfirmarActualizar  = 0) and (@EsAusentismo = 1)
			 )
		BEGIN    		
                SELECT @Mensaje =                       
                      '<table border="1" style="margin:  5px auto 0; border-collapse: collapse; padding: 10px;">' +
                      '<tr><th style="padding: 5px;">' +
                      CASE WHEN @IDIdioma = 'esmx' THEN 'Fecha' 
                           WHEN @IDIdioma = 'enus' THEN 'Date' 
                           ELSE 'Fecha' END +
                      '</th><th style="padding: 5px;">' +
                      CASE WHEN @IDIdioma = 'esmx' THEN 'Descripción' 
                           WHEN @IDIdioma = 'enus' THEN 'Description' 
                          ELSE 'Descripción' END +
                      '</th></tr>' +
                      COALESCE((
                          SELECT '<tr><td style="padding: 5px;">' + 
                                 CASE WHEN @IDIdioma = 'esmx' THEN CONVERT(NVARCHAR, ie.Fecha, 103) 
                                      WHEN @IDIdioma = 'enus' THEN CONVERT(NVARCHAR, ie.Fecha, 101) 
                                      ELSE CONVERT(NVARCHAR, ie.Fecha, 103) END +
                                 '</td><td style="padding: 5px;">' + JSON_VALUE(i.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'Descripcion')) + '</td></tr>'
                          FROM [Asistencia].[tblIncidenciaEmpleado] ie WITH (NOLOCK)
                          JOIN @Fechas f ON ie.Fecha = f.Fecha
                          JOIN [Asistencia].[tblCatIncidencias] i WITH (NOLOCK) ON ie.IDIncidencia = i.IDIncidencia
                          WHERE ie.IDEmpleado = @IDEmpleado
                         --     AND ie.IDIncidencia <> @IDIncidencia 
                              AND i.EsAusentismo = @EsAusentismo
                          ORDER BY ie.Fecha
                          FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), '') +
                  '</table>';
    
			    SELECT 0 AS ID
				,0 AS TipoEvento
				,@Mensaje  AS Mensaje
				,1 AS TipoRespuesta
                
                SET @TipoRespuesta=1
		  
          RETURN;
		  
		END 
        ELSE IF (@EsAusentismo = 1)
		BEGIN
			delete ie
			from [Asistencia].[tblIncidenciaEmpleado] ie with (nolock) 
				join @Fechas f on ie.Fecha =  f.Fecha
				join [Asistencia].[tblCatIncidencias] i with (nolock) on ie.IDIncidencia = i.IDIncidencia
			where ie.IDEmpleado = @IDEmpleado
				and ie.IDIncidencia <> @IDIncidencia 
				and i.EsAusentismo = @EsAusentismo
		END;

		

		if ((@CALENDARIO0005 = 1) and (@IDIncidencia = 'D') and exists (
				select ISOSemana,SUM(Total) as Total
				from (
					select f.ISOSemana,count(*) as Total
					from Asistencia.tblIncidenciaEmpleado ie with (nolock)
						join @Fechas1DescansoPorSemana f on ie.Fecha = f.Fecha
					where ie.IDEmpleado = @IDEmpleado and ie.IDIncidencia = 'D'
					group by f.ISOSemana
					UNION ALL
					select ISOSemana,count(*) as Total
					from @Fechas
					group by ISOSemana
				) descanso
				group by ISOSemana
				having SUM(Total) > 1
		))
		begin
			print 'No puede asignar dos descansos en la misma semana'
			select 
				0 as ID
				,0 as TipoEvento
				,'No puede asignar dos descansos en la misma semana'  as Mensaje
				,-1 as TipoRespuesta
                
                set @TipoRespuesta=-1
			return;
		end;




		SELECT @OldJson ='['+ STUFF(
            ( select ','+ a.JSON
							from @Fechas b
							join [Asistencia].[tblIncidenciaEmpleado] c
								on b.Fecha = c.Fecha
							and c.IDEmpleado = @IDEmpleado
							Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select c.* For XML Raw)) ) a
												FOR xml path('')
            )
            , 1
            , 1
            , ''
						)
						+']'


        
        IF(@IDPapeleta <> 0) 
        begin
            if @EsAusentismo =1 
            begin
                delete from  [Asistencia].[tblIncidenciaEmpleado] where IDPapeleta=@IDPapeleta and Fecha not in (select Fecha from @Fechas)                
            end else
            begin 
                delete from  [Asistencia].[tblIncidenciaEmpleado] where IDPapeleta=@IDPapeleta
            end            
        end



		MERGE [Asistencia].[tblIncidenciaEmpleado] AS TARGET
		USING @Fechas as SOURCE
			on ( TARGET.Fecha = SOURCE.Fecha and TARGET.IDEmpleado = @IDEmpleado and TARGET.IDIncidencia = @IDIncidencia ) or 
                (TARGET.IDPapeleta = @IDPapeleta and TARGET.Fecha = SOURCE.Fecha and TARGET.IDEmpleado = @IDEmpleado  and TARGET.IDIncidencia = @IDIncidencia )
                WHEN MATCHED THEN
			update 
				set	TARGET.IDIncidencia			= @IDIncidencia
				,	TARGET.TiempoSugerido			= @TiempoSugerido
				,	TARGET.TiempoAutorizado		= @TiempoAutorizado
				,	TARGET.Comentario			= @Comentario
				,	TARGET.ComentarioTextoPlano	= @ComentarioTextoPlano
				,	TARGET.CreadoPorIDUsuario		= @CreadoPorIDUsuario
				,	TARGET.Autorizado			= @Autorizado
				,	TARGET.AutorizadoPor			= @AutorizadoPor
				,	TARGET.FechaHoraAutorizacion	= @FechaHoraAutorizacion
                ,   TARGET.IDPapeleta               = @IDPapeleta
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDEmpleado,IDIncidencia,Fecha
				,TiempoSugerido,TiempoAutorizado,Comentario,ComentarioTextoPlano,CreadoPorIDUsuario
				,Autorizado,AutorizadoPor,FechaHoraAutorizacion,FechaHoraCreacion,IDPapeleta)
			values(@IDEmpleado			
		  	    ,@IDIncidencia		
		  	    ,SOURCE.Fecha				
		  	    ,@TiempoSugerido		
		  	    ,@TiempoAutorizado	
		  	    ,@Comentario	
		  	    ,@ComentarioTextoPlano	
		  	    ,@CreadoPorIDUsuario	
		  	    ,@Autorizado			
		  	    ,@AutorizadoPor		
		  	    ,@FechaHoraAutorizacion
		  	    ,getdate()
                ,@IDPapeleta
			);
			
 SELECT @NewJson ='['+ STUFF(
            ( select ','+ a.JSON
							from @Fechas b
							join [Asistencia].[tblIncidenciaEmpleado] c
								on b.Fecha = c.Fecha
							and c.IDEmpleado = @IDEmpleado
							Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,0,(Select c.* For XML Raw)) ) a
												FOR xml path('')
            )
            , 1
            , 1
            , ''
						)
						+']'

            

            IF(@NewJSON IS NULL)
            BEGIN
                SELECT 
				 0 AS ID
				,0 AS TipoEvento
				,FORMATMESSAGE('No se genero ningun evento.')  as Mensaje
				,-1 as TipoRespuesta
                
                SET @TipoRespuesta=-1
			    RETURN;
            END
            
            EXEC [Auditoria].[spIAuditoria] @CreadoPorIDUsuario,'[Asistencia].[tblIncidenciaEmpleado]','[Asistencia].[spIUIncidenciaEmpleado]','MERGE',@NewJSON,@OldJSON

			SELECT  JSON_VALUE(@NewJson, '$[0].IDIncidenciaEmpleado') as ID
				,0 as TipoEvento
				,'Registros creados correctamente' as Mensaje
				,0 as TipoRespuesta

                SET @TipoRespuesta=0

		return;
    end ELSE
    BEGIN

	select @OldJSON = a.JSON from [Asistencia].[tblIncidenciaEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDIncidenciaEmpleado	= @IDIncidenciaEmpleado


		update [Asistencia].[tblIncidenciaEmpleado]
			set 
				IDIncidencia		= @IDIncidencia
				 ,Fecha				= @FechaIni
				 ,TiempoSugerido		= @TiempoSugerido
				 ,TiempoAutorizado		= @TiempoAutorizado
				 ,Comentario			= @Comentario
				 ,ComentarioTextoPlano	= @ComentarioTextoPlano
				 ,CreadoPorIDUsuario	= @CreadoPorIDUsuario
				 ,Autorizado			= @Autorizado
				 ,AutorizadoPor			= @AutorizadoPor
				 ,FechaHoraAutorizacion	= @FechaHoraAutorizacion
                 ,IDPapeleta = @IDPapeleta 
	    where IDIncidenciaEmpleado	= @IDIncidenciaEmpleado

		select @NewJSON = a.JSON from [Asistencia].[tblIncidenciaEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDIncidenciaEmpleado	= @IDIncidenciaEmpleado

		EXEC [Auditoria].[spIAuditoria] @CreadoPorIDUsuario,'[Asistencia].[tblIncidenciaEmpleado]','[Asistencia].[spIUIncidenciaEmpleado]','UPDATE',@NewJSON,@OldJSON

	    select @IDIncidenciaEmpleado as ID
			,0 as TipoEvento
			 ,'Registro actualizado correctamente' as Mensaje
			 ,0 as TipoRespuesta

             set @TipoRespuesta=0
		return;
    end;
GO

USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Crear, Actualizar Incidencias de empleados
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
 CREATE proc [Asistencia].[spIUIncidenciaEmpleado](
	@IDIncidenciaEmpleado	int
	,@IDEmpleado			int	
	,@IDIncidencia			varchar(10)
	,@FechaIni				date 
	,@FechaFin				date     
	,@Dias					varchar(20) 
	,@TiempoSugerido		time
	,@TiempoAutorizado		time
	,@Comentario			nvarchar(max)
	,@ComentarioTextoPlano	nvarchar(max)
	,@CreadoPorIDUsuario	int 
	,@Autorizado			bit 
	,@ConfirmarActualizar	bit = 0

 ) as
	SET DATEFIRST 7;

    declare  
		 @FechaHoraAutorizacion		datetime	 
		--,@FechaHoraCreacion		datetime
		,@AutorizadoPor				int 
		,@Incidencia				varchar(255)
		,@Fechas					[App].[dtFechas]
		,@Fechas1DescansoPorSemana	[App].[dtFechas]

		,@FechaIniSemana			date 
		,@FechaFinSemana			date

		,@IDIdioma					Varchar(5)
		,@IdiomaSQL					varchar(100) = null
		,@Mensaje					nvarchar(max)
		,@EsAusentismo				bit
		,@CALENDARIO0002			bit = 0 --No Modificar calendario de días anteriores(Permite modificiar el día actual)'
		,@CALENDARIO0003			bit = 0 --No Modificar calendraio de mañana en adelante'
		,@CALENDARIO0005			bit = 0 --Solo puede agregar 1 descanso por semana.
		,@DIAS_MODIFICAR_CALENDARIO int = 0 -- Cantidad de días previos para modificar Calendario
		,@DIAS_MODIFICAR_CALENDARIO_DIAS int = 0
		,@DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA date
	;
	
	DECLARE @OldJSON Varchar(Max),
			@NewJSON Varchar(Max);

	BEGIN -- Permisos de calendario
		if exists(select top 1 1 
			from Seguridad.tblPermisosEspecialesUsuarios pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @CreadoPorIDUsuario and cpe.Codigo = 'CALENDARIO0002')
		begin
			set @CALENDARIO0002 = 1
		end;

		if exists(select top 1 1 
			from Seguridad.tblPermisosEspecialesUsuarios pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @CreadoPorIDUsuario and cpe.Codigo = 'CALENDARIO0003')
		begin
			set @CALENDARIO0003 = 1
		end;

		if exists(select top 1 1 
			from Seguridad.tblPermisosEspecialesUsuarios pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @CreadoPorIDUsuario and cpe.Codigo = 'CALENDARIO0005')
		begin
			set @CALENDARIO0005 = 1
		end;

		if exists(select top 1 1 
			from Seguridad.tblPermisosEspecialesUsuarios pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @CreadoPorIDUsuario and cpe.Codigo = 'DIAS_MODIFICAR_CALENDARIO')
		begin
			set @DIAS_MODIFICAR_CALENDARIO = 1

			select @DIAS_MODIFICAR_CALENDARIO_DIAS = CAST(isnull(cpe.[Data], 0) as int)
			from Seguridad.tblPermisosEspecialesUsuarios pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @CreadoPorIDUsuario and cpe.Codigo = 'DIAS_MODIFICAR_CALENDARIO'
		end;
	END

	select @EsAusentismo = EsAusentismo,
			@Incidencia = Descripcion
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
			return;
		end
	end



	--if object_id('tempdb..#tempResponse') is not null drop table #tempResponse;

    select @FechaHoraAutorizacion	= case WHEN @Autorizado = 1 then getdate() else null end
	     ,@AutorizadoPor			= case WHEN @Autorizado = 1 then @CreadoPorIDUsuario else null end
	     ,@Comentario				= case WHEN len(@Comentario) > 0 then @Comentario else null end
	     ,@ComentarioTextoPlano		= case WHEN len(@ComentarioTextoPlano) > 0 then @ComentarioTextoPlano else null end
	;

	select top 1 @IDIdioma = dp.Valor
    from Seguridad.tblUsuarios u with (nolock)
	   Inner join App.tblPreferencias p with (nolock) on u.IDPreferencia = p.IDPreferencia
	   Inner join App.tblDetallePreferencias dp with (nolock) on dp.IDPreferencia = p.IDPreferencia
	   Inner join App.tblCatTiposPreferencias tp with (nolock) on tp.IDTipoPreferencia = dp.IDTipoPreferencia
	where u.IDUsuario = @CreadoPorIDUsuario and tp.TipoPreferencia = 'Idioma'

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
	
		DELETE from @Fechas
		where DATEPART(dw,Fecha) NOT in (SELECT cast(item as int) from [App].[Split](@Dias,',') )
			or (Fecha < case when @CALENDARIO0002 = 1 then cast(GETDATE() as date) else '1900-01-01' end)
			or (Fecha < case when @CALENDARIO0003 = 1 then cast(dateadd(day,1,GETDATE()) as date) else '1900-01-01' end)

		if (
			(EXISTS (select top 1 1 
					from [Asistencia].[tblIncidenciaEmpleado] ei with (nolock) 
						join @Fechas f on ei.Fecha =  f.Fecha
						join [Asistencia].[tblCatIncidencias] i with (nolock) on ei.IDIncidencia = i.IDIncidencia
					 where ei.IDEmpleado = @IDEmpleado and ei.Fecha BETWEEN @FechaIni and @FechaFin
						and ei.IDIncidencia <> @IDIncidencia 
						and i.EsAusentismo = @EsAusentismo
					 )) and (@ConfirmarActualizar  = 0) and (@EsAusentismo = 1)
			 )
		BEGIN
			select @Mensaje= STUFF(
				  (select ', '+i.Descripcion+' ('+cast(count(*) as varchar(100))+')' 
				  from  [Asistencia].[tblIncidenciaEmpleado] ie with (nolock) 
					 join @Fechas f on ie.Fecha =  f.Fecha
					 join [Asistencia].[tblCatIncidencias] i with (nolock) on ie.IDIncidencia = i.IDIncidencia
				  where ie.IDEmpleado = @IDEmpleado
					 and ie.IDIncidencia <> @IDIncidencia 
					 and i.EsAusentismo = @EsAusentismo
				  group by i.Descripcion
				   FOR XML PATH('')) ,1,2,'')
 
			select 0 as ID
				,0 as TipoEvento
				,@Mensaje  as Mensaje
				,1 as TipoRespuesta
		  return;
		  
		END ELSE IF (@EsAusentismo = 1)
		BEGIN
			delete ie
			from [Asistencia].[tblIncidenciaEmpleado] ie with (nolock) 
				join @Fechas f on ie.Fecha =  f.Fecha
				join [Asistencia].[tblCatIncidencias] i with (nolock) on ie.IDIncidencia = i.IDIncidencia
			where ie.IDEmpleado = @IDEmpleado
				and ie.IDIncidencia <> @IDIncidencia 
				and i.EsAusentismo = @EsAusentismo
		END;

		--select f.ISOSemana,count(*) as Total1
		--from Asistencia.tblIncidenciaEmpleado ie with (nolock)
		--	join @Fechas1DescansoPorSemana f on ie.Fecha = f.Fecha
		--where ie.IDEmpleado = @IDEmpleado and ie.IDIncidencia = 'D'
		--group by f.ISOSemana
		
		--select ISOSemana,count(*) as Total2
		--from @Fechas
		--group by ISOSemana

		--select ISOSemana,SUM(Total) as Total3
		--from (
		--	select f.ISOSemana,count(*) as Total
		--	from Asistencia.tblIncidenciaEmpleado ie with (nolock)
		--		join @Fechas1DescansoPorSemana f on ie.Fecha = f.Fecha
		--	where ie.IDEmpleado = @IDEmpleado and ie.IDIncidencia = 'D'
		--	group by f.ISOSemana
		--	UNION ALL
		--	select ISOSemana,count(*) as Total
		--	from @Fechas
		--	group by ISOSemana
		--) descanso
		--group by ISOSemana

		--select ISOSemana,SUM(Total) as Total4
		--from (
		--	select f.ISOSemana,count(*) as Total
		--	from Asistencia.tblIncidenciaEmpleado ie with (nolock)
		--		join @Fechas1DescansoPorSemana f on ie.Fecha = f.Fecha
		--	where ie.IDEmpleado = @IDEmpleado and ie.IDIncidencia = 'D'
		--	group by f.ISOSemana
		--	UNION ALL
		--	select ISOSemana,count(*) as Total
		--	from @Fechas
		--	group by ISOSemana
		--) descanso
		--group by ISOSemana
		--having SUM(Total) > 1

		--return

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




		MERGE [Asistencia].[tblIncidenciaEmpleado] AS TARGET
		USING @Fechas as SOURCE
			on TARGET.Fecha = SOURCE.Fecha and (TARGET.IDEmpleado = @IDEmpleado)
				and (TARGET.IDIncidencia = @IDIncidencia)
		--WHEN MATCHED THEN
			--update 
				--set	TARGET.IDIncidencia			= @IDIncidencia
				--,	TARGET.TiempoSugerido			= @TiempoSugerido
				--,	TARGET.TiempoAutorizado		= @TiempoAutorizado
				--,	TARGET.Comentario			= @Comentario
				--,	TARGET.ComentarioTextoPlano	= @ComentarioTextoPlano
				--,	TARGET.CreadoPorIDUsuario		= @CreadoPorIDUsuario
				--,	TARGET.Autorizado			= @Autorizado
				--,	TARGET.AutorizadoPor			= @AutorizadoPor
				--,	TARGET.FechaHoraAutorizacion	= @FechaHoraAutorizacion
		WHEN NOT MATCHED BY TARGET THEN 
			INSERT(IDEmpleado,IDIncidencia,Fecha
				,TiempoSugerido,TiempoAutorizado,Comentario,ComentarioTextoPlano,CreadoPorIDUsuario
				,Autorizado,AutorizadoPor,FechaHoraAutorizacion,FechaHoraCreacion)
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

EXEC [Auditoria].[spIAuditoria] @CreadoPorIDUsuario,'[Asistencia].[tblIncidenciaEmpleado]','[Asistencia].[spIUIncidenciaEmpleado]','MERGE',@NewJSON,@OldJSON


			select 0 as ID
				,0 as TipoEvento
				,'Registros creados correctamente' as Mensaje
				,0 as TipoRespuesta

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
	    where IDIncidenciaEmpleado	= @IDIncidenciaEmpleado

		select @OldJSON = a.JSON from [Asistencia].[tblIncidenciaEmpleado] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDIncidenciaEmpleado	= @IDIncidenciaEmpleado

		EXEC [Auditoria].[spIAuditoria] @CreadoPorIDUsuario,'[Asistencia].[tblIncidenciaEmpleado]','[Asistencia].[spIUIncidenciaEmpleado]','UPDATE',@NewJSON,@OldJSON

	    select 0 as ID
			,0 as TipoEvento
			 ,'Registro actualizado correctamente' as Mensaje
			 ,0 as TipoRespuesta
		return;
    end;
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************   
** Descripción  : Crear, Actualizar Incapacidad de empleados  
** Autor   : Aneudy  
** Email   : aneudy.abreu@adagio.com.mx  
** FechaCreacion : 2018-05-22      
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd)	Autor				Comentario  
------------------- ------------------- ------------------------------------------------------------  
2018-08-22			Aneudy Abreu		Se quitaron los parametros @IDCausaAccidente y @IDCorreccionAccidente  
2021-11-05			Aneudy Abreu		Se agregó validación para el permiso @DIAS_MODIFICAR_CALENDARIO
2024-05-55			Aneudy Abreu		Se agrega transacción para que no se queden Incapacidades sin
										incidencias
***************************************************************************************************/  
CREATE proc [Asistencia].[spIUIncapacidadEmpleado](  
	@IDIncapacidadEmpleado int    
    ,@IDEmpleado int    
    ,@Numero varchar (100)  
    ,@Fecha date   
    ,@Duracion int   
    ,@IDTipoIncapacidad int   
    ,@IDClasificacionIncapacidad int   
    ,@PagoSubsidioEmpresa bit   
    ,@IDTipoLesion int   
    ,@IDTipoRiesgoIncapacidad int   
    ,@Permanente bit   
    ,@IDUsuario int  
) as  
 
	--DBCC TRACEOFF( 176,-1)
      
	declare @Fechas [App].[dtFechas]  
		,@IDIdioma Varchar(5)  
		,@IdiomaSQL varchar(100) = null  
		,@FechaFin date = dateadd(day,@Duracion -1,@Fecha)   
		,@CALENDARIO0002 bit = 0 --No Modificar calendario de días anteriores(Permite modificar el día actual)'
		,@CALENDARIO0003 bit = 0 --No Modificar calendraio de mañana en adelante')
		,@DIAS_MODIFICAR_CALENDARIO int = 0 -- Cantidad de días previos para modificar Calendario
		,@DIAS_MODIFICAR_CALENDARIO_DIAS int = 0
		,@DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA date
    ;  

	if object_id('tempdb..#tempIncidencias') is not null drop table #tempIncidencias;

	select IDIncidencia
	INTO #tempIncidencias
	from Asistencia.tblCatIncidencias
	where isnull(EsAusentismo, 0) = 0

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);

	DECLARE @MessageText NVARCHAR(100);
	SET @MessageText = N'Ya existe una incapacidad con este Número, %s.';

	if (exists (select top 1 1 
				from [Asistencia].[tblIncapacidadEmpleado] 
				where Numero=@Numero) and ISNULL(@IDIncapacidadEmpleado, 0) = 0)	 
	BEGIN  
		RAISERROR(
			@MessageText, -- Message text
			16, -- severity
			1, -- state
			@Numero -- first argument to the message text
		); 
		return;
	END  

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

		if (@Fecha < @DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA)
		begin
			RAISERROR(
				'No tienes permiso para crear %s mayores a %d dias previos.', -- Message text
				16, -- severity
				1, -- state
				'Incapacidad(es)',  -- first argument to the message text
				@DIAS_MODIFICAR_CALENDARIO_DIAS
			); 
			return;
		end
	end

    insert into @Fechas(Fecha)  
    exec [App].[spListaFechas]  
		@FechaIni = @Fecha  
		,@FechaFin = @FechaFin  	
		
    IF EXISTS (
        SELECT 1
        FROM @Fechas
        WHERE Fecha < CASE WHEN @CALENDARIO0002 = 1 THEN CAST(GETDATE() AS DATE) ELSE '1900-01-01' END
    )
    BEGIN
        RAISERROR ('Tu Usuario No puede Modificar calendario de días anteriores(Permite modificar el día actual). No se puede realizar la solicitud.', 16, 1);
        RETURN;
    END;
    IF EXISTS (
        SELECT 1
        FROM @Fechas
        WHERE Fecha < CASE WHEN @CALENDARIO0003 = 1 THEN CAST(DATEADD(DAY, 1, GETDATE()) AS DATE) ELSE '1900-01-01' END
    )
    BEGIN
        RAISERROR ('Tu Usuario No puede Modificar calendraio de mañana en adelante. No se puede realizar la solicitud.', 16, 1);
        
        RETURN;
    END;


	
	BEGIN TRANSACTION	
	begin try
		if exists(select top 1 1
					from @Fechas
					where Fecha = @Fecha)
		begin
			if (@IDIncapacidadEmpleado = 0)  
			begin   
				insert into [Asistencia].[tblIncapacidadEmpleado] (IDEmpleado,Numero,Fecha,Duracion,IDTipoIncapacidad  
					,IDClasificacionIncapacidad,PagoSubsidioEmpresa  
					,IDTipoLesion,Hora,Dia,IDTipoRiesgoIncapacidad,Permanente)   
				select @IDEmpleado,@Numero,@Fecha,@Duracion,@IDTipoIncapacidad  
					,case when @IDClasificacionIncapacidad = 0 then null else @IDClasificacionIncapacidad end,@PagoSubsidioEmpresa  
					,case when @IDTipoLesion = 0 then null else @IDTipoLesion end,NULL,NULL,case when @IDTipoRiesgoIncapacidad = 0 then null else @IDTipoRiesgoIncapacidad end,@Permanente     
		
				select @IDIncapacidadEmpleado = @@identity  

				select @NewJSON = a.JSON from [Asistencia].[tblIncapacidadEmpleado] b
					Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
				WHERE b.IDIncapacidadEmpleado = @IDIncapacidadEmpleado

				EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblIncapacidadEmpleado]','[Asistencia].[spIUIncapacidadEmpleado]','INSERT',@NewJSON,''

			end else  
			begin  
				if not exists(select top 1 1   
							from [Asistencia].[tblIncapacidadEmpleado]  
							where IDIncapacidadEmpleado = @IDIncapacidadEmpleado)  
				BEGIN  
					raiserror('No existe la incapacidad!',16,1);  
					return;  
				END;  
			
				select @OldJSON = a.JSON from [Asistencia].[tblIncapacidadEmpleado] b
				Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
				WHERE b.IDIncapacidadEmpleado = @IDIncapacidadEmpleado

				update [Asistencia].[tblIncapacidadEmpleado]  
				set   
						Numero					= @Numero  
					,Fecha					= @Fecha  
					,Duracion				= @Duracion  
					,IDTipoIncapacidad		= @IDTipoIncapacidad  
					,IDClasificacionIncapacidad	= case when @IDClasificacionIncapacidad = 0 then null else @IDClasificacionIncapacidad end
					,PagoSubsidioEmpresa		= @PagoSubsidioEmpresa  
					,IDTipoLesion				= case when @IDTipoLesion = 0 then null else @IDTipoLesion end
					,Hora		= NULL  
					,Dia		= NULL  
					,IDTipoRiesgoIncapacidad	= case when @IDTipoRiesgoIncapacidad = 0 then null else @IDTipoRiesgoIncapacidad end
					,Permanente					= @Permanente  
				where IDIncapacidadEmpleado		= @IDIncapacidadEmpleado  

					select @NewJSON = a.JSON from [Asistencia].[tblIncapacidadEmpleado] b
				Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
				WHERE b.IDIncapacidadEmpleado = @IDIncapacidadEmpleado

				EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblIncapacidadEmpleado]','[Asistencia].[spIUIncapacidadEmpleado]','UPDATE',@NewJSON,@OldJSON
			end;  
		end

		/* Insertar Incapacidad en Asistencia.TblIncidenciaEmpleado */  
		delete ie
		from [Asistencia].[tblIncidenciaEmpleado] ie
			join @Fechas fecha on ie.Fecha = fecha.Fecha
		where ie.IDIncapacidadEmpleado = @IDIncapacidadEmpleado; 
        
  
		MERGE [Asistencia].[TblIncidenciaEmpleado] AS TARGET  
		USING @Fechas as SOURCE  
		on TARGET.Fecha = SOURCE.Fecha and (TARGET.IDEmpleado = @IDEmpleado) and TARGET.IDIncidencia not in (select IDIncidencia from #tempIncidencias)   
		WHEN MATCHED THEN  
			update   
			set TARGET.IDIncidencia			= 'I'      
			,TARGET.TiempoSugerido			= null  
			,TARGET.TiempoAutorizado		= null  
			,TARGET.Comentario				='Número de Incapacidad: '+COALESCE(@Numero,'')   
			,TARGET.ComentarioTextoPlano	='Número de Incapacidad: '+COALESCE(@Numero,'')   
			,TARGET.CreadoPorIDUsuario		= @IDUsuario  
			,TARGET.Autorizado				= 1  
			,TARGET.AutorizadoPor			= @IDUsuario  
			,TARGET.FechaHoraAutorizacion	= getdate()      
			,TARGET.IDIncapacidadEmpleado	= @IDIncapacidadEmpleado  
      
		WHEN NOT MATCHED BY TARGET  and SOURCE.Fecha <= @FechaFin THEN   
    
		INSERT(IDEmpleado,IDIncidencia,Fecha,TiempoSugerido,TiempoAutorizado,Comentario,ComentarioTextoPlano,CreadoPorIDUsuario  
			,Autorizado,AutorizadoPor,FechaHoraAutorizacion,IDIncapacidadEmpleado)  
		values(@IDEmpleado  
			,'I'  
			,SOURCE.Fecha      
			,null  
			,null  
			,'Número de Incapacidad: '+COALESCE(@Numero,'')  
			,'Número de Incapacidad: '+COALESCE(@Numero,'')  
			,@IDUsuario  
			,1  
			,@IDUsuario  
			,getdate()      
			,@IDIncapacidadEmpleado)  
		;  

		COMMIT
	end try
	begin catch
		ROLLBACK;

		set @MessageText = ERROR_MESSAGE();

		RAISERROR(
			@MessageText, -- Message text
			16, -- severity
			1 -- state
		); 

		return;

		--select ERROR_MESSAGE()
		--		,ERROR_PROCEDURE()
		--		,ERROR_NUMBER()
	end catch
    --while (@Duracion > 0)  
    --BEGIN  
    --INSERT INTO [Asistencia].[tblIncidenciaEmpleado](IDEmpleado,IDIncidencia,Fecha  
    --,TiempoSugerido,TiempoAutorizado,Comentario,ComentarioTextoPlano,CreadoPorIDUsuario  
    --,Autorizado,AutorizadoPor,FechaHoraAutorizacion,FechaHoraCreacion,IDIncapacidadEmpleado)  
    --select @IDEmpleado     
    --   ,'I'     
    --   ,@Fecha      
    --   ,null    
    --   ,NULL           
    --   ,'Número de Incapacidad: '+COALESCE(@Numero,'')   
    --   ,'Número de Incapacidad: '+COALESCE(@Numero,'')   
    --   ,@IDUsuario    
    --   ,1     
    --   ,@IDUsuario     
    --   ,getdate()  
    --   ,getdate()  
    --   ,@IDIncapacidadEmpleado  
  
    --select @fecha = dateadd(day,1,@Fecha)  
    --  ,@Duracion = @Duracion  -1 ;  
    --end;
GO

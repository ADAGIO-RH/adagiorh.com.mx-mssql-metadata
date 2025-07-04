USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spIUVacacionesEmpleados](     
	 @IDIncidenciaEmpleado int  = 0
	,@IDEmpleado int      
	,@IDIncidencia varchar(10) = 'V'     
	,@Fecha date     
	,@Duracion int      
	,@DiasDescanso varchar(20)      
	,@Comentario varchar(max)	
    ,@ConfirmarActualizar	bit = 1
    ,@TipoRespuesta         int = 0 OUTPUT
	,@IDUsuario int     
) as    
    SET DATEFIRST 7;    
    

	if ((select Sum(cast(item as int))
		from App.split(@DiasDescanso, ',')) = 28)
	begin
        exec [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0611003'
		return
	end

	declare
		@IDCliente int
		,@CALENDARIO0007 bit=0
		,@InsertSS bit = 0
        ,@CALENDARIO0006 bit = 0 --Guardar Vacaciones sin realizar validaciones
		,@Fechas [App].[dtFechasFull]    
		,@IDIdioma Varchar(5)    
		,@IdiomaSQL varchar(100) = null    
		,@FechaFin date = dateadd(day,@Duracion-1,@Fecha)
		--,@FechaFin date = dateadd(day,@Duracion,@Fecha)   
		
		,@SumarDiasDescanso int = 0
		,@SumarDiasFestivos int = 0 
		,@Festivos [App].[dtFechasFull]
		,@i int = 1  
		,@CALENDARIO0002 bit = 0 --No Modificar calendario de días anteriores(Permite modificar el día actual)'
		,@CALENDARIO0003 bit = 0 --No Modificar calendraio de mañana en adelante')
        
		,@DIAS_MODIFICAR_CALENDARIO int = 0 --Cantidad de días previos para modificar Calendario
		,@DIAS_MODIFICAR_CALENDARIO_DIAS int = 0
		,@DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA date
		,@Message varchar(max)
		,@IDPais int
		,@OldJSON Varchar(Max)
		,@NewJSON Varchar(Max)

		,@tblTempVacaciones [Asistencia].[dtSaldosDeVacaciones]
	; 

    

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')

	select @IdiomaSQL = [SQL]
	from app.tblIdiomas with (nolock)
	where IDIdioma = @IDIdioma

	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
	begin
		set @IdiomaSQL = 'Spanish' ;
	end
  
	SET LANGUAGE @IdiomaSQL    

    select @IDCliente = IDCliente 
    from rh.tblEmpleadosMaster 		
    where IDEmpleado = @IDEmpleado
        
    Select @InsertSS = Valor
    from RH.TblConfiguracionesCliente 
	where IDCliente = @IDCliente
        and IDTipoConfiguracionCliente = 'InsertarVacacionesSinSaldo'
    
    if exists(select top 1 1 
			from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'CALENDARIO0006')
		begin
			set @CALENDARIO0006 = 1
		end;

	if exists(select top 1 1 
	from [Seguridad].[vwPermisosEspecialesUsuarios] pes	
		join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
	where pes.IDUsuario = @IDUsuario and pes.TienePermiso = 1 and cpe.Codigo = 'CALENDARIO0007')
	begin
		set @CALENDARIO0007 = 1
    end;

    if (@CALENDARIO0007 = 0)
	begin
		if (@IDEmpleado = (isnull((SELECT IDEmpleado from Seguridad.tblUsuarios where IDUsuario = @IDUsuario),0)))
		begin
			
            set @Message = FORMATMESSAGE('No tienes permiso para modificar su propio calendario.')
			raiserror(@Message,16,1)
			return;			
		end
	end


    IF(@InsertSS = 0 and @CALENDARIO0006 = 0)
    BEGIN

        insert into @tblTempVacaciones
        exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado,NUll,@Fecha,@IDUsuario

        declare @DiasDisponibles int = 0
        		
        select @DiasDisponibles = floor(sum(DiasDisponibles)) from @tblTempVacaciones
     	
		if (isnull(@DiasDisponibles,0) < @Duracion)
		begin
			raiserror('No tienes saldos disponibles en esta fecha.', 16, 1)
			return
		end
    END

    

    select @IDPais=CTN.IDPais
    FROM RH.tblEmpleadosMaster MAS WITH(nolock)
		INNER JOIN Nomina.tblCatTipoNomina CTN WITH(nolock) ON MAS.IDTipoNomina=CTN.IDTipoNomina
    WHERE MAS.IDEmpleado=@IDEmpleado

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
			set @Message = FORMATMESSAGE('No tienes permiso para crear vacaciones mayores a %d dias previos.', @DIAS_MODIFICAR_CALENDARIO_DIAS)
			raiserror(@Message,16,1)
			return;
		end
	end
  
    if object_id('tempdb..#TempLista') is not null drop table #TempLista;    
    
    create table #TempLista(    
		Fecha date    
		,ID varchar(10)    
    )    
      
    insert into @Fechas(Fecha)
    exec [App].[spListaFechas]
		@FechaIni = @Fecha
	   , @FechaFin = @FechaFin

    select @SumarDiasDescanso=count(*)
    from @Fechas f
	   join (
		  SELECT cast(item as int) as item
		  from [App].[Split](@DiasDescanso,',') ) as dd on f.DiaSemana = cast(dd.item as int)  
	
	set @i = 1;
	
	while (@i <= @SumarDiasDescanso)
	begin
		set @FechaFin = dateadd(day,1,@FechaFin)
		if not (DATEPART(DW,@FechaFin) in (
			  SELECT cast(item as int) as item
			  from [App].[Split](@DiasDescanso,',') ) )
		begin
			set @i = @i + 1;
		end;
	end; 


    delete from @Fechas;

	insert into @Fechas(Fecha)
    exec [App].[spListaFechas]
		@FechaIni = @Fecha
	   , @FechaFin = @FechaFin

    insert @Festivos(Fecha)
	select f.Fecha
	from Asistencia.TblCatDiasFestivos df
		join @Fechas f on df.Fecha = F.Fecha and df.IDPais = @IDPais
	where df.Autorizado = 1 and (DATEPART(DW,df.Fecha)) NOT IN (SELECT cast(item as int) as item from [App].[Split](@DiasDescanso,',') )

	select @SumarDiasFestivos = COUNT(*)
	from @Festivos

	set @i = 1;
	while (@i <= @SumarDiasFestivos)
	begin
		set @FechaFin = dateadd(day,1,@FechaFin)
		if not (DATEPART(DW,@FechaFin) in (
			  SELECT cast(item as int) as item
			  from [App].[Split](@DiasDescanso,',') ))
		begin
            if not exists (Select * from Asistencia.TblCatDiasFestivos where Fecha = @FechaFin and IDPais = @IDPais)
            begin
			set @i = @i + 1;
            end
		end;
	end; 

    delete from @Fechas;

    insert into @Fechas(Fecha)
    exec [App].[spListaFechas]
		@FechaIni = @Fecha
	   , @FechaFin = @FechaFin

	delete fecha
	from @Fechas fecha
		join Asistencia.TblCatDiasFestivos f on fecha.Fecha = f.Fecha and IDPais = @IDPais  
   
    IF EXISTS(Select * from @Fechas
	          where Fecha < case when @CALENDARIO0002 = 1 then cast(GETDATE() as date) else '1900-01-01' end)
    BEGIN
     set @Message = FORMATMESSAGE('No tienes permiso para modificar el calendario en dias anteriores')
			raiserror(@Message,16,1)
			return;   
    END

    IF EXISTS(Select * from @Fechas
	          where Fecha < case when @CALENDARIO0003 = 1 then cast(dateadd(day,1,GETDATE()) as date) else '1900-01-01' end)
    BEGIN
     set @Message = FORMATMESSAGE('No tienes permiso para modificar el calendario, solo de mañana en adelante')
			raiserror(@Message,16,1)
			return;   
    END


    insert into #TempLista(Fecha, ID)    
    select Fecha    
      ,ID = case when DiaSemana in (SELECT cast(item as int) from [App].[Split](@DiasDescanso,',') ) then 'D' else @IDIncidencia end    
    from @Fechas 
    
    select @FechaFin=max(Fecha)    
    from @Fechas    
    where DiaSemana not in  (SELECT cast(item as int) as item    
							from [App].[Split](@DiasDescanso,',') )  


    
	select @OldJSON = a.JSON from (select @IDEmpleado as IDEmpleado, @Fecha as Fecha, @Duracion as Duracion, @DiasDescanso as DiasDescanso, @IDIncidencia as IDIncidencia) b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a


    --Vacaciones Vencidas Pagadas
    IF(@IDIncidencia =  'VP')
    BEGIN
        insert into @tblTempVacaciones
        exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado
    
        DECLARE
        @FechaFinDisponibleMax DATE
        ,@DiasVencidos int

        Select top 1 @FechaFinDisponibleMax = FechaFinDisponible from @tblTempVacaciones where DiasVencidos > 0 order by FechaFinDisponible DESC

        Select @DiasVencidos = SUM(DiasVencidos) from @tblTempVacaciones 

        IF EXISTS(Select * from @Fechas
                where Fecha > @FechaFinDisponibleMax) 
        BEGIN
            set @Message = FORMATMESSAGE('No se pueden insertar vacaciones Vencidas en Periodos de Vacaciones Vigentes')
                    raiserror(@Message,16,1)
                    return;   
        END

        IF (ISNULL(@DiasVencidos,0) < @Duracion) 
        BEGIN
            set @Message = FORMATMESSAGE('La duracion excede el numero de dias vencidos en el historial de vacaciones del colaborador, no se puede insertar.')
                    raiserror(@Message,16,1)
                    return;   
        END

    END

    DECLARE @InsertedIdentities 
        TABLE(
           ActionType NVARCHAR(10)
            ,IDIncidenciaEmpleado INT
             ,Fecha DATE
             ,IDIncidencia varchar(69));

     declare @Mensaje VARCHAR(max),
    	    @EsAusentismo bit
            
        
        select @EsAusentismo = EsAusentismo
	    from [Asistencia].[tblCatIncidencias] with (nolock)
	    where IDIncidencia = @IDIncidencia

        IF (
			(EXISTS (SELECT TOP 1 1 
					FROM [Asistencia].[tblIncidenciaEmpleado] ei with (nolock) 
						JOIN @Fechas f on ei.Fecha =  f.Fecha
						JOIN [Asistencia].[tblCatIncidencias] i with (nolock) on ei.IDIncidencia = i.IDIncidencia
					 WHERE ei.IDEmpleado = @IDEmpleado                        
					--    AND ei.IDIncidencia <> @IDIncidencia 
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
                              --AND ie.IDIncidencia <> @IDIncidencia 
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


	MERGE [Asistencia].[TblIncidenciaEmpleado] AS TARGET    
    USING #TempLista as SOURCE    
		on TARGET.Fecha = SOURCE.Fecha and (TARGET.IDEmpleado = @IDEmpleado) 
			and TARGET.IDIncidencia in (select IDIncidencia from Asistencia.tblCatIncidencias where isnull(EsAusentismo, 0) = 1)
    WHEN MATCHED and TARGET.Fecha <= @FechaFin THEN    
		update     
			set 
				TARGET.IDIncidencia = SOURCE.ID    
				,TARGET.CreadoPorIDUsuario = @IDUsuario    
				,TARGET.Autorizado   = 1    
				,TARGET.AutorizadoPor  = @IDUsuario    
				,TARGET.FechaHoraAutorizacion = getdate() 


                
    WHEN NOT MATCHED BY TARGET and SOURCE.Fecha <= @FechaFin THEN     
    INSERT(IDEmpleado,IDIncidencia,Fecha, Comentario, ComentarioTextoPlano,CreadoPorIDUsuario,Autorizado,AutorizadoPor,FechaHoraAutorizacion)    
    values(@IDEmpleado, SOURCE.ID, SOURCE.Fecha, @Comentario, @Comentario,@IDUsuario,1,@IDUsuario,Getdate())  
    OUTPUT
     COALESCE(case when inserted.IDincidenciaEmpleado is null then 'INSERT' END , case when deleted.IDincidenciaEmpleado is not null then 'UPDATE' END) AS ActionType
     ,inserted.IDIncidenciaEmpleado
     ,inserted.Fecha 
     ,inserted.IDIncidencia 
    INTO @InsertedIdentities;    

   

    IF EXISTS(Select top 1 1 from app.tblConfiguracionesGenerales CG where IDConfiguracion = 'RefactorizacionVacaciones' and Valor = 1)
    BEGIN
    DECLARE @RowCountIncidencia INT = (SELECT COUNT(*) FROM @InsertedIdentities)
            ,@IDIncidenciaEmpleadoTemp int
            ,@IDMovAfiliatorio int 
            ,@IDSaldoVacacionEmpleado int;


        SELECT 
		    @IDMovAfiliatorio = mov.IDMovAfiliatorio
	    FROM IMSS.tblMovAfiliatorios Mov WITH(NOLOCK)
		INNER JOIN RH.tblEmpleadosMaster  M WITH(NOLOCK)
			ON Mov.IDEmpleado = M.IDEmpleado
			AND Mov.Fecha = M.FechaAntiguedad
		WHERE M.IDEmpleado = @IDEmpleado

            WHILE (@RowCountIncidencia > 0)
            BEGIN

                SELECT 
                    @IDIncidenciaEmpleadoTemp = IDIncidenciaEmpleado
                FROM @InsertedIdentities WHERE IDIncidencia IN( 'V' , 'VP') AND ActionType is null
                ORDER BY Fecha DESC OFFSET @RowCountIncidencia - 1 ROWS FETCH NEXT 1 ROWS ONLY;
                    
                SELECT 
                    TOP 1 @IDSaldoVacacionEmpleado = IDSaldoVacacionEmpleado
                FROM Asistencia.tblSaldoVacacionesEmpleado SVE with(nolock)
                INNER JOIN @InsertedIdentities IE 
					ON IE.Fecha <= SVE.FechaFinDisponible AND IE.IDIncidenciaEmpleado = @IDIncidenciaEmpleadoTemp AND ie.IDIncidencia in('V', 'VP') AND ActionType is null
                WHERE SVE.IDEmpleado = @IDEmpleado 
						And SVE.IDMovAfiliatorio = @IDMovAfiliatorio 
						AND SVE.IDincidenciaEmpleado IS NULL 
						AND SVE.IDAjusteSaldo IS NULL
                ORDER BY SVE.FechaInicioDisponible ASC           

                Update Asistencia.tblSaldoVacacionesEmpleado
                    Set IDIncidenciaEmpleado = @IDIncidenciaEmpleadoTemp
                Where IDSaldoVacacionEmpleado = @IDSaldoVacacionEmpleado
                
                set @RowCountIncidencia -= 1 
    END

END
    SELECT 0 AS ID
				,0 AS TipoEvento
				,'Las vacaciones se craron correctamente'  AS Mensaje
				,0 AS TipoRespuesta
                
	EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[TblIncidenciaEmpleado]','[Asistencia].[spIUVacacionesEmpleados]','MERGE','',@OldJson
GO

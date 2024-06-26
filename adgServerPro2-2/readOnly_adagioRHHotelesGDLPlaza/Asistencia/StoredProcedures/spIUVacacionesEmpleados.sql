USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spIUVacacionesEmpleados](     
	@IDIncidenciaEmpleado int  = 0
	,@IDEmpleado int      
	,@Fecha date     
	,@Duracion int      
	,@DiasDescanso varchar(20)      
	,@IDUsuario int     
) as    
    SET DATEFIRST 7;    
  --  set @Duracion = (@Duracion - 1);    
    
	declare 
		@Fechas [App].[dtFechas]    
		,@IDIdioma Varchar(5)    
		,@IdiomaSQL varchar(100) = null    
		,@FechaFin date = dateadd(day,@Duracion-1,@Fecha)
		--,@FechaFin date = dateadd(day,@Duracion,@Fecha)   
		
		,@SumarDiasDescanso int = 0
		,@SumarDiasFestivos int = 0 
		,@Festivos [App].[dtFechas]
		,@i int = 1  
		,@CALENDARIO0002 bit = 0 --No Modificar calendario de días anteriores(Permite modificiar el día actual)'
		,@CALENDARIO0003 bit = 0 --No Modificar calendraio de mañana en adelante')
		,@DIAS_MODIFICAR_CALENDARIO int = 0 -- Cantidad de días previos para modificar Calendario
		,@DIAS_MODIFICAR_CALENDARIO_DIAS int = 0
		,@DIAS_MODIFICAR_CALENDARIO_FECHA_MINIMA date
		,@Message varchar(max)
		,@IdSucursalEmpleado int = 0
	;    

	BEGIN -- Permisos de calendario
		if exists(select top 1 1 
			from Seguridad.tblPermisosEspecialesUsuarios pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and cpe.Codigo = 'CALENDARIO0002')
		begin
			set @CALENDARIO0002 = 1
		end;

		if exists(select top 1 1 
			from Seguridad.tblPermisosEspecialesUsuarios pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and cpe.Codigo = 'CALENDARIO0003')
		begin
			set @CALENDARIO0003 = 1
		end;

		if exists(select top 1 1 
			from Seguridad.tblPermisosEspecialesUsuarios pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and cpe.Codigo = 'DIAS_MODIFICAR_CALENDARIO')
		begin
			set @DIAS_MODIFICAR_CALENDARIO = 1

			select @DIAS_MODIFICAR_CALENDARIO_DIAS = CAST(isnull(cpe.[Data], 0) as int)
			from Seguridad.tblPermisosEspecialesUsuarios pes	
				join App.tblCatPermisosEspeciales cpe on pes.IDPermiso = cpe.IDPermiso
			where pes.IDUsuario = @IDUsuario and cpe.Codigo = 'DIAS_MODIFICAR_CALENDARIO'
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
    
    select top 1 @IDIdioma = dp.Valor    
    from Seguridad.tblUsuarios u    
		Inner join App.tblPreferencias p on u.IDPreferencia = p.IDPreferencia    
		Inner join App.tblDetallePreferencias dp on dp.IDPreferencia = p.IDPreferencia    
		Inner join App.tblCatTiposPreferencias tp on tp.IDTipoPreferencia = dp.IDTipoPreferencia    
	where u.IDUsuario = @IDUsuario and tp.TipoPreferencia = 'Idioma'    
    
    select @IdiomaSQL = [SQL]    
    from app.tblIdiomas    
    where IDIdioma = @IDIdioma    
    
    if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)    
    begin    
		set @IdiomaSQL = 'Spanish' ;    
    end    
      
    SET LANGUAGE @IdiomaSQL;  
	
	select @IdSucursalEmpleado = IdSucursal from rh.tblsucursalempleado where idempleado = @idempleado and FechaFin >= @FechaFin
    
    insert into @Fechas(Fecha)
    exec [App].[spListaFechas]
		@FechaIni = @Fecha
	   , @FechaFin = @FechaFin

	insert @Festivos(Fecha)
	select f.Fecha
	from Asistencia.TblCatDiasFestivos df
		join @Fechas f on df.Fecha = F.Fecha
	where df.Autorizado = 1

	if(@IdSucursalEmpleado = 1 or @IdSucursalEmpleado = 2)
	begin
		delete from @Festivos where (day(Fecha) = 8 and month(Fecha) = 10 ) or (day(Fecha) = 12 and month(Fecha) = 12 )
	end
	

	select @SumarDiasFestivos = COUNT(*)
	from @Festivos

	set @i = 1;
	while (@i <= @SumarDiasFestivos)
	begin
		set @FechaFin = dateadd(day,1,@FechaFin)
		if not (DATEPART(DW,DATEADD(day,1,@FechaFin)) in (
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

    select @SumarDiasDescanso=count(*)
    from @Fechas f
	   join (
		  SELECT cast(item as int) as item
		  from [App].[Split](@DiasDescanso,',') ) as dd on f.DiaSemana = cast(dd.item as int)  


	set @i = 1;
	while (@i <= @SumarDiasDescanso)
	begin
		set @FechaFin = dateadd(day,1,@FechaFin)
		if not (DATEPART(DW,DATEADD(day,1,@FechaFin)) in (
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
    
	delete fecha
	from @Fechas fecha
		join @Festivos f on fecha.Fecha = f.Fecha

	DELETE from @Fechas
	where (Fecha < case when @CALENDARIO0002 = 1 then cast(GETDATE() as date) else '1900-01-01' end)
		or (Fecha < case when @CALENDARIO0003 = 1 then cast(dateadd(day,1,GETDATE()) as date) else '1900-01-01' end)

    insert into #TempLista(Fecha, ID)    
    select Fecha    
      ,ID = case when DiaSemana in (SELECT cast(item as int) from [App].[Split](@DiasDescanso,',') ) then 'D' else 'V' end    
    from @Fechas 
    
    select @FechaFin=max(Fecha)    
    from @Fechas    
    where DiaSemana not in  (SELECT cast(item as int) as item    
							from [App].[Split](@DiasDescanso,',') )    
DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max);

	select @OldJSON = a.JSON from (select @IDEmpleado as IDEmpleado, @Fecha as Fecha, @Duracion as Duracion, @DiasDescanso as DiasDescanso, 'V' as IDIncidencia) b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a



    MERGE [Asistencia].[TblIncidenciaEmpleado] AS TARGET    
    USING #TempLista as SOURCE    
		on TARGET.Fecha = SOURCE.Fecha and (TARGET.IDEmpleado = @IDEmpleado)    
    WHEN MATCHED and TARGET.Fecha <= @FechaFin THEN    
		update     
		set 
			TARGET.IDIncidencia = SOURCE.ID    
			,TARGET.CreadoPorIDUsuario = @IDUsuario    
			,TARGET.Autorizado   = 1    
			,TARGET.AutorizadoPor  = @IDUsuario    
			,TARGET.FechaHoraAutorizacion = getdate()      
    WHEN NOT MATCHED BY TARGET  and SOURCE.Fecha <= @FechaFin THEN     
    INSERT(IDEmpleado,IDIncidencia,Fecha,CreadoPorIDUsuario,Autorizado,AutorizadoPor,FechaHoraAutorizacion)    
    values(@IDEmpleado, SOURCE.ID, SOURCE.Fecha,@IDUsuario,1,@IDUsuario,Getdate())    
    ;    
    
	 EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[TblIncidenciaEmpleado]','[Asistencia].[spIUVacacionesEmpleados]','MERGE','',@OldJson
GO

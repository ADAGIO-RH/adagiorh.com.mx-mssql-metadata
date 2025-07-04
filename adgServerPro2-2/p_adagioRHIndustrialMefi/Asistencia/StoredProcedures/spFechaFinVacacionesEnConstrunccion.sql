USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spFechaFinVacacionesEnConstrunccion](
   @Fecha date 
    ,@Duracion int  
    ,@DiasDescanso varchar(20)  
    ,@IDUsuario int 
)
as
	SET DATEFIRST 7;

	--set @Duracion = (@Duracion - 1);
    
    declare 
		@Fechas [App].[dtFechasFull]
		,@IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null
		,@FechaFin date = dateadd(day,@Duracion-1,@Fecha)
		,@SumarDiasDescanso int = 0 
		,@SumarDiasFestivos int = 0 
		,@Festivos [App].[dtFechasFull]
		,@i int = 1
	;

	--if (DATEPART(DW,DATEADD(day,1,@FechaFin)) in (
	--	  SELECT cast(item as int) as item
	--	  from [App].[Split](@DiasDescanso,',') ) )
	--begin
	--	while (DATEPART(DW,@FechaFin) in (
	--		  SELECT cast(item as int) as item
	--		  from [App].[Split](@DiasDescanso,',') ) )
	--	begin
	--		set @FechaFin = dateadd(day,1,@FechaFin)
	--	end;
	--end

	--select @FechaFin as FechaFinInicial

    if object_id('tempdb..#TempLista') is not null drop table #TempLista;

    create table #TempLista(
	   Fecha date
	   ,ID varchar(10)
    )

    select top 1 @IDIdioma = dp.Valor
    from Seguridad.tblUsuarios u
	   Inner join App.tblPreferencias p
		  on u.IDPreferencia = p.IDPreferencia
	   Inner join App.tblDetallePreferencias dp
		  on dp.IDPreferencia = p.IDPreferencia
	   Inner join App.tblCatTiposPreferencias tp
		  on tp.IDTipoPreferencia = dp.IDTipoPreferencia
	   where u.IDUsuario = @IDUsuario
		  and tp.TipoPreferencia = 'Idioma'

    select @IdiomaSQL = [SQL]
    from app.tblIdiomas
    where IDIdioma = @IDIdioma

    if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
    begin
	   set @IdiomaSQL = 'Spanish' ;
    end
  
    SET LANGUAGE @IdiomaSQL;

    insert into @Fechas(Fecha)
    exec [App].[spListaFechas]
		@FechaIni = @Fecha
	   , @FechaFin = @FechaFin

	insert @Festivos(Fecha)
	select f.Fecha
	from Asistencia.TblCatDiasFestivos df
		join @Fechas f on df.Fecha = F.Fecha
	where df.Autorizado = 1

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

	--select @SumarDiasFestivos as SumarDiasFestivos,@FechaFin as FechaFin
	--set @FechaFin = dateadd(day,@SumarDiasFestivos,@FechaFin)
	--select @SumarDiasFestivos as SumarDiasFestivos,@FechaFin as FechaFin

	--while (
	--		(DATEPART(DW,@FechaFin) in (
	--		  SELECT cast(item as int) as item
	--		  from [App].[Split](@DiasDescanso,',') ) )

	--		or 

	--		 (DATEPART(DW,DATEADD(day,1,@FechaFin)) in (
	--	  SELECT cast(item as int) as item
	--	  from [App].[Split](@DiasDescanso,',') ) )
	--	 )
	--begin
	--	set @FechaFin = dateadd(day,1,@FechaFin)
	--	print 'Fecha fin dentro primer While'
	--	print @FechaFin
	--end;

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

    --set @FechaFin = dateadd(day,(@SumarDiasDescanso-1),@FechaFin)

	print 'Fecha fin antes segundo While'
	print @FechaFin

	--while (
	--		(DATEPART(DW,@FechaFin) in (
	--	  SELECT cast(item as int) as item
	--	  from [App].[Split](@DiasDescanso,',') ) )

	--	  or 

	--		 (DATEPART(DW,DATEADD(day,1,@FechaFin)) in (
	--	  SELECT cast(item as int) as item
	--	  from [App].[Split](@DiasDescanso,',') ) )
	--	 )
	--begin
	--	set @FechaFin = dateadd(day,1,@FechaFin)

	--	print 'Fecha fin dentro segundo While'
	--	print @FechaFin
	--end;

    delete from @Fechas;

    insert into @Fechas(Fecha)
    exec [App].[spListaFechas]
		@FechaIni = @Fecha
	   , @FechaFin = @FechaFin
    
    select isnull(max(Fecha),dateadd(day,-1,@FechaFin)) as FechaFin
    from @Fechas
    where DiaSemana not in  (
						  SELECT cast(item as int) as item
						  from [App].[Split](@DiasDescanso,',') )
		  and 
		  Fecha not in (
			select Fecha
			from @Festivos
		  )
GO

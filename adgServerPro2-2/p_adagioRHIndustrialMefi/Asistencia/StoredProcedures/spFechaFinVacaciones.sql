USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Calcula las fechas a asignar las vacaciones considerantes días de descanso y días festivos
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2018-01-01
** Paremetros		: 

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2019-11-27			Aneudy Abreu		Se agregó la validación de días festivos para que no sean incluidos
										o contemplados en los días de vacaciones.

	[Asistencia].[spFechaFinVacaciones] 
		@Fecha			= '2020-12-14'
		,@Duracion		= 3
		,@DiasDescanso	= '1,7'
		,@IDUsuario		= 1
***************************************************************************************************/
CREATE proc [Asistencia].[spFechaFinVacaciones](
	@IDEmpleado int
    ,@Fecha date 
    ,@Duracion int  
    ,@DiasDescanso varchar(20)  
    ,@IDUsuario int 
)
as
	SET DATEFIRST 7;

	if ((select Sum(cast(item as int))
		from App.split(@DiasDescanso, ',')) = 28)
	begin
		--raiserror('No puedes seleccionar todos los días de la semana como días de descanso.', 16,1)
		exec [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0611003'
		return
	end

    declare 
		@Fechas [App].[dtFechasFull]
		,@IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null
		,@FechaFin date = dateadd(day,@Duracion-1,@Fecha)
		,@SumarDiasDescanso int = 0 
		,@SumarDiasFestivos int = 0 
		,@Festivos [App].[dtFechasFull]
		,@i int = 1
		,@intDiasDescanso int = 0
		,@IDPais int
	;

	select @IDPais = CTN.IDPais
    FROM RH.tblEmpleadosMaster MAS WITH(nolock)
		INNER JOIN NOMINA.tblCatTipoNomina CTN WITH(nolock) ON MAS.IDTipoNomina=CTN.IDTipoNomina
    WHERE MAS.IDEmpleado=@IDEmpleado

    if object_id('tempdb..#TempLista') is not null drop table #TempLista;

    create table #TempLista(
	   Fecha date
	   ,Incidencia varchar(10)
    )

    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')

    select @IdiomaSQL = [SQL]
    from App.tblIdiomas
    where IDIdioma = @IDIdioma

    if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
    begin
	   set @IdiomaSQL = 'Spanish' ;
    end
  
    SET LANGUAGE @IdiomaSQL;

    insert into #TempLista(Fecha)
    exec [App].[spListaFechas]
		@FechaIni = @Fecha
	   ,@FechaFin = @FechaFin

	update #TempLista 
	   set Incidencia = 'V'

	update  l 
		set l.Incidencia = 'DF'
	from #TempLista l
		inner join Asistencia.TblCatDiasFestivos df with(nolock) on l.Fecha = df.Fecha  and df.IDPais = @IDPais
	where df.Autorizado = 1

	update  l 
		set l.Incidencia = 'D'
	from #TempLista l
		inner join (
					SELECT cast(item as int) as item
					from [App].[Split](@DiasDescanso,',') 
				) descansos on DATEPART(DW,l.Fecha) = descansos.item
		
	While((select count(*) from #TempLista where Incidencia = 'V') <> @Duracion)
	BEGIN
		insert into #TempLista(Fecha)
		select DATEADD(DAY, 1 ,MAX(Fecha))
		from #TempLista

		update #TempLista 
			set Incidencia = 'V'
		
		update  l 
			set l.Incidencia = 'DF'
		from #TempLista l
			inner join Asistencia.TblCatDiasFestivos df with(nolock) on l.Fecha = df.Fecha  and df.IDPais = @IDPais
		where df.Autorizado = 1

		update  l 
			set l.Incidencia = 'D'
		from #TempLista l
			inner join (
					SELECT cast(item as int) as item
					from [App].[Split](@DiasDescanso,',') 
				) descansos on DATEPART(DW,l.Fecha) = descansos.item
	END

	select isnull(max(Fecha),dateadd(day,-1,@FechaFin)) as FechaFin
	from #TempLista
GO

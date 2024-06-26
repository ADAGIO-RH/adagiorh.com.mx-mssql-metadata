USE [readOnly_adagioRHHotelesGDLPlaza]
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
   @Fecha date 
    ,@Duracion int  
    ,@DiasDescanso varchar(20)  
    ,@IDUsuario int 
)
as
	--declare @Fecha date	= '2019-12-09'
	--	,@Duracion	int		= 10
	--	,@DiasDescanso varchar(20)  = '1,7'
	--	,@IDUsuario int =1 

	SET DATEFIRST 7;

	if ((select Sum(cast(item as int))
		from App.split(@DiasDescanso, ',')) = 28)
	begin
		raiserror('No puedes seleccionar todos los días de la semana como días de descanso.', 16,1)
		return
	end

	--set @Duracion = @Duracion  + (  SELECT count(*)
	--	  from [App].[Split](@DiasDescanso,','));
   -- select @Duracion
    declare 
		@Fechas [App].[dtFechas]
		,@IDIdioma Varchar(5)
		,@IdiomaSQL varchar(100) = null
		,@FechaFin date = dateadd(day,@Duracion-1,@Fecha)
		,@SumarDiasDescanso int = 0 
		,@SumarDiasFestivos int = 0 
		,@Festivos [App].[dtFechas]
		,@i int = 1
		,@intDiasDescanso int = 0
	;

    if object_id('tempdb..#TempLista') is not null drop table #TempLista;

    create table #TempLista(
	   Fecha date
	   ,Incidencia varchar(10)
    )

    select top 1 @IDIdioma = dp.Valor
    from Seguridad.tblUsuarios u
	   Inner join App.tblPreferencias p with(nolock)
		  on u.IDPreferencia = p.IDPreferencia
	   Inner join App.tblDetallePreferencias dp with(nolock)
		  on dp.IDPreferencia = p.IDPreferencia
	   Inner join App.tblCatTiposPreferencias tp with(nolock)
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

    insert into #TempLista(Fecha)
    exec [App].[spListaFechas]
		@FechaIni = @Fecha
	   , @FechaFin = @FechaFin

	   update #TempLista 
	   set Incidencia = 'V'


	   update  l 
		set l.Incidencia = 'DF'
	   from #TempLista l
		inner join Asistencia.TblCatDiasFestivos df with(nolock)
			on l.Fecha = df.Fecha
		where df.Autorizado = 1

		update  l 
		set l.Incidencia = 'D'
	   from #TempLista l
		inner join (
					SELECT cast(item as int) as item
					from [App].[Split](@DiasDescanso,',') ) descansos
			on DATEPART(DW,l.Fecha) = descansos.item

		
		
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
			inner join Asistencia.TblCatDiasFestivos df with(nolock)
				on l.Fecha = df.Fecha
			where df.Autorizado = 1

			update  l 
			set l.Incidencia = 'D'
		   from #TempLista l
			inner join (
						SELECT cast(item as int) as item
						from [App].[Split](@DiasDescanso,',') ) descansos
				on DATEPART(DW,l.Fecha) = descansos.item

			
		END


	select isnull(max(Fecha),dateadd(day,-1,@FechaFin)) as FechaFin
	from #TempLista
GO

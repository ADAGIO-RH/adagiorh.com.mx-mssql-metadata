USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Borrar vacaciones de un empleado por rango de fecha
** Autor			: Joseph Roman
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2019-01-01
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE proc [Asistencia].[spBorrarVacacionesEmpleadosMasivo](         
  @IDIncidenciaEmpleado int  = 0    
    ,@IDEmpleado int          
    ,@Fecha date         
    ,@Duracion int          
    ,@DiasDescanso varchar(20)          
    ,@IDUsuario int 
    ,@IDIncidencia varchar(5)        
    ) as        
        
    SET DATEFIRST 7;        
        
    declare 
        @Fechas [App].[dtFechasFull]        
        ,@IDIdioma Varchar(5)        
        ,@IdiomaSQL varchar(100) = null        
        ,@FechaFin date = dateadd(day,@Duracion,@Fecha)         
        ,@SumarDiasDescanso int = 0
    ;        
       
    if object_id('tempdb..#TempLista') is not null drop table #TempLista;        
        
    create table #TempLista(        
        Fecha date        
        ,ID varchar(10)        
    )        
        
    select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')

	select @IdiomaSQL = [SQL]
	from app.tblIdiomas with (nolock)
	where IDIdioma = @IDIdioma

	if (@IdiomaSQL is null or len(@IdiomaSQL) = 0)
	begin
		set @IdiomaSQL = 'Spanish' ;
	end
  
	SET LANGUAGE @IdiomaSQL    
        
    insert into @Fechas(Fecha)        
    exec [App].[spListaFechas]  @FechaIni = @Fecha, @FechaFin = @FechaFin        
        
    select @SumarDiasDescanso=count(*)        
    from @Fechas f        
        join (        
            SELECT cast(item as int) as item        
            from [App].[Split](@DiasDescanso,',') 
        ) as dd on f.DiaSemana =  cast(dd.item as int)          
        
    delete from @Fechas;        
    set @FechaFin = dateadd(day,(@Duracion+@SumarDiasDescanso) -1,@Fecha)        
        
    insert into @Fechas(Fecha)        
    exec [App].[spListaFechas] @FechaIni = @Fecha, @FechaFin = @FechaFin        
        
    insert into #TempLista(Fecha, ID)        
    select Fecha        
      ,ID = case when DiaSemana in (SELECT cast(item as int) from [App].[Split](@DiasDescanso,',') ) then 'D' else @IDIncidencia end        
    from @Fechas        
        
    select @FechaFin=max(Fecha)        
    from @Fechas        
    where DiaSemana not in  (        
    SELECT cast(item as int) as item        
    from [App].[Split](@DiasDescanso,',') )        
        
    MERGE [Asistencia].[TblIncidenciaEmpleado] AS TARGET        
    USING #TempLista as SOURCE        
		on TARGET.Fecha = SOURCE.Fecha 
			and (TARGET.IDEmpleado = @IDEmpleado)        
			and (TARGET.IDIncidencia = SOURCE.ID)        
    WHEN MATCHED and TARGET.Fecha <= @FechaFin and TARGET.IDEmpleado = @IDEmpleado THEN        
    DELETE       
    ;
GO

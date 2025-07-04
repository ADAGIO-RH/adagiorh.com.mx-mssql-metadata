USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Borrar Incidencias de empleados  
** Autor   : Joseph  
** Email   : ;jose.roman@adagio.com.mx  
** FechaCreacion : 2018-11-28   
   
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
***************************************************************************************************/  
 CREATE proc [Asistencia].[spBorrarIncidenciaEmpleadoMasivo](  
 @IDIncidenciaEmpleado   int  
    ,@IDEmpleado     int   
    ,@IDIncidencia     varchar(10)  
    ,@FechaIni date   
    ,@FechaFin date       
    ,@Dias varchar(20)   
    ,@TiempoSugerido    time  
    ,@TiempoAutorizado    time  
    ,@Comentario     nvarchar(max)  
    ,@ComentarioTextoPlano   nvarchar(max)  
    ,@CreadoPorIDUsuario    int   
    ,@Autorizado     bit   
    ,@ConfirmarActualizar bit = 0  
  
 ) as  
     SET DATEFIRST 7;  
  
    declare    
     @FechaHoraAutorizacion   datetime    
    --,@FechaHoraCreacion    datetime  
    ,@AutorizadoPor     int   
    ,@Fechas [App].[dtFechas]  
    ,@IDIdioma Varchar(5)  
    ,@IdiomaSQL varchar(100) = null  
    ,@Mensaje nvarchar(max)  
    ,@EsAusentismo bit;  
   
  
    select @EsAusentismo = EsAusentismo  
    from [Asistencia].[tblCatIncidencias] with (nolock)  
    where IDIncidencia = @IDIncidencia  

  
    select @FechaHoraAutorizacion = case WHEN @Autorizado = 1 then getdate() else null end  
      ,@AutorizadoPor = case WHEN @Autorizado = 1 then @CreadoPorIDUsuario else null end  
      ,@Comentario = case WHEN len(@Comentario) > 0 then @Comentario else null end  
      ,@ComentarioTextoPlano = case WHEN len(@ComentarioTextoPlano) > 0 then @ComentarioTextoPlano else null end  
    ;  
  
    select top 1 @IDIdioma = dp.Valor  
    from Seguridad.tblUsuarios u  
    Inner join App.tblPreferencias p  
    on u.IDPreferencia = p.IDPreferencia  
    Inner join App.tblDetallePreferencias dp  
    on dp.IDPreferencia = p.IDPreferencia  
    Inner join App.tblCatTiposPreferencias tp  
    on tp.IDTipoPreferencia = dp.IDTipoPreferencia  
    where u.IDUsuario = @CreadoPorIDUsuario  
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
  @FechaIni = @FechaIni  
    , @FechaFin = @FechaFin  
   
    DELETE from @Fechas  
    where DATEPART(dw,Fecha) NOT in (SELECT cast(item as int) from [App].[Split](@Dias,',') )  

  
    MERGE [Asistencia].[tblIncidenciaEmpleado] AS TARGET  
    USING @Fechas as SOURCE  
    on TARGET.Fecha = SOURCE.Fecha and (TARGET.IDEmpleado = @IDEmpleado)  
    and (TARGET.IDIncidencia = @IDIncidencia)  
    WHEN MATCHED THEN 
	Delete; 
   
    select 0 as ID  
    ,0 as TipoEvento  
    ,'Registros Borrados correctamente' as Mensaje  
    ,0 as TipoRespuesta
GO

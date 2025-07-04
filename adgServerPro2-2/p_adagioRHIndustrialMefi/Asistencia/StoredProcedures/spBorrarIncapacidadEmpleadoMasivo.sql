USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************     
** Descripción  : Borrar Incapacidad de empleados    
** Autor   : Aneudy    
** Email   : aneudy.abreu@adagio.com.mx    
** FechaCreacion : 2018-05-22        
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
2018-08-22  Aneudy Abreu  Se quitaron los parametros @IDCausaAccidente y @IDCorreccionAccidente    
***************************************************************************************************/    
  
  
CREATE proc [Asistencia].[spBorrarIncapacidadEmpleadoMasivo](    
 @IDIncapacidadEmpleado    int      
    ,@IDEmpleado      int      
    ,@Fecha       date     
    ,@Duracion    int     
    ,@IDUsuario int    
) as    
   
 DBCC TRACEOFF( 176,-1)  
        
declare @Fechas [App].[dtFechas]    
    ,@IDIdioma Varchar(5)    
    ,@IdiomaSQL varchar(100) = null    
    ,@FechaFin date = dateadd(day,@Duracion -1,@Fecha)     
    ;    

	 if object_id('tempdb..#tempIncapacidades') is not null  
		drop table #tempIncapacidades;  
    
    insert into @Fechas(Fecha)    
    exec [App].[spListaFechas]    
  @FechaIni = @Fecha    
    , @FechaFin = @FechaFin    

	select distinct IDIncapacidadEmpleado, IDIncidenciaEmpleado
		into #tempIncapacidades 
	from [Asistencia].[TblIncidenciaEmpleado]
		where IDEmpleado = @IDEmpleado
		and Fecha Between @Fecha and @FechaFin
		and IDIncidencia = 'I' 
    
    /* Insertar Incapacidad en Asistencia.TblIncidenciaEmpleado */    
    delete from [Asistencia].[tblIncidenciaEmpleado] where IDIncapacidadEmpleado in( select IDIncapacidadEmpleado From #tempIncapacidades);    
    delete from [Asistencia].[tblIncapacidadEmpleado] where IDIncapacidadEmpleado in( select IDIncapacidadEmpleado From #tempIncapacidades);
GO

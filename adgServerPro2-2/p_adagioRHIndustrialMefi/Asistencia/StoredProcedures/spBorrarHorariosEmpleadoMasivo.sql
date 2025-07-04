USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Borrar Horarios de los empleados  
** Autor   : Joseph  
** Email   : jose.roman@adagio.com.mx  
** FechaCreacion : 2018-11-28  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
***************************************************************************************************/  
  
CREATE proc [Asistencia].[spBorrarHorariosEmpleadoMasivo] (  
     @IDEmpleado int  
    ,@IDHorario int   
    ,@FechaIni date   
    ,@FechaFin date       
    ,@Dias varchar(20)   
    ,@IDUsuario int   
 ) as  
  
    SET DATEFIRST 7;  
  
    declare @Fechas [App].[dtFechas]  
    ,@IDIdioma Varchar(5)  
    ,@IdiomaSQL varchar(100) = null;  
   
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
  
    if not exists (SELECT top 1 *   
    from Asistencia.tblCatHorarios   
    where IDHorario = @IDHorario)   
    BEGIN  
    EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0611002'  
   -- return 0;  
    END;  
  
    insert into @Fechas(Fecha)  
    exec [App].[spListaFechas]  
  @FechaIni = @FechaIni  
    , @FechaFin = @FechaFin  
   
    DELETE from @Fechas  
    where DATEPART(dw,Fecha) NOT in (SELECT cast(item as int) from [App].[Split](@Dias,',') )  
      
    MERGE [Asistencia].[tblHorariosEmpleados] AS TARGET  
    USING @Fechas as SOURCE  
    on TARGET.Fecha = SOURCE.Fecha and (TARGET.IDEmpleado = @IDEmpleado)  
    WHEN MATCHED THEN  
    DELETE 
  
    --WHEN NOT MATCHED BY SOURCE and  (TARGET.IDEmpleado = @IDEmpleado) THEN   
    --DELETE  
    ;  
      
  
    --select *  
    --from [Asistencia].[tblHorariosEmpleados]  
    --select *  
    --from @Fechas
GO

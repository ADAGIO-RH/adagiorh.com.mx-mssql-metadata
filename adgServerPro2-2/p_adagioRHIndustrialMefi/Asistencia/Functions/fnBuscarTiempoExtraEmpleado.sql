USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****************************************************************************************************   
** Descripción  : Funcion que obtiene la cantidad de Tiempo Extra de Incidencia autirizadas de un empleado dentro de   
       un periodo de tiempo.  
** Autor   : Jose Roman  
** Email   : jose.roman@adagio.com.mx  
** FechaCreacion : 13-07-2018  
** Paremetros  :                
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
***************************************************************************************************/ 
CREATE FUNCTION [Asistencia].[fnBuscarTiempoExtraEmpleado]  
(  
 @IDEmpleado int,  
 @IDPeriodo int,  
 @FechaIni date,  
 @FechaFin date,  
 @HoraExtraTriple bit = 0  
)  
RETURNS Decimal(18,2)  
AS  
BEGIN  
  
DECLARE @Incidencias Decimal(18,2),  
  @PeriodicidadPago Varchar(50),  
  @Result Decimal(18,2);  
  
set @PeriodicidadPago = (  
     Select TOP 1 PP.Descripcion from Nomina.tblCatPeriodos p  
      Inner join Nomina.tblCatTipoNomina TN  
       on P.IDTipoNomina = TN.IDTipoNomina  
      Inner join Sat.tblCatPeriodicidadesPago PP  
       on PP.IDPeriodicidadPago = TN.IDPeriodicidadPago  
      WHERE P.IDPeriodo = @IDPeriodo  
    )  
  
  
  
 select @Result = CASE WHEN @HoraExtraTriple = 0 THEN   
				  CASE WHEN @PeriodicidadPago = 'Semanal' and ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0) <= 9 THEN  ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0)  
						 WHEN @PeriodicidadPago = 'Semanal' and ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0) > 9 THEN  9  
						 WHEN @PeriodicidadPago = 'Catorcenal' and ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0) <= 18 THEN  ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0)  
						 WHEN @PeriodicidadPago = 'Catorcenal' and ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0) > 18 THEN  18  
						 WHEN @PeriodicidadPago = 'Quincenal' and ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0) <= 18 THEN  ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0)  
						 WHEN @PeriodicidadPago = 'Quincenal' and ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0) > 18 THEN  18  
						 WHEN @PeriodicidadPago = 'Mensual' and ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0) <= 36 THEN  ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0)  
						 WHEN @PeriodicidadPago = 'Mensual' and ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0) > 36 THEN  36  
				 ELSE 0  
				 END   
      ELSE  
       CASE WHEN @PeriodicidadPago = 'Semanal' and ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0) <= 9 THEN  0  
        WHEN @PeriodicidadPago = 'Semanal' and ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0) > 9 THEN  ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0) - 9  
        WHEN @PeriodicidadPago = 'Catorcenal' and ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0) <= 18 THEN  0  
        WHEN @PeriodicidadPago = 'Catorcenal' and ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0) > 18 THEN  ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0) - 18  
        WHEN @PeriodicidadPago = 'Quicenal' and ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0) <= 18 THEN  0  
        WHEN @PeriodicidadPago = 'Quicenal' and ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0) > 18 THEN  ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0) - 18  
        WHEN @PeriodicidadPago = 'Mensual' and ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0) <= 36 THEN  0  
        WHEN @PeriodicidadPago = 'Mensual' and ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0) > 36 THEN  ISNULL(SUM(DatePArt(HOUR, TiempoAutorizado) + Datepart(MINUTE,TiempoAutorizado)),0) - 36  
        ELSE 0  
        END   
      END  
 From Asistencia.tblIncidenciaEmpleado IE  
  Inner join Asistencia.tblCatIncidencias I  
   on IE.IDIncidencia = I.IDIncidencia  
    
 Where IE.IDEmpleado = @IDEmpleado  
  AND I.IDIncidencia = 'EX'  
  AND IE.Fecha Between @FechaIni and @FechaFin  
  AND IE.Autorizado = 1;  
   
  
RETURN @Result;  
  
END
GO

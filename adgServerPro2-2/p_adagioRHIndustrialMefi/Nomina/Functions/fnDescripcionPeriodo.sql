USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION Nomina.fnDescripcionPeriodo  
(  
 @IDTipoNomina INT,  
 @FechaInicio DATE,  
 @FechaFin DATE  
)  
RETURNS VARCHAR(MAX)  
AS  
BEGIN  
   
 DECLARE @Descripcion VARCHAR(MAX),  
   @PerioricidadPago VArchar(50)  
  
 SET @PerioricidadPago = (SELECT top 1 pp.Descripcion FROM Nomina.tblCatTipoNomina tp  
           inner join sat.tblCatPeriodicidadesPago pp  
          on tp.IDPeriodicidadPago = pp.IDPeriodicidadPago  
            where tp.IDTipoNomina = @IDTipoNomina)  
   
 set @Descripcion = (select CASE WHEN @PerioricidadPago = 'Diario' then 'DIA DEL '+ CAST(FORMAT(cast(@FechaInicio as date),'dd-MM-yyyy') as varchar) +' AL '+CAST(FORMAT(cast(@FechaFin as date),'dd-MM-yyyy') as varchar) 
         WHEN @PerioricidadPago = 'Semanal' then 'SEMANA DEL '+ CAST(FORMAT(cast(@FechaInicio as date),'dd-MM-yyyy') as varchar) +' AL '+CAST(FORMAT(cast(@FechaFin as date),'dd-MM-yyyy') as varchar)  
         WHEN @PerioricidadPago = 'Catorcenal' then 'CATORCENA DEL '+ CAST(FORMAT(cast(@FechaInicio as date),'dd-MM-yyyy') as varchar) +' AL '+CAST(FORMAT(cast(@FechaFin as date),'dd-MM-yyyy') as varchar)   
         WHEN @PerioricidadPago = 'Quincenal' then 'QUINCENA DEL '+ CAST(FORMAT(cast(@FechaInicio as date),'dd-MM-yyyy') as varchar) +' AL '+CAST(FORMAT(cast(@FechaFin as date),'dd-MM-yyyy') as varchar)  
         WHEN @PerioricidadPago = 'Mensual' then 'MES DEL '+ CAST(FORMAT(cast(@FechaInicio as date),'dd-MM-yyyy') as varchar) +' AL '+CAST(FORMAT(cast(@FechaFin as date),'dd-MM-yyyy') as varchar)  
         WHEN @PerioricidadPago = 'Bimestral' then 'BIMESTRE DEL '+ CAST(FORMAT(cast(@FechaInicio as date),'dd-MM-yyyy') as varchar) +' AL '+CAST(FORMAT(cast(@FechaFin as date),'dd-MM-yyyy') as varchar)  
         WHEN @PerioricidadPago = 'Decenal' then 'DECENA DEL '+ CAST(FORMAT(cast(@FechaInicio as date),'dd-MM-yyyy') as varchar) +' AL '+CAST(FORMAT(cast(@FechaFin as date),'dd-MM-yyyy') as varchar) 
         ELSE 'OTRO DEL '+ CAST(FORMAT(cast(@FechaInicio as date),'dd-MM-yyyy') as varchar) +' AL '+CAST(FORMAT(cast(@FechaFin as date),'dd-MM-yyyy') as varchar)  
         END)  
 RETURN  @Descripcion;  
END
GO

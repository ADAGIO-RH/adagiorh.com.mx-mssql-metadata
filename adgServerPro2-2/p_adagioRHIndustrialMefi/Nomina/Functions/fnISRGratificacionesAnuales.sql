USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [Nomina].[fnISRGratificacionesAnuales]        
(        
         
 @IDPeriodicidadPago int ,        
 @TotalPercepciones Decimal(18,4),        
 @Ejercicio int,
 @IDPais int = 151
)        
RETURNS DECIMAL(18,4)        
AS        
BEGIN        
        
         
        
 DECLARE         
   @PeriodicidadesPago varchar(100),        
   @IDCalculo int,        
   @LimiteInferior DECIMAL(18,4),        
   @LimiteSuperior DECIMAL(18,4),        
   @CuotaFija DECIMAL(18,4),        
   @Porcentaje DECIMAL(18,4),        
   @totalImpuestos DECIMAL(18,4)        
        
 select top 1 @IDCalculo = IDCalculo         
 from Nomina.tblCatTipoCalculoISR        
 WHERE Codigo = 'ISR_SUELDOS'        
         
        
        
 SELECT TOP 1 @PeriodicidadesPago = pp.Descripcion         
     ,@PeriodicidadesPago = PP.Descripcion        
 FROM sat.tblCatPeriodicidadesPago PP        
 WHERE IDPeriodicidadPago = @IDPeriodicidadPago        
        
      
 --set @TotalPercepciones = ((@TotalPercepciones/@Dias)* case when @PeriodicidadesPago = 'Semanal'then  7      
 --               when @PeriodicidadesPago = 'Catorcenal' then 14      
 --               when @PeriodicidadesPago = 'Quincenal'  then 15      
 --               when @PeriodicidadesPago = 'Mensual'  then 30      
 --               when @PeriodicidadesPago = 'Decenal'  then 10      
 --               else 1      
 --               END)      
  --select @TotalPercepciones      
        
 SELECT @LimiteInferior = DTI.LimiteInferior,        
     @LimiteSuperior = DTI.LimiteSuperior,        
     @CuotaFija = DTI.CoutaFija,        
     @Porcentaje = DTI.Porcentaje,         
	 @PeriodicidadesPago = pp.Descripcion      
 FROM Nomina.tbltablasImpuestos  TI        
  INNER JOIN Nomina.tblDetalleTablasImpuestos DTI        
   on DTI.IDTablaImpuesto = TI.IDTablaImpuesto      
  inner join sat.tblCatPeriodicidadesPago pp      
 on ti.IDPeriodicidadPago = pp.IDPeriodicidadPago        
 WHERE TI.Ejercicio = @Ejercicio  
	AND TI.IDPais = @IDPais
	AND TI.IDCalculo = @IDCalculo        
	AND TI.IDPeriodicidadPago = @IDPeriodicidadPago        
	and @TotalPercepciones BETWEEN DTI.LimiteInferior and DTI.LimiteSuperior        
         
  --select @LimiteInferior as LimiteInferior    
  --, @CuotaFija as CuotaFija    
  --,@Porcentaje as Porcentaje    
  --, ( @TotalPercepciones - @LimiteInferior) as Excedente    
  --, (( @TotalPercepciones - @LimiteInferior) * @Porcentaje) as excedentePorPorcentaje    
  --, ((( @TotalPercepciones - @LimiteInferior) * @Porcentaje) + @CuotaFija) as formulafull    
 SELECT @totalImpuestos = ((( @TotalPercepciones - @LimiteInferior) * @Porcentaje) + @CuotaFija)        
        
        
--set @totalImpuestos = ( @totalImpuestos/ case when @PeriodicidadesPago = 'Semanal'then  7      
--                when @PeriodicidadesPago = 'Catorcenal' then 14      
--                when @PeriodicidadesPago = 'Quincenal'  then 15      
--                when @PeriodicidadesPago = 'Mensual'  then 30      
--                when @PeriodicidadesPago = 'Decenal'  then 10      
--                else 1      
--                END *  @Dias)      
      
      
--select @totalImpuestos        
RETURN @totalImpuestos        
        
END
GO

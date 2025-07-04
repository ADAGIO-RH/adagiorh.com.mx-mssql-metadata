USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Nomina].[fnSubsidioEmpleoCalculo]          
(          
	@IDPeriodicidadPago int,          
	@TotalPercepciones Decimal(18,4) ,  
	@Dias decimal(18,2) = 0,        
	@Ejercicio int,
	@FinMes bit = 0,
	@IDPais int = 151
) RETURNS DECIMAL(18,4)          
AS          
BEGIN          
          
	DECLARE           
		@PeriodicidadesPago varchar(100),          
		@IDCalculo int,          
		@LimiteInferior DECIMAL(18,4),          
		@LimiteSuperior DECIMAL(18,4),          
		@CuotaFija DECIMAL(18,4),          
		@Porcentaje DECIMAL(18,4),          
		@totalSubsidio DECIMAL(18,4) ,
		@ISRProporcional int ,
		@IDPeriodicidadesPagoMensual int,
		@PeriodicidadesPagoMensual varchar(30)
          
	select top 1 @IDCalculo = IDCalculo           
	from Nomina.tblCatTipoCalculoISR          
	WHERE Codigo = 'CALCULO_SUBSIDIO'   
 
	Select top 1 @ISRProporcional = cast(isnull(Valor,0) as int) 
	from Nomina.tblConfiguracionNomina 
	where Configuracion = 'ISRProporcional'   
	
	
  SELECT TOP 1 @IDPeriodicidadesPagoMensual = pp.IDPeriodicidadPago               
     ,@PeriodicidadesPagoMensual = PP.Descripcion              
 FROM sat.tblCatPeriodicidadesPago PP              
 WHERE Descripcion = 'Mensual'
	
        
        
	SELECT TOP 1 @PeriodicidadesPago = pp.Descripcion             
				,@PeriodicidadesPago = PP.Descripcion            
	FROM sat.tblCatPeriodicidadesPago PP            
	WHERE IDPeriodicidadPago = @IDPeriodicidadPago            
   
   IF(@ISRProporcional in (0,1,2,3))
   BEGIN


    	set @Dias = CASE 
						WHEN @Dias = 0 THEN case when @PeriodicidadesPago = 'Semanal'		then  7.00          
												 when @PeriodicidadesPago = 'Catorcenal'	then 14.00          
												 when @PeriodicidadesPago = 'Quincenal'		then 15.00          
												 when @PeriodicidadesPago = 'Mensual'		then 30.00          
												 when @PeriodicidadesPago = 'Decenal'		then 10.00          
											else 1 END 
					ELSE @Dias END
   
        
	set @TotalPercepciones = CASE 
									WHEN @ISRProporcional = 1 THEN (@TotalPercepciones /@Dias) * case 
																									when @PeriodicidadesPago = 'Semanal'	then  7.00          
																									when @PeriodicidadesPago = 'Catorcenal' then 14.00          
																									when @PeriodicidadesPago = 'Quincenal'  then 15.00          
																									when @PeriodicidadesPago = 'Mensual'	then 30.00          
																									when @PeriodicidadesPago = 'Decenal'	then 10.00          
																								else 1.00 END	
									WHEN @ISRProporcional = 2  THEN @TotalPercepciones	
									WHEN @ISRProporcional = 3  THEN (@TotalPercepciones/@Dias) * 30.4	
								 ELSE @TotalPercepciones END     
          
	SELECT 
		@LimiteInferior = DTI.LimiteInferior,          
		@LimiteSuperior = DTI.LimiteSuperior,          
		@totalSubsidio = DTI.CoutaFija,          
		@PeriodicidadesPago = pp.Descripcion          
	FROM Nomina.tbltablasImpuestos  TI          
		INNER JOIN Nomina.tblDetalleTablasImpuestos DTI          
			on DTI.IDTablaImpuesto = TI.IDTablaImpuesto          
		INNER JOIN sat.tblCatPeriodicidadesPago pp          
			on ti.IDPeriodicidadPago = pp.IDPeriodicidadPago         
	WHERE TI.Ejercicio = @Ejercicio          
		AND TI.IDCalculo = @IDCalculo  
		AND TI.IDPais = @IDPais
		AND TI.IDPeriodicidadPago = CASE WHEN @ISRProporcional = 3 THEN @IDPeriodicidadesPagoMensual else @IDPeriodicidadPago   end            
		and @TotalPercepciones BETWEEN DTI.LimiteInferior and DTI.LimiteSuperior          
          
 --select @LimiteInferior,@LimiteSuperior,@CuotaFija,@Porcentaje          
	set @totalSubsidio = CASE WHEN @ISRProporcional = 1 THEN ( @totalSubsidio/ 
												case 
													when @PeriodicidadesPago = 'Semanal'	then  7.00            
													when @PeriodicidadesPago = 'Catorcenal' then 14.00            
													when @PeriodicidadesPago = 'Quincenal'  then 15.00            
													when @PeriodicidadesPago = 'Mensual'	then 30.00            
													when @PeriodicidadesPago = 'Decenal'	then 10.00            
												else 1 END *  @Dias)   
								 WHEN @ISRProporcional = 2 THEN @totalSubsidio
								 ELSE ((@totalSubsidio / 30.4) * @Dias)
								 END
	END ELSE IF (@ISRProporcional = 4)
	BEGIN
		IF(@FinMes = 0)
		BEGIN
			
			SELECT 
				@LimiteInferior = DTI.LimiteInferior,          
				@LimiteSuperior = DTI.LimiteSuperior,          
				@totalSubsidio = DTI.CoutaFija,          
				@PeriodicidadesPago = pp.Descripcion          
			FROM Nomina.tbltablasImpuestos  TI          
				INNER JOIN Nomina.tblDetalleTablasImpuestos DTI          
					on DTI.IDTablaImpuesto = TI.IDTablaImpuesto          
				INNER JOIN sat.tblCatPeriodicidadesPago pp          
					on ti.IDPeriodicidadPago = pp.IDPeriodicidadPago         
			WHERE TI.Ejercicio = @Ejercicio          
				AND TI.IDCalculo = @IDCalculo  
				AND TI.IDPais = @IDPais
				AND TI.IDPeriodicidadPago = @IDPeriodicidadPago          
				and @TotalPercepciones BETWEEN DTI.LimiteInferior and DTI.LimiteSuperior
 
		END ELSE
		BEGIN
			
			SELECT 
				@LimiteInferior = DTI.LimiteInferior,          
				@LimiteSuperior = DTI.LimiteSuperior,          
				@totalSubsidio = DTI.CoutaFija,          
				@PeriodicidadesPago = pp.Descripcion          
			FROM Nomina.tbltablasImpuestos  TI          
				INNER JOIN Nomina.tblDetalleTablasImpuestos DTI          
					on DTI.IDTablaImpuesto = TI.IDTablaImpuesto          
				INNER JOIN sat.tblCatPeriodicidadesPago pp          
					on ti.IDPeriodicidadPago = pp.IDPeriodicidadPago         
			WHERE TI.Ejercicio = @Ejercicio          
				AND TI.IDCalculo = @IDCalculo 
				AND TI.IDPais = @IDPais
				AND TI.IDPeriodicidadPago = @IDPeriodicidadesPagoMensual          
				and @TotalPercepciones BETWEEN DTI.LimiteInferior and DTI.LimiteSuperior
		END
	END 
	--select @totalImpuestos          
	RETURN isnull(@totalSubsidio,0)
END
GO

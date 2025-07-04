USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Funcion para Calcular el ISR CORE
** Autor			: JOSE ROMAN
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 08/07/2018
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
2020-11-30			Jose Roman			Se agrego Cambio para cuando se calcule ISR Anual 
										lo realice directo con la configuracion 4 que es directo 
										por la periodicidad de pago sin propocionar el impuesto.
2024-03-08			Jose Roman			Se agrega parametro para validad si estoy ejecutando un periodo de 
										finiquito y asi buscar la configuración de calculo de isr para
										finiquito.
***************************************************************************************************/      
CREATE   FUNCTION [Nomina].[fnCoreISRSUELDOSTipoNomina]              
(              
	@IDPeriodicidadPago int ,              
	@TotalPercepciones Decimal(18,4),   
	@Dias decimal (18,2) = 0,             
	@Ejercicio int,
	@FinMes bit = 0,
	@IDPais int = 151,
	@Finiquito bit = 0,
    @IDISRProporcional int = null 
)              
RETURNS DECIMAL(18,4)              
AS              
BEGIN              
		          
	DECLARE               
		@PeriodicidadesPago varchar(100),              
		@PeriodicidadesPagoMensual varchar(100),              
		@IDPeriodicidadesPagoMensual int,              
		@IDPeriodicidadesPagoAnual int,              
		@IDCalculo int,              
		@LimiteInferior DECIMAL(18,4),              
		@LimiteSuperior DECIMAL(18,4),              
		@CuotaFija DECIMAL(18,4),              
		@Porcentaje DECIMAL(18,4),              
		@totalImpuestos DECIMAL(18,4), 
		@totalFinalTabla DECIMAL(18,4),
		@ISRProporcional int    
	;
              
	select top 1 @IDCalculo = IDCalculo               
	from Nomina.tblCatTipoCalculoISR              
	WHERE Codigo = 'ISR_SUELDOS'              

	-- Select top 1 @ISRProporcional = cast(isnull(Valor,0) as int)   
	-- from Nomina.tblConfiguracionNomina   
	-- where Configuracion =  CASE WHEN ISNULL(@Finiquito,0) = 0 THEN 'ISRProporcional'    
	-- 							ELSE 'ISRPROPORCIONALFINIQUITO'    
	-- 							END
    SET @ISRProporcional = @IDISRProporcional

	SELECT TOP 1 @PeriodicidadesPago = pp.Descripcion               
		,@PeriodicidadesPago = PP.Descripcion              
	FROM sat.tblCatPeriodicidadesPago PP              
	WHERE IDPeriodicidadPago = @IDPeriodicidadPago   

	--set @ISRProporcional =CASE WHEN @PeriodicidadesPago = 'Anual' THEN  4 
	--					ELSE @ISRProporcional
	--					END
  
	
	set @Dias = CASE WHEN @Dias = 0 THEN case when @PeriodicidadesPago	= 'Semanal'		then  7 
											when @PeriodicidadesPago	= 'Diario'		then  1            
											when @PeriodicidadesPago	= 'Catorcenal'	then 14            
											when @PeriodicidadesPago	= 'Quincenal'	then 15.2            
											when @PeriodicidadesPago	= 'Mensual'		then 30.4            
											when @PeriodicidadesPago	= 'Decenal'		then 10            
											when @PeriodicidadesPago	= 'Anual'		then 365.00            
										else 1            
									END   
				ELSE @Dias END  

	IF(@ISRProporcional in (0,1,2))  
	BEGIN
		set @TotalPercepciones = CASE WHEN @ISRProporcional = 1 THEN (@TotalPercepciones /@Dias) *  case when @PeriodicidadesPago = 'Semanal'then  7.0   
																										when @PeriodicidadesPago = 'Diario'then  1.0          
																										when @PeriodicidadesPago = 'Catorcenal' then 14.0            
																										when @PeriodicidadesPago = 'Quincenal'  then 15.2            
																										when @PeriodicidadesPago = 'Mensual'  then 30.4            
																										when @PeriodicidadesPago = 'Decenal'  then 10.0            
																										when @PeriodicidadesPago = 'Anual'  then 365.00           
																									   else 1.0            
																									END
			
						WHEN @ISRProporcional = 2 THEN 	@TotalPercepciones																		       
						ELSE @TotalPercepciones  
						END                     
                     
              
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
			AND TI.IDCalculo = @IDCalculo              
			AND TI.IDPais = @IDPais              
			AND TI.IDPeriodicidadPago = @IDPeriodicidadPago              
			and @TotalPercepciones BETWEEN DTI.LimiteInferior and DTI.LimiteSuperior              

		SELECT @totalFinalTabla = ((( @TotalPercepciones - @LimiteInferior) * @Porcentaje) + @CuotaFija)              
		       
		set @totalImpuestos = CASE WHEN @ISRProporcional = 1 THEN( @totalFinalTabla/ case when @PeriodicidadesPago = 'Semanal'then  7            
																						when @PeriodicidadesPago = 'Diario'then  1 
																						when @PeriodicidadesPago = 'Catorcenal' then 14            
																						when @PeriodicidadesPago = 'Quincenal'  then 15.2            
																						when @PeriodicidadesPago = 'Mensual'  then 30.4            
																						when @PeriodicidadesPago = 'Decenal'  then 10            
																						when @PeriodicidadesPago = 'Anual'  then 365            
																						else 1            
														END *  @Dias) 
														WHEN @ISRProporcional = 2 THEN  @totalFinalTabla   
														ELSE @totalFinalTabla
														END
	END 
	ELSE IF(@ISRProporcional = 3)
	BEGIN
		 set  @TotalPercepciones = ((@TotalPercepciones /@Dias ) * 30.4)
		
		SELECT TOP 1 @IDPeriodicidadesPagoMensual = pp.IDPeriodicidadPago               
			 ,@PeriodicidadesPagoMensual = PP.Descripcion              
		 FROM sat.tblCatPeriodicidadesPago PP              
		 WHERE Descripcion = 'Mensual'  


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
		  AND TI.IDCalculo = @IDCalculo    
		  AND TI.IDPais = @IDPais 
		  AND TI.IDPeriodicidadPago = @IDPeriodicidadesPagoMensual              
		  and @TotalPercepciones BETWEEN DTI.LimiteInferior and DTI.LimiteSuperior       
 
		 SELECT @totalFinalTabla = ((( @TotalPercepciones - @LimiteInferior) * @Porcentaje) + @CuotaFija)   
		 SELECT @totalImpuestos = ( ( ((( @TotalPercepciones - @LimiteInferior) * @Porcentaje) + @CuotaFija) / 30.4) * @Dias ) 

	END ELSE IF(@ISRProporcional = 4)
	BEGIN
		IF(@FinMes = 0)
		BEGIN
			SELECT 
				@LimiteInferior = DTI.LimiteInferior,              
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
				AND TI.IDCalculo = @IDCalculo 
				AND TI.IDPais = @IDPais 
				AND TI.IDPeriodicidadPago = @IDPeriodicidadPago              
				and @TotalPercepciones BETWEEN DTI.LimiteInferior and DTI.LimiteSuperior              
          
			SELECT @totalFinalTabla = ((( @TotalPercepciones - @LimiteInferior) * @Porcentaje) + @CuotaFija)  

			set @totalImpuestos = @totalFinalTabla
		END ELSE
		BEGIN

			SELECT TOP 1 @IDPeriodicidadesPagoMensual = pp.IDPeriodicidadPago               
				,@PeriodicidadesPagoMensual = PP.Descripcion              
			FROM sat.tblCatPeriodicidadesPago PP              
			WHERE Descripcion = 'Mensual'  

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
				AND TI.IDCalculo = @IDCalculo  
				AND TI.IDPais = @IDPais 
				AND TI.IDPeriodicidadPago = @IDPeriodicidadesPagoMensual              
				and @TotalPercepciones BETWEEN DTI.LimiteInferior and DTI.LimiteSuperior       

			SELECT @totalFinalTabla = ((( @TotalPercepciones - @LimiteInferior) * @Porcentaje) + @CuotaFija)   
			set @totalImpuestos = @totalFinalTabla

		END
	END  IF(@ISRProporcional = 5)
	BEGIN
		set @TotalPercepciones = ((@TotalPercepciones / @Dias) * 365.00)

		SELECT TOP 1 
			@IDPeriodicidadesPagoAnual = pp.IDPeriodicidadPago               
		FROM sat.tblCatPeriodicidadesPago PP              
		WHERE Descripcion = 'Anual'  

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
			AND TI.IDCalculo = @IDCalculo   
			AND TI.IDPais = @IDPais 
			AND TI.IDPeriodicidadPago = @IDPeriodicidadesPagoAnual           
			and @TotalPercepciones BETWEEN DTI.LimiteInferior and DTI.LimiteSuperior       

	   SELECT @totalFinalTabla = ((( @TotalPercepciones - @LimiteInferior) * @Porcentaje) + @CuotaFija)   
	   set @totalImpuestos = ((@totalFinalTabla /365.00) * @Dias)

	END
            
	--select @totalImpuestos              
	RETURN @totalImpuestos              
              
END
GO

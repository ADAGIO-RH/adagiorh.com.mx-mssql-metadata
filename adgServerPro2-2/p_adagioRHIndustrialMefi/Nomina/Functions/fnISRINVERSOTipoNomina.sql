USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Funcion para Calcular el ISR INVERSO
** Autor			: Julio Castillo
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 09/05/2023
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?			
***************************************************************************************************/      
CREATE FUNCTION [Nomina].[fnISRINVERSOTipoNomina]              
(              
	@IDPeriodicidadPago int ,              
	@TotalPercepciones Decimal(18,4),   
	@Dias decimal(18,2) = 0,             
	@Ejercicio int,
	@FinMes bit = 0,
    @IDPais int = 151,
    @IDISRProporcional int = null 
)              
RETURNS DECIMAL(18,4)              
AS              
BEGIN       

--declare 
--@IDPeriodicidadPago int = 4 ,              
--	@TotalPercepciones Decimal(18,4)= 22045.50,   
--	@Dias decimal(18,2) = 15.2,             
--	@Ejercicio int = 2021,
--	@FinMes bit = 0

		          
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
	WHERE Codigo = 'ISR_INVERSO' 

    SET @ISRProporcional = @IDISRProporcional 

    -- Select top 1 @ISRProporcional = cast(isnull(Valor,0) as int)   
	-- from Nomina.tblConfiguracionNomina   
	-- where Configuracion = 'ISRProporcional'  

    SELECT TOP 1 @PeriodicidadesPago = pp.Descripcion               
		,@PeriodicidadesPago = PP.Descripcion              
	FROM sat.tblCatPeriodicidadesPago PP              
	WHERE IDPeriodicidadPago = @IDPeriodicidadPago  
        
	set @Dias = CASE WHEN @Dias = 0 THEN case when @PeriodicidadesPago	= 'Semanal'		then  7 
											when @PeriodicidadesPago	= 'Diario'		then  1            
											when @PeriodicidadesPago	= 'Catorcenal'	then 14            
											when @PeriodicidadesPago	= 'Quincenal'	then 15            
											when @PeriodicidadesPago	= 'Mensual'		then 30            
											when @PeriodicidadesPago	= 'Decenal'		then 10            
										else 1            
									END   
				ELSE @Dias END  
		

	            
	IF(@ISRProporcional in (0,1,2))  
	BEGIN
        set @TotalPercepciones = CASE WHEN @ISRProporcional = 1 THEN (@TotalPercepciones / @Dias) *  case when @PeriodicidadesPago = 'Semanal'then  7   
                                                                                                            when @PeriodicidadesPago = 'Diario'then  1          
                                                                                                            when @PeriodicidadesPago = 'Catorcenal' then 14            
                                                                                                            when @PeriodicidadesPago = 'Quincenal'  then 15            
                                                                                                            when @PeriodicidadesPago = 'Mensual'  then 30.4            
                                                                                                            when @PeriodicidadesPago = 'Decenal'  then 10            
                                                                                                            when @PeriodicidadesPago = 'Anual'  then 365            
                                                                                                        else 1            
                                                                                                        END
                
                            WHEN @ISRProporcional = 2 THEN 	@TotalPercepciones																		       
                            ELSE @TotalPercepciones  
                            END  

        SELECT  @LimiteInferior	= DTI.LimiteInferior,              
				@LimiteSuperior = DTI.LimiteSuperior,              
				@CuotaFija		= DTI.CoutaFija,              
				@Porcentaje		= DTI.Porcentaje,               
				@PeriodicidadesPago = pp.Descripcion            
		FROM Nomina.tbltablasImpuestos  TI              
			INNER JOIN Nomina.tblDetalleTablasImpuestos DTI              
				on DTI.IDTablaImpuesto = TI.IDTablaImpuesto            
			inner join sat.tblCatPeriodicidadesPago pp            
				on ti.IDPeriodicidadPago = pp.IDPeriodicidadPago              
		WHERE TI.Ejercicio = @Ejercicio              
			AND TI.IDCalculo = @IDCalculo              
			AND TI.IDPeriodicidadPago = @IDPeriodicidadPago              
			and @TotalPercepciones BETWEEN DTI.LimiteInferior and DTI.LimiteSuperior  

        SELECT @totalFinalTabla = ((( @TotalPercepciones - @LimiteInferior) / @Porcentaje) + @CuotaFija)  

        set @totalImpuestos = @totalFinalTabla

    
    END

    ELSE IF(@ISRProporcional = 3)
    BEGIN
		set @TotalPercepciones = ((@TotalPercepciones * 30.40) / @Dias)		
		SELECT TOP 1 
			@IDPeriodicidadesPagoMensual = pp.IDPeriodicidadPago               
			,@PeriodicidadesPagoMensual = PP.Descripcion              
		FROM sat.tblCatPeriodicidadesPago PP              
		WHERE Descripcion = 'Mensual'  

		SELECT  @LimiteInferior	= DTI.LimiteInferior,              
				@LimiteSuperior = DTI.LimiteSuperior,              
				@CuotaFija		= DTI.CoutaFija,              
				@Porcentaje		= DTI.Porcentaje,               
				@PeriodicidadesPago = pp.Descripcion            
		FROM Nomina.tbltablasImpuestos  TI              
			INNER JOIN Nomina.tblDetalleTablasImpuestos DTI              
				on DTI.IDTablaImpuesto = TI.IDTablaImpuesto            
			inner join sat.tblCatPeriodicidadesPago pp            
				on ti.IDPeriodicidadPago = pp.IDPeriodicidadPago              
		WHERE TI.Ejercicio = @Ejercicio              
			AND TI.IDCalculo = @IDCalculo              
			AND TI.IDPeriodicidadPago = @IDPeriodicidadesPagoMensual              
			and @TotalPercepciones BETWEEN DTI.LimiteInferior and DTI.LimiteSuperior     
			
	
	   SELECT @totalFinalTabla = ((( @TotalPercepciones - @LimiteInferior) / @Porcentaje) + @CuotaFija)   

	   
	   set @totalImpuestos = ((@totalFinalTabla / 30.40) * @Dias)

    END   

    ELSE IF(@ISRProporcional = 4)
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
            
            SELECT @totalFinalTabla = ((( @TotalPercepciones - @LimiteInferior) / @Porcentaje) + @CuotaFija) 
           
            SET @totalImpuestos = @totalFinalTabla

        END
        ELSE
            BEGIN
            SELECT TOP 1 @IDPeriodicidadesPagoMensual = pp.IDPeriodicidadPago               
				,@PeriodicidadesPagoMensual = PP.Descripcion              
			FROM sat.tblCatPeriodicidadesPago PP              
			WHERE Descripcion = 'Mensual'  

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
                        AND TI.IDPeriodicidadPago = @IDPeriodicidadesPagoMensual              
                        and @TotalPercepciones BETWEEN DTI.LimiteInferior and DTI.LimiteSuperior 
                    
                    SELECT @totalFinalTabla = ((( @TotalPercepciones - @LimiteInferior) / @Porcentaje) + @CuotaFija) 
                
                    SET @totalImpuestos = @totalFinalTabla
            END

    END   

    ELSE IF(@ISRProporcional = 5) 
    BEGIN
        set @TotalPercepciones = ((@TotalPercepciones / @Dias) * 365.00)

		SELECT TOP 1 
			@IDPeriodicidadesPagoAnual = pp.IDPeriodicidadPago               
		FROM sat.tblCatPeriodicidadesPago PP              
		WHERE Descripcion = 'Anual'  

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
                        AND TI.IDPeriodicidadPago = @IDPeriodicidadesPagoAnual              
                        and @TotalPercepciones BETWEEN DTI.LimiteInferior and DTI.LimiteSuperior

        SELECT @totalFinalTabla = ((( @TotalPercepciones - @LimiteInferior) / @Porcentaje) + @CuotaFija)

        SET @totalImpuestos = ((@totalFinalTabla /365.00) * @Dias)

    END
             
	
RETURN @totalImpuestos              
              
END
GO

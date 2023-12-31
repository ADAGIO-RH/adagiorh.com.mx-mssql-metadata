USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Funcion para Calcular el ISR COSTARICA
** Autor			: JOSE ROMAN
** Email			: jroman@adagio.com.mx
** FechaCreacion	: 11-02-2022
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/ 
CREATE FUNCTION [Nomina].[fnISRSUELDOSCOSTARICA]              
(              
	@IDPeriodicidadPago int ,              
	@TotalPercepciones Decimal(18,4),   
	@Ejercicio int,
	@IDPais int = 52
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
		@ISRProporcional int,    
		@SUMCuotaFija Decimal(18,4)
	;
              
	select top 1 @IDCalculo = IDCalculo               
	from Nomina.tblCatTipoCalculoISR              
	WHERE Codigo = 'ISR_SUELDOS'              

	Select top 1 @ISRProporcional = cast(isnull(Valor,0) as int)   
	from Nomina.tblConfiguracionNomina   
	where Configuracion = 'ISRProporcional'    

	SELECT TOP 1 @PeriodicidadesPago = pp.Descripcion               
		,@PeriodicidadesPago = PP.Descripcion              
	FROM sat.tblCatPeriodicidadesPago PP              
	WHERE IDPeriodicidadPago = @IDPeriodicidadPago   

	SELECT TOP 1 
			@IDPeriodicidadesPagoMensual = pp.IDPeriodicidadPago               
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
			
		SELECT @SUMCuotaFija = SUM(DTI.CoutaFija)           
		FROM Nomina.tbltablasImpuestos  TI              
			INNER JOIN Nomina.tblDetalleTablasImpuestos DTI              
				on DTI.IDTablaImpuesto = TI.IDTablaImpuesto            
			inner join sat.tblCatPeriodicidadesPago pp            
				on ti.IDPeriodicidadPago = pp.IDPeriodicidadPago              
		WHERE TI.Ejercicio = @Ejercicio              
			AND TI.IDCalculo = @IDCalculo              
			AND TI.IDPais = @IDPais              
			AND TI.IDPeriodicidadPago = @IDPeriodicidadesPagoMensual              
			and  DTI.LimiteSuperior < @LimiteSuperior

		SELECT @totalFinalTabla = ((( @TotalPercepciones - @LimiteInferior) * @Porcentaje) + @SUMCuotaFija)
            
	--select @totalImpuestos              
	RETURN @totalFinalTabla              
              
END
GO

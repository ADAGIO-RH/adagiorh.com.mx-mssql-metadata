USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reportes].[spDetalleOtrosFiniquito] --0,100,390,1 
(        
	@IDFiniquito int = 0,          
	@IDPeriodo int,    
	@IDEmpleado int,
	@IDUsuario int          
)        
AS        
BEGIN        
         
	DECLARE         
		 @empleados [RH].[dtEmpleados]        
		,@periodo [Nomina].[dtPeriodos]        
		,@Conceptos [Nomina].[dtConceptos]        
		,@dtFiltros [Nomina].[dtFiltrosRH]        
		,@fechaIniPeriodo  date        
		,@fechaFinPeriodo  date   
		,@Estatus varchar(max)     
		,@TotalAPagar decimal(18,2)
		,@TotalFondoAhorro decimal(18,2)

		,@ConceptoTotalDevAhorro varchar(10) = '533'
		,@IDTotalDevFondoAhorro int

		,@SumaPerc decimal(18,2)
		,@TotalPercepiones decimal(18,2)

		,@SumaDedu decimal(18,2)
		,@TotalDeducciones decimal(18,2)
	;		



	
	select top 1 @Estatus = ef.Descripcion 
		from Nomina.tblControlFiniquitos cf with (nolock)
			inner join Nomina.tblCatEstatusFiniquito ef with (nolock)
				on cf.IDEStatusFiniquito = ef.IDEStatusFiniquito
	where IDFiniquito = @IDFiniquito  	
	



	IF(@Estatus = 'Aplicar')
    BEGIN
        SELECT
        CASE WHEN CC.IDConcepto=108 THEN 'Gratificación por terminación de relación laboral' 
             WHEN CC.IDConcepto=109 THEN 'Indeminizacion (20 Dias X Año)' 
             WHEN CC.IDConcepto=110 THEN 'Prima de antiguedad' 
             END AS Descripcion,
             DP.ImporteTotal1 as importe
            from Nomina.tblDetallePeriodo dp with (nolock) 
												join Nomina.tblCatConceptos cc with (nolock) on dp.IDConcepto =  cc.IDConcepto 
											 where IDPeriodo = @IDPeriodo and IDEmpleado = @IDEmpleado and dp.IDConcepto in (108,109,110)

    END
    ELSE
    BEGIN
        SELECT
        CASE WHEN CC.IDConcepto=108 THEN 'Gratificación por terminación de relación laboral' 
             WHEN CC.IDConcepto=109 THEN 'Indeminizacion (20 Dias X Año)' 
             WHEN CC.IDConcepto=110 THEN 'Prima de antiguedad' 
             END AS Descripcion
        ,DP.ImporteTotal1 as importe
								from Nomina.tblDetallePeriodoFiniquito dp with (nolock) 
									join Nomina.tblCatConceptos cc with (nolock) on dp.IDConcepto = cc.IDConcepto
								where IDPeriodo = @IDPeriodo and IDEmpleado = @IDEmpleado and dp.IDConcepto in (108,109,110)
    END


    
    
     


END
GO

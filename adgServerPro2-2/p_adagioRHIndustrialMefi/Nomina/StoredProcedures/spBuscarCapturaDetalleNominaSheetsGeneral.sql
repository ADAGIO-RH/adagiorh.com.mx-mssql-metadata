USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Nomina.spBuscarCapturaDetalleNomina 264  
CREATE PROCEDURE [Nomina].[spBuscarCapturaDetalleNominaSheetsGeneral] --476  
(  
--declare   
 @IDPeriodo int,  
 @dtFiltros [Nomina].[dtFiltrosRH] READONLY ,
 @IDTipoConcepto int 
)  
AS  
BEGIN  
 declare   
    @IDTipoNomina int,  
    @FI date,  
    @FF date,  
    @dtEmpleado [RH].[dtEmpleados],  
    @tipoCaptura varchar(100) = ''  
  
 select @IDTipoNomina=IDTipoNomina,@FI=FechaInicioPago, @FF=FechaFinPago   
 from Nomina.tblCatPeriodos  
 where IDPeriodo=@IDPeriodo  
  
 insert into @dtEmpleado  
 Exec RH.spBuscarEmpleados   
     @FechaIni = @FI  
 ,@Fechafin = @FF  
 ,@IDUsuario = 0   
 ,@IDTipoNomina = @IDTipoNomina  
 ,@dtFiltros = @dtFiltros  
  
 SELECT   
     
     
     c.IDConcepto,  
     C.Codigo +' - '+C.Descripcion Concepto  
   ,ISNULL(dp.CantidadMonto,0) as CantidadMonto  
   ,ISNULL(dp.CantidadDias ,0) as CantidadDias  
   ,ISNULL(dp.CantidadVeces,0) as CantidadVeces  
   ,ISNULL(dp.CantidadOtro1,0) as CantidadOtro1  
   ,ISNULL(dp.CantidadOtro2,0) as CantidadOtro2  
   ,ISNULL(dp.ImporteGravado,0) as ImporteGravado  
   ,ISNULL(dp.ImporteExcento,0) as ImporteExcento 
   ,ISNULL(dp.ImporteTotal1,0) as ImporteTotal1  
   ,ISNULL(dp.ImporteTotal2,0) as ImporteTotal2       
   ,isnull(dp.ImporteAcumuladoTotales,0) as ImporteAcumuladoTotales  
        
 FROM Nomina.tblCatPeriodos p   
  cross join @dtEmpleado e  
  cross join Nomina.tblCatConceptos c  
  left join Nomina.tbldetallePeriodo dp  
   on dp.IDPeriodo = p.IDPeriodo  
    and dp.IDConcepto = c.IDConcepto  
    and dp.IDEmpleado = e.IDEmpleado  
 where p.IDPeriodo = @IDPeriodo and c.Estatus = 1 and p.Cerrado = 0  
	and c.IDTipoConcepto = @IDTipoConcepto
  and ((c.IDConcepto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Conceptos'),','))   
       or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Conceptos'))))    
           
 ORDER BY e.IDEmpleado, C.OrdenCalculo  
  
end  
  
  
--declare   
--   @tipoCaptura varchar(100) = 'CantidadVeces'  
  
  
  
--Select *  
--        from Nomina.tblCatConceptos   
--        where ((@tipoCaptura = 'CantidadMonto' and bCantidadMonto = 1)   
--        OR (@tipoCaptura = 'CantidadDias' and bCantidadDias = 1)  
--        OR (@tipoCaptura = 'CantidadVeces' and bCantidadVeces = 1)  
--        OR (@tipoCaptura = 'CantidadOtro1' and bCantidadOtro1 = 1)  
--        OR (@tipoCaptura = 'CantidadOtro2' and bCantidadOtro2 = 1))
GO

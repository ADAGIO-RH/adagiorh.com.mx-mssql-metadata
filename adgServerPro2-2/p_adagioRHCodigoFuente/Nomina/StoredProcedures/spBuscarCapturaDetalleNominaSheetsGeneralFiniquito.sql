USE [p_adagioRHCodigoFuente]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spBuscarCapturaDetalleNominaSheetsGeneralFiniquito] --471        
(        
--declare         
 @IDPeriodo int,        
 @dtFiltros [Nomina].[dtFiltrosRH] READONLY,    
 @IDTipoConcepto varchar(10) = null  ,
  @IDUsuario int         
)        
AS        
BEGIN        
 declare         
    @IDTipoNomina int,        
    @FI date,        
    @FF date,        
    @dtEmpleado [RH].[dtEmpleados],     
	@IDEmpleado int,
    @tipoCaptura varchar(100) = '',    
	@IDPais int
	;
        
	set @IDEmpleado = cast([Nomina].[fnObtenerValorFiltro](@dtFiltros, 'Empleados', null) as int)
    
	select 
		@IDPais = tn.IDPais       
    from Nomina.tblCatPeriodos p 
		inner join Nomina.tblCatTipoNomina tn with(nolock)
			on tn.IDTipoNomina = p.IDTipoNomina
	where p.IDPeriodo = @IDPeriodo    
            
	SELECT            
		 E.IDEmpleado        
		,E.ClaveEmpleado        
		,E.NOMBRECOMPLETO as NombreCompleto        
		,c.IDConcepto       
		,C.Codigo +' - '+C.Descripcion Concepto        
		,ISNULL(dp.CantidadMonto,0) as CantidadMonto        
		,ISNULL(dp.CantidadDias ,0) as CantidadDias        
        ,ISNULL(dp.CantidadVeces,0) as CantidadVeces        
        ,ISNULL(dp.CantidadOtro1,0) as CantidadOtro1        
        ,ISNULL(dp.CantidadOtro2,0) as CantidadOtro2        
        ,ISNULL(dp.ImporteGravado,0) as ImporteGravado        
        ,ISNULL(dp.ImporteExcento,0) as ImporteExcento       
        ,ISNULL(dp.ImporteTotal1,0) as ImporteTotal1        
        ,ISNULL(dp.ImporteTotal2,0) as ImporteTotal2             
        ,ISNULL(dp.ImporteAcumuladoTotales,0) as ImporteAcumuladoTotales       
        ,ISNULL(dp.IDReferencia,0) as IDReferencia       
	FROM Nomina.tblCatPeriodos p         
	  cross join (Select 
                     IDEmpleado        
		            ,ClaveEmpleado        
		            ,NOMBRECOMPLETO 
                    from rh.tblEmpleadosMaster 
                    where IDempleado = @IDempleado ) e       
	  cross join Nomina.tblCatConceptos c        
	  left  join Nomina.tblDetallePeriodoFiniquito dp        
	   on dp.IDPeriodo = p.IDPeriodo        
		and dp.IDConcepto = c.IDConcepto        
		and dp.IDEmpleado = e.IDEmpleado        
	where p.IDPeriodo = @IDPeriodo and c.Estatus = 1 --and p.Cerrado = 0        
	 and c.IDTipoConcepto in (Select item from App.Split(@IDTipoConcepto,','))     
	 and ((c.IDConcepto in (Select item from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Conceptos'),','))         
		   or (Not exists(Select 1 from @dtFiltros where Catalogo = 'Conceptos'))))          
	 and c.IDPais = @IDPais             
	ORDER BY e.IDEmpleado, C.OrdenCalculo        
        
end
GO

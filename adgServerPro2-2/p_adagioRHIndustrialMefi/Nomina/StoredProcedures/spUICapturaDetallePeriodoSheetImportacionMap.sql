USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Nomina].[spUICapturaDetallePeriodoSheetImportacionMap](    
   @IDPeriodo int           
  ,@DetallePeriodoCapturaImportacion [Nomina].[dtDetallePeriodoCapturaImportacion] READONLY          
)        
AS        
BEGIN       
     
	select           
		isnull(M.IDEmpleado,0) as IDEmpleado            
		,E.[ClaveEmpleado]      
		,isnull(M.NOMBRECOMPLETO,'') as NombreCompleto      
		,isnull(c.IDConcepto,0) as IDConcepto          
		,e.Codigo as Codigo      
		,isnull(c.Descripcion,'') as Descripcion      
		,isnull(e.CantidadMonto,0.00) as  CantidadMonto   
		,isnull(e.CantidadDias,0.00) as CantidadDias     
		,isnull(e.CantidadVeces,0.00) as CantidadVeces     
		,isnull(e.CantidadOtro1,0.00) as CantidadOtro1     
		,isnull(e.CantidadOtro2,0.00) as CantidadOtro2     
		,isnull(e.ImporteGravado,0.00) as ImporteGravado     
		,isnull(e.ImporteExcento,0.00) as ImporteExcento     
		,isnull(e.ImporteOtro,0.00) as ImporteOtro     
		,isnull(e.ImporteTotal1,0.00) as ImporteTotal1     
		,isnull(e.ImporteTotal2,0.00) as ImporteTotal2     
	from @DetallePeriodoCapturaImportacion E          
		left join RH.tblEmpleadosMaster m on e.ClaveEmpleado = m.ClaveEmpleado      
		left join Nomina.tblCatConceptos c on c.Codigo = e.Codigo     
		inner join Nomina.tblCatPeriodos p on p.IDTipoNomina = m.IDTipoNomina   
			and p.IDPeriodo = @IDPeriodo     
	WHERE isnull(E.ClaveEmpleado,'') <>''           
END
GO

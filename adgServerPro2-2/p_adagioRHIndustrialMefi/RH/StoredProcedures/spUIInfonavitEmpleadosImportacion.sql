USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spUIInfonavitEmpleadosImportacion]  
(  
 @dtCreditosInfonavit [RH].[dtInfonavitEmpleadosMap] READONLY  
)  
AS  
BEGIN  
  
  
   MERGE RH.tblInfonavitEmpleado AS TARGET  
    USING @dtCreditosInfonavit AS SOURCE  
    ON TARGET.IDEmpleado = SOURCE.IDEmpleado  
      and TARGET.Fecha = SOURCE.Fecha  
      and TARGET.NumeroCredito = SOURCE.NumeroCredito  
      and TARGET.IDRegPatronal = SOURCE.IDRegPatronal       
   WHEN MATCHED Then  
    update  
    Set       
    TARGET.IDTipoMovimiento  = (select IDTipoMovimiento from RH.tblCatInfonavitTipoMovimiento where Descripcion=SOURCE.TipoMovimiento),  
    TARGET.IDTipoDescuento  = SOURCE.IDTipoDescuento,  
    TARGET.ValorDescuento  = SOURCE.ValorDescuento,  
    TARGET.AplicaDisminucion  = SOURCE.AplicaDisminucion      
  
    WHEN NOT MATCHED BY TARGET THEN   
    INSERT(IDEmpleado
			,IDRegPatronal
			,NumeroCredito
			,IDTipoMovimiento
			,Fecha
			,IDTipoDescuento
			,ValorDescuento
			,AplicaDisminucion) 
    VALUES(SOURCE.IDEmpleado,SOURCE.IDRegPatronal,SOURCE.NumeroCredito,(select IDTipoMovimiento from RH.tblCatInfonavitTipoMovimiento where Descripcion=SOURCE.TipoMovimiento),SOURCE.Fecha,SOURCE.IDTipoDescuento,SOURCE.ValorDescuento,SOURCE.AplicaDisminucion);  
    
   
    MERGE RH.tblHistorialInfonavitEmpleado AS TARGET  
    USING RH.tblInfonavitEmpleado AS SOURCE  
    ON TARGET.IDEmpleado = SOURCE.IDEmpleado  
      and TARGET.Fecha = SOURCE.Fecha  
      and TARGET.NumeroCredito = SOURCE.NumeroCredito  
      and TARGET.IDRegPatronal = SOURCE.IDRegPatronal 
	  and TARGET.IDInfonavitEmpleado =  SOURCE.IDInfonavitEmpleado 
	  and TARGET.NumeroCredito in (Select NumeroCredito from @dtCreditosInfonavit)      
   WHEN MATCHED Then  
    update  
    Set       
    TARGET.IDTipoMovimiento  = SOURCE.IDTipoMovimiento,  
    TARGET.IDTipoDescuento  = SOURCE.IDTipoDescuento,  
    TARGET.ValorDescuento  = SOURCE.ValorDescuento,  
    TARGET.AplicaDisminucion  = SOURCE.AplicaDisminucion     

    WHEN NOT MATCHED BY TARGET THEN   
    INSERT( IDInfonavitEmpleado
			,IDEmpleado
			,IDRegPatronal
			,NumeroCredito
			,IDTipoMovimiento
			,Fecha
			,IDTipoDescuento
			,ValorDescuento
			,AplicaDisminucion)  
    VALUES(SOURCE.IDInfonavitEmpleado,SOURCE.IDEmpleado,SOURCE.IDRegPatronal,SOURCE.NumeroCredito,SOURCE.IDTipoMovimiento,SOURCE.Fecha,SOURCE.IDTipoDescuento,SOURCE.ValorDescuento,SOURCE.AplicaDisminucion);  


END
GO

USE [p_adagioRHMinutoAntes]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spUIHistorialMovAfiliatoriosImportacion]      
(      
 @dtHistorial [RH].[dtHistorialMovAfiliatoriosMap] READONLY      
 --@Fecha date,  
 --@IDEmpleado int,  
 --@IDTipoMovimiento int,  
 --@IDRazonMovimiento int = null,  
 --@SalarioDiario decimal(18,2) = 0.00,  
 --@SalarioIntegrado decimal(18,2)= 0.00,  
 --@SalarioVariable decimal(18,2)= 0.00,  
 --@SalarioDiarioReal decimal(18,2)= 0.00,  
 --@IDRegPatronal int = 0,  
 --@FechaIMSS date = null,  
 --@FechaIDSE date = null  
  
  
)      
AS      
BEGIN      
      
 --IF exists(Select 1 from IMSS.tblMovAfiliatorios where IDEmpleado = @IDEmpleado and Fecha = @Fecha and IDTipoMovimiento = @IDTipoMovimiento)  
 --BEGIN  
 -- update  IMSS.tblMovAfiliatorios    
 --  Set           
 --  FechaIMSS  = @FechaIMSS,      
 --  FechaIDSE  = @FechaIDSE,      
 --  IDRazonMovimiento = @IDRazonMovimiento,      
 --  SalarioDiario = @SalarioDiario,      
 --  SalarioIntegrado = @SalarioIntegrado,      
 --  SalarioVariable = @SalarioVariable,      
 --  SalarioDiarioReal = @SalarioDiarioReal,      
 --  IDRegPatronal = CASE WHEN @IDRegPatronal = 0 THEN NULL ELSE @IDRegPatronal END     
 -- where IDEmpleado = @IDEmpleado and Fecha = @Fecha and IDTipoMovimiento = @IDTipoMovimiento  
 --END  
 --ELSE  
 --BEGIN  
 -- INSERT INTO IMSS.tblMovAfiliatorios(Fecha,IDEmpleado,IDTipoMovimiento,FechaIMSS,FechaIDSE,SalarioDiario,SalarioIntegrado,SalarioVariable,SalarioDiarioReal,IDRegPatronal)      
 --  VALUES(@Fecha,@IDEmpleado,@IDTipoMovimiento,@FechaIMSS,@FechaIDSE,@SalarioDiario,@SalarioIntegrado,@SalarioVariable,@SalarioDiarioReal, CASE WHEN @IDRegPatronal = 0 THEN NULL ELSE @IDRegPatronal END );      
        
      
 --END  
      
   MERGE IMSS.tblMovAfiliatorios AS TARGET      
    USING @dtHistorial AS SOURCE      
    ON TARGET.IDEmpleado = SOURCE.IDEmpleado      
      and TARGET.Fecha = SOURCE.Fecha      
      and TARGET.IDTipoMovimiento = SOURCE.IDTipoMovimiento      
   WHEN MATCHED Then      
    update      
    Set           
    TARGET.FechaIMSS  = SOURCE.FechaIMSS,      
    TARGET.FechaIDSE  = SOURCE.FechaIDSE,      
    TARGET.IDRazonMovimiento = SOURCE.IDRazonMovimiento,      
    TARGET.SalarioDiario = SOURCE.SalarioDiario,      
    TARGET.SalarioIntegrado = SOURCE.SalarioIntegrado,      
    TARGET.SalarioVariable = SOURCE.SalarioVariable,      
    TARGET.SalarioDiarioReal = SOURCE.SalarioDiarioReal,      
    TARGET.IDRegPatronal = CASE WHEN SOURCE.IDRegPatronal = 0 THEN NULL ELSE SOURCE.IDRegPatronal END     
      
    WHEN NOT MATCHED BY TARGET THEN       
    INSERT(Fecha,IDEmpleado,IDTipoMovimiento,FechaIMSS,FechaIDSE,SalarioDiario,SalarioIntegrado,SalarioVariable,SalarioDiarioReal,IDRegPatronal)      
    VALUES(SOURCE.Fecha,SOURCE.IDEmpleado,SOURCE.IDTipoMovimiento,SOURCE.FechaIMSS,SOURCE.FechaIDSE,SOURCE.SalarioDiario,SOURCE.SalarioIntegrado,SOURCE.SalarioVariable,SOURCE.SalarioDiarioReal, CASE WHEN SOURCE.IDRegPatronal = 0 THEN NULL ELSE SOURCE.IDRegPatronal END );      
        
      
  declare @tran int   
   set @tran = @@TRANCOUNT  
   if(@tran = 0)  
   BEGIN  
  exec [RH].[spSincronizarEmpleadosMaster]  
   END 
      
       
END
GO

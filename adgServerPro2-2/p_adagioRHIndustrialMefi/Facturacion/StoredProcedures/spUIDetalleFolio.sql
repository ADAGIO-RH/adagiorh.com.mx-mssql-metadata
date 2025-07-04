USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Facturacion].[spUIDetalleFolio] --150,'02','3BF5AE3B-9BDF-4582-B7DE-F5619DA2F299','20001000000300022323',2,'2018-01-15 14:33:01.183',5,null,null    
(  
 @IDHistorialEmpleadoPeriodo int,  
 @CodigoTipoRegimen Varchar(5),  
 @UUID VARCHAR(50) =null,  
 @ACUSE VARCHAR(50) =null,  
 @IDEstatusTimbrado int,  
 @Fecha Datetime,  
 @IDUsuario int,  
 @CodigoError Varchar(255)= null,  
 @Error Varchar(MAX)= null,
 @SelloCFDI NVARCHAR(MAX)= NULL,  
 @SelloSAT NVARCHAR(MAX)= NULL,  
 @CadenaOriginal NVARCHAR(MAX) =NULL,
 @NoCertificadoSat NVARCHAR(MAX)= NULL,
 @CustomID NVARCHAR(MAX)= NULL
)  
AS  
BEGIN  
 Declare @IDTimbrado int  
  
 update Facturacion.TblTimbrado  
  set Actual = 0  
 where IDHistorialEmpleadoPeriodo = @IDHistorialEmpleadoPeriodo  
  And Actual = 1  
  
 insert into Facturacion.TblTimbrado(  
    IDHistorialEmpleadoPeriodo  
    ,IDTipoRegimen  
    ,UUID  
    ,ACUSE  
    ,IDEstatusTimbrado  
    ,Fecha  
    ,Actual  
    ,IDUsuario  
    ,CodigoError  
    ,Error 
	,SelloCFDI
	,SelloSAT
	,CadenaOriginal 
	,NoCertificadoSat
	,CustomID
 )  
  
 VALUES(   
  @IDHistorialEmpleadoPeriodo  
  ,(Select TOP 1 IDTipoRegimen from Sat.tblCatTiposRegimen where Codigo = @CodigoTipoRegimen)  
  ,@UUID  
  ,@ACUSE  
  ,@IDEstatusTimbrado  
  ,@Fecha  
  ,1  
  ,@IDUsuario  
  ,@CodigoError  
  ,@Error 
  ,@SelloCFDI
  ,@SelloSAT
  ,@CadenaOriginal 
  ,@NoCertificadoSat
  ,@CustomID
 )  
  
  
END
GO

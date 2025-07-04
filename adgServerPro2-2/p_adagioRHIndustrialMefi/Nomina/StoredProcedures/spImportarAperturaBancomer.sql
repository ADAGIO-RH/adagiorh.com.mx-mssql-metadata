USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
            
/****************************************************************************************************             
** Descripción  : Procedimiento para Actualizar el historial de metodos de pago de un Colaborador Con la apertura Bancomer           
** Autor   : Jose Rafael Roman Gil            
** Email   : jose.roman@adagio.com.mx            
** FechaCreacion :20/12/2018            
** Paremetros  :                          
****************************************************************************************************            
HISTORIAL DE CAMBIOS            
Fecha(yyyy-mm-dd) Autor    Comentario            
------------------- ------------------- ------------------------------------------------------------            
0000-00-00  NombreCompleto   ¿Qué cambió?            
          
***************************************************************************************************/            
            
CREATE PROCEDURE [Nomina].[spImportarAperturaBancomer]            
(            
 @IDPagoEmpleado int = 0            
 ,@IDEmpleado int         
 ,@IDLayoutPago int          
 ,@Tarjeta Varchar(20)= NULL             
 ,@Cuenta Varchar(18) =NULL           
 ,@Interbancaria Varchar(18)=  NULL          
 ,@IDUsuario int            
)            
AS            
BEGIN            
            
	Declare @IDTipoLayout int,      
			@IDConcepto int,       
			@IDBanco int,
			@ImporteTotal int
	;            
          
	Select top 1 
		@IDTipoLayout = tl.IDTipoLayout    
		,@IDBanco = tl.IDBanco   
		,@IDConcepto = lp.IDConcepto  
		,@ImporteTotal = lp.ImporteTotal  
	from Nomina.tblCatTiposLayout tl with (nolock)
		inner join Nomina.tblLayoutPago lp with (nolock)    
			on tl.IDTipoLayout = lp.IDTipoLayout    
	where lp.IDLayoutPago = @IDLayoutPago       
     
	IF(@IDPagoEmpleado = 0)
	BEGIN
		if not exists (select top 1 1
						from RH.tblPagoEmpleado with (nolock)
						where IDEmpleado = @IDEmpleado and IDLayoutPago = @IDLayoutPago)
		begin
			insert into RH.tblPagoEmpleado(
				IDEmpleado
				,IDLayoutPago
				,IDConcepto
				,ImporteTotal
				,Cuenta
				,Interbancaria
				,Tarjeta
				,IDBanco) 
			Values(
				 @IDEmpleado
				,@IDLayoutPago
				,@IDConcepto
				,@ImporteTotal
				,@Cuenta
				,@Interbancaria
				,@Tarjeta
				,@IDBanco
			)
		end else
		begin
			UPDATE RH.tblPagoEmpleado            
			SET            
				IDLayoutPago = case when @IDLayoutPago = 0 then null else @IDLayoutPago end            
				,Cuenta = isnull(@Cuenta, Cuenta)   
				,IDConcepto = @IDConcepto           
				,Interbancaria = ISNULL(@Interbancaria, Interbancaria)            
				,IDBanco = case when @IDBanco = 0 then null else @IDBanco end        
				,Tarjeta = ISNULL(@Tarjeta,Interbancaria)          
			WHERE IDEmpleado = @IDEmpleado and IDLayoutPago = @IDLayoutPago
		end;
	END
	ELSE
	BEGIN
		UPDATE RH.tblPagoEmpleado            
		SET            
			IDLayoutPago = case when @IDLayoutPago = 0 then null else @IDLayoutPago end            
			,Cuenta = isnull(@Cuenta, Cuenta)   
			,IDConcepto = @IDConcepto           
			,Interbancaria = ISNULL(@Interbancaria, Interbancaria)            
			,IDBanco = case when @IDBanco = 0 then null else @IDBanco end        
			,Tarjeta = ISNULL(@Tarjeta,null)          
		WHERE IDEmpleado = @IDEmpleado and IDPagoEmpleado = @IDPagoEmpleado   
	 END
END
GO

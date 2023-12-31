USE [p_adagioRHPoliAcero]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
NO BORRAR, NO MOVER.
JOSEPH - ARTURO
ESPECIAL PARA REPORTE DE 2 PARTES PERSONALIZADO PARA POLIACERO

*/
--select * from RH.tblEmpleadosMaster where ClaveEmpleado = '00435'
--select * from Nomina.tblCatTipoNomina

CREATE PROCEDURE [Reportes].[spCalculoNominaDetallePorEmpleadoAcumFondoCajaPrestamos_POLIACERO_ORIGINAL]--555,91   
(    
 @IDEmpleado int,    
 @IDPeriodo int    
)    
AS    
BEGIN    
    SET NOCOUNT ON;
     IF 1=0 BEGIN
       SET FMTONLY OFF
     END
     
	 DECLARE @Ejercicio int,
			@IDTipoNomina int,
			@IDFondoAhorro int,
			@IDCajaAhorro int
	 SELECT @Ejercicio = Ejercicio, @IDTipoNomina = IDTipoNomina FROM Nomina.tblCatPeriodos with(nolock) WHERE IDPeriodo = @IDPeriodo
	 
	 select @IDFondoAhorro = IDFondoAhorro from Nomina.tblCatFondosAhorro where IDTipoNomina = @IDTipoNomina and Ejercicio = @Ejercicio
	 select @IDCajaAhorro = IDCajaAhorro from [Nomina].[tblCajaAhorro] where IDEmpleado = @IDEmpleado


	 

	IF OBJECT_ID('tempdb..#tblAcumuladoFondoAhorro') IS NOT NULL DROP TABLE #tblAcumuladoFondoAhorro    
	IF OBJECT_ID('tempdb..#tblAcumuladoCajaAhorro') IS NOT NULL DROP TABLE #tblAcumuladoCajaAhorro    
	IF OBJECT_ID('tempdb..#tblAcumuladoTotales') IS NOT NULL DROP TABLE #tblAcumuladoCajaAhorro    
    
	create table  #tblAcumuladoFondoAhorro  
	(
			TotalAportacionesEmpresa	  decimal(18,2)null	
		   ,TotalAportacionesTrabajador	  decimal(18,2)null	
		   ,TotalDevolucionesEmpresa	  decimal(18,2)null	
		   ,TotalDevolucionesTrabajador	  decimal(18,2)null	
		   ,TotalRetirosEmpresa			  decimal(18,2)null	
		   ,TotalRetirosTrabajador		  decimal(18,2)null	
		   ,TotalAcumulado				  decimal(18,2)null	
		   ,TotalPrestamosFondoAhorro	  decimal(18,2)null		
		   ,TotalSaldoPendienteADescontar decimal(18,2)null		
	)

	create table  #tblAcumuladoCajaAhorro  
	(
			TotalAcumuladoCajaAhorro				  decimal(18,2)null	
		   ,TotalPrestamosDevolucionesCajaAhorro	  decimal(18,2)null	
		   ,NetoDisponible							  decimal(18,2)null	
		   ,TotalPrestamosPendientes				  decimal(18,2)null	
		  
	)


	create table  #tblAcumuladoTotal 
	(
			ACUMFondoAhorro							decimal(18,2) null	
		   ,ACUMCajaAhorro						decimal(18,2) null	
		   ,SaldoActualCajaAhorro					decimal(18,2) null	
		   ,ACUMPrestamoCajaAhorro					decimal(18,2) null	
		   ,SaldoActualPrestamoCajaAhorro			decimal(18,2) null	
		  
	)

	insert into #tblAcumuladoFondoAhorro 
	EXEC  [Nomina].[spBuscarAcumuladoFondoAhorroPorEmpleado]
		@IDFondoAhorro	= @IDFondoAhorro
		,@IDEmpleado	= @IDEmpleado	
		,@IDUsuario		= 1

	insert into #tblAcumuladoCajaAhorro
	EXEC  [Nomina].[spBuscarAcumuladoCajaAhorroPorEmpleado]
		@IDCajaAhorro	= @IDCajaAhorro
		,@IDEmpleado	= @IDEmpleado	
		,@IDUsuario		= 1


	insert into #tblAcumuladoTotal(ACUMFondoAhorro,ACUMCajaAhorro,SaldoActualCajaAhorro,SaldoActualPrestamoCajaAhorro)
	select FA.TotalAcumulado,
		   CA.TotalAcumuladoCajaAhorro,
		   CA.NetoDisponible,
		   CA.TotalPrestamosPendientes

	from #tblAcumuladoFondoAhorro FA
		inner join  #tblAcumuladoCajaAhorro CA
			on 1 = 1

			select ACUMFondoAhorro,ACUMCajaAhorro,SaldoActualCajaAhorro,SaldoActualPrestamoCajaAhorro 
			from #tblAcumuladoTotal

END
GO

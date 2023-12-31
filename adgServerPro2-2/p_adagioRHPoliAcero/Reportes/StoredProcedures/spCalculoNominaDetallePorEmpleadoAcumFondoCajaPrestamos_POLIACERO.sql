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

DENZEL 
SE HIZO UN CAMBIO A LA DECLARACION #tblAcumuladoFondoAhorro POR QUE EL SP ENTREGABA MAS DATOS Y TIRABA EXEPCION.
SE LE ANADIERON INTERESES AL SALDO ACTUAL PRESTAMO, UTILIZANDO UNA FUNCION LLAMADA fnBuscarSaldoActualPrestamosCajaAhorroConIntereses

*/
--select * from RH.tblEmpleadosMaster where ClaveEmpleado = '00435'
--select * from Nomina.tblCatTipoNomina


/****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2022-05-09		Yesenia Leonel		Se crearon nuevos SP para mostrar los acumulados al periodo del recibo, y no a la fecha actual
***************************************************************************************************/

CREATE PROCEDURE [Reportes].[spCalculoNominaDetallePorEmpleadoAcumFondoCajaPrestamos_POLIACERO]--555,91   
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
		@IDCajaAhorro int,
		@TotalPrestamosCajaDeAhorro decimal(18,2),
		@TotalPrestamosEmpresa decimal (18,2), 
		@fondoAhorroActual decimal (18,2),
		@cajaActual decimal (18,2)
	;

	select @TotalPrestamosCajaDeAhorro=Total from Nomina.fnBuscarSaldoActualPrestamosCajaAhorroConIntereses(@IDEmpleado)
	select @TotalPrestamosEmpresa=Total from Nomina.fnBuscarSaldoActualPrestamosEmpresa(@IDEmpleado)
	SELECT @Ejercicio = Ejercicio, @IDTipoNomina = IDTipoNomina FROM Nomina.tblCatPeriodos with(nolock) WHERE IDPeriodo = @IDPeriodo
	 
	select @IDFondoAhorro = IDFondoAhorro from Nomina.tblCatFondosAhorro where IDTipoNomina = @IDTipoNomina and Ejercicio = @Ejercicio
	select @IDCajaAhorro = IDCajaAhorro from [Nomina].[tblCajaAhorro] where IDEmpleado = @IDEmpleado

	select @fondoAhorroActual = ImporteTotal1 from Nomina.tblDetallePeriodo where IDPeriodo = @IDPeriodo and IDConcepto = 91 and IDEmpleado = @IDEmpleado
	select @cajaActual = ImporteTotal1 from Nomina.tblDetallePeriodo where IDPeriodo = @IDPeriodo and IDConcepto = 21 and IDEmpleado = @IDEmpleado


	--select @TotalPrestamosCajaDeAhorro as 'TotalPrestamosCajaDeAhorro' , @TotalPrestamosEmpresa as 'TotalPrestamosEmpresa',  @Ejercicio as 'Ejercicio', @IDFondoAhorro as 'IDFondoAhorro', @IDCajaAhorro as 'IDCajaAhorro', @fondoAhorroActual as 'fondoAhorroActual',  @cajaActual as 'cajaActual'
	--return


	IF OBJECT_ID('tempdb..#tblAcumuladoFondoAhorro') IS NOT NULL DROP TABLE #tblAcumuladoFondoAhorro    
	IF OBJECT_ID('tempdb..#tblAcumuladoCajaAhorro') IS NOT NULL DROP TABLE #tblAcumuladoCajaAhorro    
	IF OBJECT_ID('tempdb..#tblAcumuladoTotales') IS NOT NULL DROP TABLE #tblAcumuladoCajaAhorro    
    

	create table  #tblAcumuladoFondoAhorro  
	(
		TotalAportacionesEmpresa	    decimal(18,2)null --TotalAportacionesEmpresa		
		,TotalAportacionesTrabajador	decimal(18,2)null --TotalAportacionesTrabajador
		,TotalDevolucionesEmpresa	    decimal(18,2)null --TotalDevolucionesEmpresa
		,TotalDevolucionesTrabajador	decimal(18,2)null --TotalDevolucionesTrabajador
		,TotalRetirosEmpresa			decimal(18,2)null --TotalRetirosEmpresa
		,TotalRetirosTrabajador		    decimal(18,2)null --TotalRetirosTrabajador
		,TotalAcumulado				    decimal(18,2)null --TotalAcumulado
		,TotalPrestamosFondoAhorro	    decimal(18,2)null --TotalPrestamosFondoAhorro
		,TotalSaldoPendienteADescontar  decimal(18,2)null --TotalSaldoPendienteADescontar
		,NetoDisponible                 decimal(18,2)null --NetoDisponible
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
	EXEC  [Nomina].[spBuscarAcumuladoFondoAhorroPorEmpleadoyPeriodo]
		 @IDFondoAhorro	= @IDFondoAhorro
		,@IDEmpleado	= @IDEmpleado
		,@IDPeriodo		= @Idperiodo
		,@IDUsuario		= 1

	insert into #tblAcumuladoCajaAhorro
	EXEC  [Nomina].[spBuscarAcumuladoCajaAhorroPorEmpleadoyPeriodo_POLIACERO]
		 @IDCajaAhorro	= @IDCajaAhorro
		,@IDEmpleado	= @IDEmpleado	
		,@IDPeriodo = @IDPeriodo
		,@IDUsuario		= 1


	insert into #tblAcumuladoTotal(ACUMFondoAhorro,ACUMCajaAhorro,SaldoActualCajaAhorro,SaldoActualPrestamoCajaAhorro)
	select FA.TotalAcumulado as ACUMFondoAhorro,
		   CA.TotalAcumuladoCajaAhorro,
		   CA.NetoDisponible as SaldoActualCajaAhorro,
		   CA.TotalPrestamosPendientes
	from #tblAcumuladoFondoAhorro FA
		inner join  #tblAcumuladoCajaAhorro CA
			on 1 = 1

	select ACUMFondoAhorro,ACUMCajaAhorro,SaldoActualCajaAhorro,SaldoActualPrestamoCajaAhorro,@TotalPrestamosCajaDeAhorro as TotalPrestamosCajaDeAhorro,
		@TotalPrestamosEmpresa as TotalPrestamosEmpresa
	from #tblAcumuladoTotal

END
GO

USE [p_adagioRHAvilab]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Reportes].[spReportePrestamosFondoAhorroConAportaciones_ANS]
	-- Add the parameters for the stored procedure here	
    @ClaveEmpleadoInicial varchar (max) = '0'
	,@IDEstatusPrestamo varchar(max)		= ''    
	,@IDUsuario int
AS
BEGIN

    
    declare @Titulo varchar(max)

    SET @Titulo =  UPPER( 'REPORTE DE PRESTAMOS DE FONDO DE AHORRO')		
    

       SELECT top 300
/*em.ClaveEmpleado 
            ,em.NOMBRECOMPLETO
            ,em.Cliente
            ,em.TipoNomina
            ,em.TiposPrestacion
            ,em.Division
            
            ,IIF(em.Vigente=1 ,'SI','NO') as [VigenteHoy]
            ,em.Departamento
            ,em.Puesto
            ,em.Sucursal
            ,pre.Codigo as [CodigoPrestamo]
            ,pre.MontoPrestamo 
            ,pre.MontoPrestamo - (select sum(MontoCuota) from Nomina.tblPrestamosDetalles as o where o.IDPrestamo =pre.IDPrestamo) as [Saldo]
            ,pre.Intereses
            ,pre.Cuotas as [Descuento]
            ,pre.FechaInicioPago as [FechaPrestamo]        

            ,prede.FechaPago as [FechaAbono]
            ,prede.MontoCuota as [Abono]
            ,es.Descripcion [EstatusPrestamo]
            
            ,COALESCE(pe.ClavePeriodo,'') as [ClavePeriodo]
            ,COALESCE(pe.Descripcion,'') as [DescripcionPeriodo]      
*/
			pe.IDPeriodo
			,em.IDEmpleado
			,em.ClaveEmpleado 
            ,em.NOMBRECOMPLETO
            ,em.Cliente
            ,em.TipoNomina
            ,em.TiposPrestacion
            ,em.Division            
            ,IIF(em.Vigente=1 ,'SI','NO') as [VigenteHoy]
            ,em.Departamento
            ,em.Puesto
            ,em.Sucursal
			,pe.FechaFinPago
            ,dpcol.IDDetallePeriodo
			,dpcol.ImporteTotal1 [AportacionEmpresa]			
			,dpemp.ImporteTotal1 [AportacionColaborador]			 
			, dpcol.ImporteTotal1 + dpemp.ImporteTotal1 [TotalAportacion]
		 	,'APORT. FONDO AHORRO' [DescripcionConcepto]
			 
FROM  RH.tblEmpleadosMaster em
inner join Nomina.tblDetallePeriodo dpemp  on dpemp.IDEmpleado=em.IDEmpleado and dpemp.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos as c where  c.Codigo='308')
inner join Nomina.tblDetallePeriodo dpcol  on dpcol.IDEmpleado=em.IDEmpleado and dpcol.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos as c where  c.Codigo='309') AND dpcol.IDPeriodo=dpemp.IDPeriodo
inner join Nomina.tblCatPeriodos  as pe on dpemp.IDPeriodo=pe.IDPeriodo and pe.Ejercicio = 2021 
where (em.ClaveEmpleado  in ( select item from app.Split( @ClaveEmpleadoInicial,',')) or isnull(@ClaveEmpleadoInicial,'') = ''  OR @ClaveEmpleadoInicial='0')


ORDER by ClaveEmpleado ,IDPeriodo

END
GO

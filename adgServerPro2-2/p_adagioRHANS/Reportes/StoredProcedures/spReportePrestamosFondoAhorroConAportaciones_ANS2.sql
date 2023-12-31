USE [p_adagioRHANS]
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
CREATE PROCEDURE [Reportes].[spReportePrestamosFondoAhorroConAportaciones_ANS2]
     @Ejercicio int
    ,@ClaveEmpleadoInicial varchar (max)  
    ,@Cliente int
    ,@TipoNomina int 
	,@IDUsuario int
    ,@FechaIni datetime
    ,@FechaFin datetime

  /*Se añadieron variables para agregar filtros al reporte*/  
   
AS
BEGIN

set @TipoNomina = isnull(@TipoNomina,0)


if (@TipoNomina <> 0 ) 
begin 

-- Select @FechaIni = cp.FechaFinPago
-- from nomina.tblCatFondosAhorro fa
-- Inner join nomina.tblCatPeriodos cp On fa.IDPeriodoInicial = cp.IDPeriodo
-- Where fa.Ejercicio = @Ejercicio and fa.IDTipoNomina = @TipoNomina

-- Select @FechaFin = cp.FechaFinPago
-- from nomina.tblCatFondosAhorro fa
-- Inner join nomina.tblCatPeriodos cp On fa.IDPeriodoFinal = cp.IDPeriodo
-- Where fa.Ejercicio = @Ejercicio and fa.IDTipoNomina = @TipoNomina

--select * from nomina.tblCatPeriodos where IDTipoNomina = 5
     
    SELECT 
     
                pe.IDPeriodo
                ,em.IDEmpleado
                ,em.ClaveEmpleado 
                ,em.NOMBRECOMPLETO
                ,em.Cliente
                ,em.TipoNomina
                ,em.TiposPrestacion
                ,em.Division            
                ,IIF(em.Vigente=1,'SI','NO') as [VigenteHoy]
                ,em.Departamento
                ,em.Puesto
                ,em.Sucursal
                ,pe.FechaFinPago
                ,dpcol.IDDetallePeriodo
                ,dpcol.ImporteTotal1 [AportacionEmpresa]			
                ,dpemp.ImporteTotal1 [AportacionColaborador]			 
                ,dpcol.ImporteTotal1 + dpemp.ImporteTotal1 [TotalAportacion]
                ,'APORT. FONDO AHORRO' [DescripcionConcepto]
                
    FROM  RH.tblEmpleadosMaster em
    inner join Nomina.tblDetallePeriodo dpemp  on dpemp.IDEmpleado=em.IDEmpleado and dpemp.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos as c where  c.Codigo='308')
    inner join Nomina.tblDetallePeriodo dpcol  on dpcol.IDEmpleado=em.IDEmpleado and dpcol.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos as c where  c.Codigo='309') AND dpcol.IDPeriodo=dpemp.IDPeriodo
    inner join Nomina.tblCatPeriodos  as pe on dpemp.IDPeriodo=pe.IDPeriodo
    where (em.ClaveEmpleado  in ( select item from app.Split( @ClaveEmpleadoInicial,',')) or isnull(@ClaveEmpleadoInicial,'') = ''  OR  @ClaveEmpleadoInicial='0')
    and (pe.FechaFinPago BETWEEN @FechaIni and @FechaFin) and pe.IDTipoNomina = @TipoNomina
    ORDER by ClaveEmpleado ,FechaFinPago
    END





    Else 
        Begin
            /*-------------------------------Tabla Semanal-------------------------------------------*/
            if object_id('tempdb..#TablaNominaSemanal') is not null        
			drop table #TablaNominaSemanal 

            
            SELECT 
                pe.IDPeriodo
                ,em.IDEmpleado
                ,em.ClaveEmpleado 
                ,em.NOMBRECOMPLETO
                ,em.Cliente
                ,em.TipoNomina
                ,em.TiposPrestacion
                ,em.Division            
                ,IIF(em.Vigente=1,'SI','NO') as [VigenteHoy]
                ,em.Departamento
                ,em.Puesto
                ,em.Sucursal
                ,pe.FechaFinPago
                ,dpcol.IDDetallePeriodo
                ,dpcol.ImporteTotal1 [AportacionEmpresa]			
                ,dpemp.ImporteTotal1 [AportacionColaborador]			 
                ,dpcol.ImporteTotal1 + dpemp.ImporteTotal1 [TotalAportacion]
                ,'APORT. FONDO AHORRO' [DescripcionConcepto]
                INTO #TablaNominaSemanal
                FROM  RH.tblEmpleadosMaster em
                    inner join Nomina.tblDetallePeriodo dpemp  on dpemp.IDEmpleado=em.IDEmpleado and dpemp.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos as c where  c.Codigo='308')
                        inner join Nomina.tblDetallePeriodo dpcol  on dpcol.IDEmpleado=em.IDEmpleado and dpcol.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos as c where  c.Codigo='309') AND dpcol.IDPeriodo=dpemp.IDPeriodo
                            inner join Nomina.tblCatPeriodos  as pe on dpemp.IDPeriodo=pe.IDPeriodo
                where (em.ClaveEmpleado  in ( select item from app.Split( @ClaveEmpleadoInicial,',')) or isnull(@ClaveEmpleadoInicial,'') = ''  OR @ClaveEmpleadoInicial='0')
                and (pe.FechaFinPago BETWEEN @FechaIni and @FechaFin) and pe.IDTipoNomina = 4
                ORDER by ClaveEmpleado ,FechaFinPago

            /*-------------------------------Tabla Catorcenal-------------------------------------------*/

            if object_id('tempdb..#TablaNominaCatorcenal') is not null        
			    drop table #TablaNominaCatorcenal

            SELECT 
                pe.IDPeriodo
                ,em.IDEmpleado
                ,em.ClaveEmpleado 
                ,em.NOMBRECOMPLETO
                ,em.Cliente
                ,em.TipoNomina
                ,em.TiposPrestacion
                ,em.Division            
                ,IIF(em.Vigente=1,'SI','NO') as [VigenteHoy]
                ,em.Departamento
                ,em.Puesto
                ,em.Sucursal
                ,pe.FechaFinPago
                ,dpcol.IDDetallePeriodo
                ,dpcol.ImporteTotal1 [AportacionEmpresa]			
                ,dpemp.ImporteTotal1 [AportacionColaborador]			 
                ,dpcol.ImporteTotal1 + dpemp.ImporteTotal1 [TotalAportacion]
                ,'APORT. FONDO AHORRO' [DescripcionConcepto]
                INTO #TablaNominaCatorcenal
                FROM  RH.tblEmpleadosMaster em
                    inner join Nomina.tblDetallePeriodo dpemp  on dpemp.IDEmpleado=em.IDEmpleado and dpemp.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos as c where  c.Codigo='308')
                        inner join Nomina.tblDetallePeriodo dpcol  on dpcol.IDEmpleado=em.IDEmpleado and dpcol.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos as c where  c.Codigo='309') AND dpcol.IDPeriodo=dpemp.IDPeriodo
                            inner join Nomina.tblCatPeriodos  as pe on dpemp.IDPeriodo=pe.IDPeriodo
                where (em.ClaveEmpleado  in ( select item from app.Split( @ClaveEmpleadoInicial,',')) or isnull(@ClaveEmpleadoInicial,'') = ''  OR @ClaveEmpleadoInicial='0')
                and (pe.FechaFinPago BETWEEN @FechaIni and @FechaFin) and pe.IDTipoNomina = 5
                ORDER by ClaveEmpleado ,FechaFinPago


                Select * from #TablaNominaSemanal
                UNION
                Select * from #TablaNominaCatorcenal
                Order by ClaveEmpleado ,FechaFinPago




        End

END
GO

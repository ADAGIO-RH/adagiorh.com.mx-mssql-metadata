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
CREATE PROCEDURE [Reportes].[spReportePrestamosFondoAhorroConAportaciones_ANS_Excel]
     @dtFiltros [Nomina].[dtFiltrosRH] Readonly
	,@IDUsuario int
    
  /*Se añadieron variables para agregar filtros al reporte*/  
   
AS
BEGIN
DECLARE 
 @Ejercicio int
,@ClaveEmpleadoInicial varchar (max)  
,@Cliente int
,@TipoNomina int 
,@FechaIni date
,@FechaFin date
;
SET @FechaIni = isnull((Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaIni'),',')),convert(varchar, getdate(), 23))
SET @FechaFin = isnull((Select top 1 cast(item as varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'FechaFin'),',')),convert(varchar, getdate(), 23))
SET @Ejercicio = isnull((Select top 1 cast(item as Varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'Ejercicio'),',')),'0')
SET @ClaveEmpleadoInicial = isnull((Select top 1 cast(item as Varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'ClaveEmpleadoInicial'),',')),'0')
SET @TipoNomina = isnull((Select top 1 cast(item as Varchar(max)) from App.Split((Select top 1 Value from @dtFiltros where Catalogo = 'TipoNomina'),',')),'0')

set @TipoNomina = isnull(@TipoNomina,0)

if (@TipoNomina <> 0 ) 
begin 
  
    SELECT 
     
                 em.ClaveEmpleado 
                ,em.NOMBRECOMPLETO
                ,em.Cliente
                ,em.TipoNomina           
                ,IIF(em.Vigente=1,'SI','NO') as [VigenteHoy]
                ,FORMAT(CAST(pe.FechaFinPago AS DATE),'dd/MM/yyyy') as [Fecha]
                ,pe.Descripcion [Descripcion]
                ,'APORT. FONDO AHORRO' [DescripcionConcepto]
                ,dpcol.ImporteTotal1 [AportacionEmpresa]			
                ,dpemp.ImporteTotal1 [AportacionColaborador]			 
                ,dpcol.ImporteTotal1 + dpemp.ImporteTotal1 [TotalAportacion]
                
    FROM  RH.tblEmpleadosMaster em
    inner join Nomina.tblDetallePeriodo dpemp  on dpemp.IDEmpleado=em.IDEmpleado and dpemp.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos as c where  c.Codigo='308')
    inner join Nomina.tblDetallePeriodo dpcol  on dpcol.IDEmpleado=em.IDEmpleado and dpcol.IDConcepto = (select IDConcepto from Nomina.tblCatConceptos as c where  c.Codigo='309') AND dpcol.IDPeriodo=dpemp.IDPeriodo
    inner join Nomina.tblCatPeriodos  as pe on dpemp.IDPeriodo=pe.IDPeriodo
    where (em.ClaveEmpleado  in ( select item from app.Split( @ClaveEmpleadoInicial,',')) or isnull(@ClaveEmpleadoInicial,'') = ''  OR @ClaveEmpleadoInicial='0')
    and (pe.FechaFinPago BETWEEN @FechaIni and @FechaFin) and pe.IDTipoNomina = @TipoNomina
    ORDER by ClaveEmpleado ,FechaFinPago
    END





    Else 
        Begin
            /*-------------------------------Tabla Semanal-------------------------------------------*/
            if object_id('tempdb..#TablaNominaSemanal') is not null        
			drop table #TablaNominaSemanal 

            
            SELECT 
                 em.ClaveEmpleado 
                ,em.NOMBRECOMPLETO
                ,em.Cliente
                ,em.TipoNomina           
                ,IIF(em.Vigente=1,'SI','NO') as [VigenteHoy]
                ,pe.FechaFinPago 
                ,pe.Descripcion
                ,'APORT. FONDO AHORRO' [DescripcionConcepto]
                ,dpcol.ImporteTotal1 [AportacionEmpresa]			
                ,dpemp.ImporteTotal1 [AportacionColaborador]			 
                ,dpcol.ImporteTotal1 + dpemp.ImporteTotal1 [TotalAportacion]
                
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
                
                em.ClaveEmpleado 
                ,em.NOMBRECOMPLETO
                ,em.Cliente
                ,em.TipoNomina           
                ,IIF(em.Vigente=1,'SI','NO') as [VigenteHoy]
                ,pe.FechaFinPago 
                ,pe.Descripcion
                ,'APORT. FONDO AHORRO' [DescripcionConcepto]
                ,dpcol.ImporteTotal1 [AportacionEmpresa]			
                ,dpemp.ImporteTotal1 [AportacionColaborador]			 
                ,dpcol.ImporteTotal1 + dpemp.ImporteTotal1 [TotalAportacion]
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

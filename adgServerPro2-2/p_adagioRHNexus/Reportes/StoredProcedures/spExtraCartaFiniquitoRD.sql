USE [p_adagioRHNexus]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select * from RH.tblEmpleados where ClaveEmpleado = 'JM00604'
--select * from nomina.tblCatTipoNomina
CREATE PROCEDURE [Reportes].[spExtraCartaFiniquitoRD] --577, 99, 1     
(      
  @ClaveEmpleado VARCHAR(10), 
  @IDEmpleado int,        
  @IDPeriodo int,
  @IDUsuario int        
)      
AS      
BEGIN      
       
DECLARE       
  @empleados [RH].[dtEmpleados]      
  ,@periodo [Nomina].[dtPeriodos]      
  ,@Conceptos [Nomina].[dtConceptos]      
  ,@dtFiltros [Nomina].[dtFiltrosRH]      
  ,@fechaIniPeriodo  date      
  ,@fechaFinPeriodo  date      
  ,@Finiquito bit
  ,@diasPagables int
  ,@IDConceptoRD151 INT --SalarioPromDiario
  ,@IDConceptoRD120 int --SalarioVacaciones
       
      
 if(isnull(@IDEmpleado,'')<>'')      
   BEGIN      
   insert into @dtFiltros(Catalogo,Value)      
   values('Empleados',case when @IDEmpleado is null then '' else @IDEmpleado end)      
   END
   ELSE
   BEGIN
   Select @IDEmpleado = IDEmpleado from rh.tblEmpleadosMaster where ClaveEmpleado = @ClaveEmpleado
   insert into @dtFiltros(Catalogo,Value)      
   values('Empleados',case when @IDEmpleado is null then '' else @IDEmpleado end)
   END     
      



    Insert into @periodo(IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,Especial,Cerrado)      
    select IDPeriodo,IDTipoNomina,Ejercicio,ClavePeriodo,Descripcion,FechaInicioPago,FechaFinPago,FechaInicioIncidencia,FechaFinIncidencia,Dias,AnioInicio,AnioFin,MesInicio,MesFin,IDMes,BimestreInicio,BimestreFin,General,Finiquito,isnull(Especial,0),Cerrado   
    from Nomina.TblCatPeriodos      
    where IDPeriodo = @IDPeriodo      
      
      
    select @fechaIniPeriodo = FechaInicioPago, @fechaFinPeriodo =FechaFinPago, @Finiquito = ISNULL(Finiquito,0)      
    from Nomina.TblCatPeriodos      
    where IDPeriodo = @IDPeriodo      

    select @IDConceptoRD151=IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo='RD151'
    select @IDConceptoRD120=IDConcepto FROM Nomina.tblCatConceptos WHERE Codigo='RD120'
      
    insert into @empleados      
    exec [RH].[spBuscarEmpleadosMaster]@FechaIni = @fechaIniPeriodo, @Fechafin= @fechaFinPeriodo, @dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario      
       
    select       
    cat.Codigo,
    dp.*
    from       
  Nomina.tblDetallePeriodo dp      
   inner join @periodo p       
    on dp.IDPeriodo = p.IDPeriodo      
   inner join @empleados e       
    on e.IDEmpleado = dp.IDEmpleado 
inner join nomina.tblCatConceptos cat 
on cat.IDConcepto = dp.IDConcepto   
where cat.IDConcepto in (@IDConceptoRD151,@IDConceptoRD120)  
END
GO

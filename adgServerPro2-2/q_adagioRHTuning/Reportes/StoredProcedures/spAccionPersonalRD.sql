USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reportes].[spAccionPersonalRD] --577, 99, 1     
(  
  @ClaveEmpleado VARCHAR(10),      
  @Empleados int,        
  @IDUsuario int        
)      
AS      
BEGIN      
       
DECLARE       
  @empleadosM [RH].[dtEmpleados]      
  ,@periodo [Nomina].[dtPeriodos]      
  ,@Conceptos [Nomina].[dtConceptos]      
  ,@dtFiltros [Nomina].[dtFiltrosRH]      
  ,@fechaIniPeriodo  date      
  ,@fechaFinPeriodo  date      
  ,@Finiquito bit
  ,@diasPagables int
  ,@IDConceptoRD010 INT
       
      
 if(isnull(@Empleados,'')<>'')      
   BEGIN      
   insert into @dtFiltros(Catalogo,Value)      
   values('Empleados',case when @Empleados is null then '' else @Empleados end)      
   END
   ELSE
   BEGIN
   Select @Empleados = IDEmpleado from rh.tblEmpleadosMaster where ClaveEmpleado = @ClaveEmpleado
   insert into @dtFiltros(Catalogo,Value)      
   values('Empleados',case when @Empleados is null then '' else @Empleados end)
   END     
      



   
      


      
    insert into @empleadosM      
    exec [RH].[spBuscarEmpleadosMaster]@dtFiltros = @dtFiltros, @IDUsuario = @IDUsuario      
     
    select    
     (Select NOMBRECOMPLETO from rh.tblJefesEmpleados j inner join rh.tblEmpleadosMaster em on j.IDJefe= em.IDEmpleado where j.IDEmpleado = @Empleados) as JEFENOMBRE ,  
     (Select Puesto from rh.tblJefesEmpleados j inner join rh.tblEmpleadosMaster em on j.IDJefe= em.IDEmpleado where j.IDEmpleado = @Empleados) as JEFEPuesto ,
     Convert(varchar , e.FechaAntiguedad,103) as FechaAntiguedadVar ,  
     Convert(varchar , e.FechaIngreso,103) as FechaIngresoVar ,  
     Convert(varchar , e.FechaIniContrato,103) as FechaIniContratoVar ,  
     Convert(varchar , e.FechaPrimerIngreso,103) as FechaPrimerIngresoVar ,
     Convert(varchar , getdate(),103) as today ,

     *  
 from
  @empleadosM e
  left join rh.tblPagoEmpleado pe on e.IDEmpleado = pe.IDEmpleado 
  
       
END
GO

USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reportes].[spPagoVacacionRD] --577, 99, 1     
(  
  @IDPeriodo int , 
  @ClaveEmpleado VARCHAR(10),      
  @Empleados int,        
  @IDUsuario int,   
  @FechaIni date     
)      
AS      
BEGIN      
       
DECLARE       
  @empleadosM [RH].[dtEmpleados]      
  ,@periodo [Nomina].[dtPeriodos]           
  ,@dtFiltros [Nomina].[dtFiltrosRH]      
  ,@IDConceptoRD120  int   

 Select @IDConceptoRD120 = IDConcepto from Nomina.tblCatConceptos where Codigo = 'RD120'
      
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
     Convert(varchar , e.FechaAntiguedad,103) as FechaAntiguedadDate,  
     (Select NOMBRECOMPLETO from rh.tblJefesEmpleados j inner join rh.tblEmpleadosMaster em on j.IDJefe= em.IDEmpleado where j.IDEmpleado = @Empleados) as JEFENOMBRE ,  
     (Select Puesto from rh.tblJefesEmpleados j inner join rh.tblEmpleadosMaster em on j.IDJefe= em.IDEmpleado where j.IDEmpleado = @Empleados) as JEFEPuesto ,
     CAST((DATEDIFF(Day, e.FechaAntiguedad,GETDATE())/30.4375)/12 as int ) as Añostrabajados,
     CAST((DATEDIFF(Day,e.FechaAntiguedad,GETDATE())/30.4375)%12 as int ) as Mesestrabajados,
     CAST((((DATEDIFF(Day,e.FechaAntiguedad,GETDATE())/30.4375)%12)%1)*30.4375 as int ) as Diastrabajados,
     Convert(varchar , se.FechaIni,103) as FechaIniVaca, 
     Convert(varchar , se.FechaFin,103) as FechaFinVaca, 
     *  
 From @empleadosM e
    Inner join nomina.tblDetallePeriodo dp 
        on dp.IDEmpleado = e.IDEmpleado 
        and dp.IDPeriodo = @IDPeriodo
    Inner join Nomina.tblCatPeriodos cat 
        on cat.IDPeriodo = dp.IDPeriodo
    LEFT join Intranet.tblSolicitudesEmpleado se 
        on se.IDEmpleado = e.IDEmpleado
        and se.FechaIni = @FechaIni
    Where dp.IDConcepto = @IDConceptoRD120
   
END
GO

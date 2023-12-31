USE [q_adagioRHTuning]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Reportes].[spSolicitudesIntranetVacacionesRD] --577, 99, 1     
(  
  @ClaveEmpleado VARCHAR(10),      
  @Empleados int,        
  @IDUsuario int        
)      
AS      
BEGIN      
       
DECLARE       
   @empleadosM [RH].[dtEmpleados]          
  ,@dtFiltros [Nomina].[dtFiltrosRH]      

       
      
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
    s.IDEmpleado, 
    Convert(varchar ,s.FechaFin,103) as FechaFin,
    Convert(varchar ,s.FechaCreacion,103) as FechaCreacion,
    s.DiasDescanso,
    s.FechaIni,
    Convert(varchar ,s.FechaIni,103) as FechaIni2,
    Convert(varchar,DATEADD(day,1,s.FechaFin),103) as FechaReingreso,
    s.CantidadDias, 
    ROW_NUMBER() OVER(Order by FechaIni Asc) as Periodo 
from Intranet.tblSolicitudesEmpleado s 
    inner join @empleadosM em 
    on em.IDEmpleado = s.IDEmpleado 
where  s.IDTipoSolicitud = 1 and s.IDEstatusSolicitud = 2   

END
GO

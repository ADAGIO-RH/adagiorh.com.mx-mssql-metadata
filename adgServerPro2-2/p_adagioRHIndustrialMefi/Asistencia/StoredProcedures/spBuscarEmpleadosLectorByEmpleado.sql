USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Asistencia.spBuscarEmpleadosLectorByEmpleado  
(  
  
 @IDEmpleado int  
)  
AS  
BEGIN  
  
SELECT   
   le.IDLectorEmpleado  
     ,em.IDEmpleado  
  ,em.ClaveEmpleado  
  ,em.NOMBRECOMPLETO  
  ,em.Puesto  
  ,em.Departamento  
  ,em.Sucursal  
  ,l.IDLector as IDLector  
  ,l.Lector as Lector  
  ,ROW_NUMBER()Over(ORder by le.IDLectorEmpleado)  as ROWNUMBER
FROM rh.tblEmpleadosMaster em  
 inner join Asistencia.tblLectoresEmpleados le  
  on em.IDEmpleado = le.IDEmpleado  
 inner join Asistencia.tblLectores l  
  on le.IDLector = l.IDLector  
where le.IDEmpleado = @IDEmpleado
  
  
END
GO

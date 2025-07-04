USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************     
** Descripción  : Busca las Programaciones de cursos de cpacitacion de los empleados NO Aprovado   
** Autor   : Jose Roman   
** Email   : jose.roman@adagio.com.mx    
** FechaCreacion : 2019-01-01    
** Paremetros  :                  
    
** DataTypes Relacionados:     
****************************************************************************************************    
HISTORIAL DE CAMBIOS    
Fecha(yyyy-mm-dd) Autor   Comentario    
------------------- ------------------- ------------------------------------------------------------    
2019-05-10   Aneudy Abreu Se agregó el parámetro @IDUsuario y el JOIN a la tabla de     
         Seguridad.tblDetalleFiltrosEmpleadosUsuarios    
***************************************************************************************************/    
CREATE PROCEDURE [STPS].[spBuscarEmpleadosProgramacionCursosCapacitacionNOAprovados]  (      
 @IDProgramacionCursoCapacitacion int      
 ,@IDUsuario int    
)      
AS      
BEGIN      
 SELECT       
  pcce.IDProgramacionCursosCapacitacionEmpleados      
  ,em.IDEmpleado      
  ,em.ClaveEmpleado      
  ,em.NOMBRECOMPLETO      
  ,em.Puesto      
  ,em.Departamento      
  ,em.Sucursal      
  ,pcc.IDProgramacionCursoCapacitacion as IDProgramacionCursoCapacitacion       
 FROM rh.tblEmpleadosMaster em with (nolock)    
  inner join STPS.tblProgramacionCursosCapacitacionEmpleados pcce with (nolock) on em.IDEmpleado = pcce.IDEmpleado      
  inner join STPS.tblProgramacionCursosCapacitacion pcc with (nolock) on pcc.IDProgramacionCursoCapacitacion = pcce.IDProgramacionCursoCapacitacion      
  inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario
  inner join STPS.tblEstatusCursosEmpleados ECE with (nolock) on  isnull(pcce.IDEstatusCursoEmpleados,1) = ECE.IDEstatusCursoEmpleados   
 where PCCE.IDProgramacionCursoCapacitacion = @IDProgramacionCursoCapacitacion      
 and ECE.Descripcion = 'NO APROBADO'
   order by EM.ClaveEmpleado ASC
END;
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Listado de Asistencia de colaboradores a cursos  
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
CREATE PROCEDURE [Reportes].[spBuscarListaEmpleadosCursosCapacitacion] --1002,1
 (    
 @IDProgramacionCursoCapacitacion int    
 ,@IDUsuario int  
)    
AS    
BEGIN    

SET FMTONLY OFF

 SELECT     
  pcce.IDProgramacionCursosCapacitacionEmpleados    
  ,em.IDEmpleado    
  ,em.ClaveEmpleado    
  ,em.NOMBRECOMPLETO    
  ,em.Puesto    
  ,em.Departamento    
  ,em.Sucursal    
  ,pcc.IDProgramacionCursoCapacitacion as IDProgramacionCursoCapacitacion 
  ,FORMAT(SCC.FechaHoraInicial,'dd/MM/yyyy HH:mm') + ' - '+ FORMAT(SCC.FechaHoraFinal,'HH:mm') +' - '+ SC.Nombre as Fecha
 FROM [RH].[tblEmpleadosMaster] em with (nolock)  
  inner join STPS.tblProgramacionCursosCapacitacionEmpleados pcce with (nolock) on em.IDEmpleado = pcce.IDEmpleado    
  inner join STPS.tblProgramacionCursosCapacitacion pcc with (nolock) on pcc.IDProgramacionCursoCapacitacion = pcce.IDProgramacionCursoCapacitacion    
  inner join STPS.tblSesionesCursosCapacitacion SCC with (nolock) on SCC.IDProgramacionCursoCapacitacion = PCCE.IDProgramacionCursoCapacitacion
  left join STPS.tblSalasCapacitacion SC on SCC.IDSalaCapacitacion = SC.IDSalaCapacitacion
  inner join Seguridad.tblDetalleFiltrosEmpleadosUsuarios dfe with (nolock) on dfe.IDEmpleado = em.IDEmpleado and dfe.IDUsuario = @IDUsuario  
 where PCCE.IDProgramacionCursoCapacitacion = @IDProgramacionCursoCapacitacion    
END;
GO

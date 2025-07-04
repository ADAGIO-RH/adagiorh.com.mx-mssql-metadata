USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE STPS.spBuscarCursosAprobadosEmpleado  
(  
 @IDEmpleado int,  
 @IDUsuario int  
)  
AS  
BEGIN  
   
   
 select M.IDEmpleado,  
     M.ClaveEmpleado,   
     CC.Codigo as CodigoCurso,  
     CC.Nombre as NombreCurso,  
     FORMAT(PCC.FechaIni,'dd/MM/yyyy') +' - '+  FORMAT(PCC.FechaFin,'dd/MM/yyyy') as Fechas  
 from RH.tblEmpleadosMaster M  
  inner join STPS.tblProgramacionCursosCapacitacionEmpleados CCE  
   on CCE.IDEmpleado = M.IDEmpleado  
  inner join STPS.tblProgramacionCursosCapacitacion PCC  
   on PCC.IDProgramacionCursoCapacitacion = CCE.IDProgramacionCursoCapacitacion  
  Inner join STPS.tblCursosCapacitacion CC  
   on CC.IDCursoCapacitacion = PCC.IDCursoCapacitacion  
 WHERE M.IDEmpleado = @IDEmpleado  
	and isnull(CCE.IDEstatusCursoEmpleados,(select top 1 IDEstatusCursoEmpleados from STPS.tblEstatusCursosEmpleados where Descripcion = 'NO EVALUADO')) = (select top 1 IDEstatusCursoEmpleados from STPS.tblEstatusCursosEmpleados where Descripcion = 'APROBADO')
 Order by PCC.FechaIni desc  
  
END
GO

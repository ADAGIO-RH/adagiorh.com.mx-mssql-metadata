USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spBuscarParticipantesDeEmpleadoProyecto] (
	@IDEmpleadoProyecto int 
) as

--declare  @IDEmpleadoProyecto int = 41081

    SET NOCOUNT ON;
     IF 1=0 BEGIN
       SET FMTONLY OFF
     END

select em.*,evaluador.NOMBRECOMPLETO,ctp.Relacion
from [Evaluacion360].[tblEvaluacionesEmpleados] em
	join [Evaluacion360].[tblCatTiposRelaciones] ctp on em.IDTipoRelacion = ctp.IDTipoRelacion
	join [RH].[tblEmpleadosMaster] evaluador on evaluador.IDEmpleado = em.IDEvaluador

where em.IDEmpleadoProyecto = @IDEmpleadoProyecto
GO

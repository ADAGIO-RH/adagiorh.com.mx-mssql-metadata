USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROC [Evaluacion360].[spSePuedoModificarElProyecto](  
 @IDProyecto int  
 ,@IDUsuario int  
) as  
  
  
DECLARE  
 @IDEstatusProyecto int = 0  
 ;  
  
  
 SELECT TOP 1 @IDEstatusProyecto = tep.IDEstatus  
 FROM Evaluacion360.tblEstatusProyectos tep  
 WHERE tep.IDProyecto = @IDProyecto  
 ORDER BY FechaCreacion DESC  
  
 --SELECT @IDEstatusProyecto  
  
 IF (@IDEstatusProyecto IN (4,5,6))  
 BEGIN  
	raiserror('Error, no se puede modificar el proyecto',16,1);
  --EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '1318003'  
  return 0;  
 end;  
-- SELECT * FROM Evaluacion360.tblCatEstatus tce  
GO

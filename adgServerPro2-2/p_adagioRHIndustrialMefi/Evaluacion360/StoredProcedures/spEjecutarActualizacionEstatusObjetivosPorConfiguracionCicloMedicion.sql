USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Evaluacion360].[spEjecutarActualizacionEstatusObjetivosPorConfiguracionCicloMedicion] as
BEGIN
	DECLARE	
         @FechaHoy date =GETDATE()        	        
        ,@IDUsuarioAdmin INT = 1
        ,@ID_ESTATUS_AUTORIZACION_AUTORIZADO INT = 2
        ,@ID_ESTATUS_OBJETIVO_EMPLEADO_CONSEGUIDO INT=5
        ,@ID_ESTATUS_OBJETIVO_EMPLEADO_NO_CONSEGUIDO INT=6
        ,@ID_ESTATUS_OBJETIVO_EMPLEADO_CANCELADO INT=7
        ,@ID_ESTATUS_OBJETIVO_EMPLEADO_PENDIENTE_DE_AUTORIZACION INT=8
        ,@ID_ESTATUS_OBJETIVO_EMPLEADO_NO_AUTORIZADO INT=9
	;

    
    if object_id('tempdb..#tempCiclosMedicionTrabajables') is not null drop table #tempCiclosMedicionTrabajables;



    SELECT CM.*
        INTO #tempCiclosMedicionTrabajables
    FROM Evaluacion360.tblCatCiclosMedicionObjetivos cm
    WHERE FechaParaActualizacionEstatusObjetivos=@FechaHoy


    IF NOT EXISTS(SELECT TOP 1 1 FROM #tempCiclosMedicionTrabajables)
    BEGIN
        PRINT 'No existen ciclos de medición trabajables'
        RETURN;
    END

    
    
   
    UPDATE Evaluacion360.tblObjetivosEmpleados
    SET IDEstatusObjetivoEmpleado= CASE WHEN PorcentajeAlcanzado >= 100 THEN @ID_ESTATUS_OBJETIVO_EMPLEADO_CONSEGUIDO ELSE @ID_ESTATUS_OBJETIVO_EMPLEADO_NO_CONSEGUIDO END 
    WHERE IDEstatusAutorizacion=@ID_ESTATUS_AUTORIZACION_AUTORIZADO 
      AND IDEstatusObjetivoEmpleado NOT IN(
         @ID_ESTATUS_OBJETIVO_EMPLEADO_CONSEGUIDO 
        ,@ID_ESTATUS_OBJETIVO_EMPLEADO_NO_CONSEGUIDO 
        ,@ID_ESTATUS_OBJETIVO_EMPLEADO_CANCELADO 
        ,@ID_ESTATUS_OBJETIVO_EMPLEADO_PENDIENTE_DE_AUTORIZACION 
        ,@ID_ESTATUS_OBJETIVO_EMPLEADO_NO_AUTORIZADO 
      )
      AND IDCicloMedicionObjetivo IN (SELECT IDCicloMedicionObjetivo FROM #tempCiclosMedicionTrabajables)



   
    

    
END
GO

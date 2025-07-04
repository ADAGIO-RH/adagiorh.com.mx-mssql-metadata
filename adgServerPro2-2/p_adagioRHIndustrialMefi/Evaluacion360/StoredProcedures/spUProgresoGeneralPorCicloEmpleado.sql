USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   proc [Evaluacion360].[spUProgresoGeneralPorCicloEmpleado](
		@IDCicloMedicionObjetivo int,
		@IDEmpleado int
) as
	declare 
		@Porcentaje decimal(18, 2)=0.00
       ,@ID_ESTATUS_OBJETIVO_CANCELADO int=7
       ,@ID_ESTATUS_OBJETIVO_EMPLEADO_PENDIENTE_AUTORIZAR INT = 8                   
       ,@ID_ESTATUS_OBJETIVO_EMPLEADO_SIN_AUTORIZAR INT = 9;

    

    SELECT 
		@Porcentaje = cast(sum((PorcentajeAlcanzado*(case when isnull(Peso, 0) = 0 then 100 else  Peso end))) /SUM(case when isnull(Peso, 0) = 0 then 100 else  Peso end) as decimal(18,2))
	FROM Evaluacion360.tblObjetivosEmpleados oe
	WHERE OE.IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo 
      AND oe.IDEmpleado = @IDEmpleado 
      AND IDEstatusObjetivoEmpleado 
          NOT IN ( @ID_ESTATUS_OBJETIVO_CANCELADO
                  ,@ID_ESTATUS_OBJETIVO_EMPLEADO_PENDIENTE_AUTORIZAR
                  ,@ID_ESTATUS_OBJETIVO_EMPLEADO_SIN_AUTORIZAR )
	GROUP BY oe.IDEmpleado


	MERGE INTO Evaluacion360.tblProgresoGeneralPorCicloEmpleados AS target
	USING (
		SELECT 
			@IDCicloMedicionObjetivo AS IDCicloMedicionObjetivo, 
			@IDEmpleado AS IDEmpleado,
			@Porcentaje AS Porcentaje
	) AS source
		ON (target.IDCicloMedicionObjetivo = source.IDCicloMedicionObjetivo and target.IDEmpleado = source.IDEmpleado)
	WHEN MATCHED THEN
		UPDATE 
			SET target.Porcentaje = source.Porcentaje
	WHEN NOT MATCHED THEN
	INSERT (IDCicloMedicionObjetivo, IDEmpleado, Porcentaje)
	VALUES (source.IDCicloMedicionObjetivo, source.IDEmpleado, source.Porcentaje);
GO

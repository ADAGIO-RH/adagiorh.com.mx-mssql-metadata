USE [p_adagioRHHPM]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc Evaluacion360.spUProgresoGeneralPorCicloEmpleado(
		@IDCicloMedicionObjetivo int,
		@IDEmpleado int
) as
	declare 
		@Porcentaje decimal(18, 2)

	select 
		@Porcentaje = cast(sum((PorcentajeAlcanzado*(case when isnull(Peso, 0) = 0 then 100 else  Peso end))) /SUM(case when isnull(Peso, 0) = 0 then 100 else  Peso end) as decimal(18,2))
	from Evaluacion360.tblCatObjetivos o
		join Evaluacion360.tblObjetivosEmpleados oe on oe.IDObjetivo = o.IDObjetivo
	where o.IDCicloMedicionObjetivo = @IDCicloMedicionObjetivo and oe.IDEmpleado = @IDEmpleado
	group by oe.IDEmpleado

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

USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
	Catálogo de estatus
		1 - Sin comenzar
		2 - En progreso
		3 - Atrasado
		4 - En riesgo
		5 - Cumplido
		6 - Cancelado

	exec Evaluacion360.spBuscarEstatusObjetivos @IDUsuario=1
*/
CREATE   proc Evaluacion360.spUProgresoObjetivo(
	@IDObjetivo int,
	@IDUsuario int
) as

	declare	
		@IDEstatusActual int,
		@Progreso decimal(18, 2)
	;


	select @Progreso = cast(SUM(PorcentajeAlcanzado)/cast(count(*) as decimal(18,2)) as decimal(18,2))
	from Evaluacion360.tblObjetivosEmpleados
	where IDObjetivo = @IDObjetivo


	update Evaluacion360.tblCatObjetivos
		set 
			Progreso = @Progreso,
			IDEstatusObjetivo = 
				case 
					when IDEstatusObjetivo in (1,2,3,4) and @Progreso >= 100.00 then 5
					when IDEstatusObjetivo = 1 and @Progreso between 1 and 99.99 then 2
				else IDEstatusObjetivo
				end
	where IDObjetivo = @IDObjetivo
GO

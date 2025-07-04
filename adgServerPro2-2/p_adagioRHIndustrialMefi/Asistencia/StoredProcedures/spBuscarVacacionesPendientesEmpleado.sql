USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



/**************************************************************************************************** 
** Descripción		: Procedimiento para obtener las vacaciones pentientes por Tomar de un Empleado
** Autor			: Jose Roman
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 16-08-2018
** Paremetros		:              


[Asistencia].[spBuscarVacacionesPendientesEmpleado] @IDEmpleado = 1279,@IDUsuario = 1

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2019-04-11			Aneudy Abreu	Se sustityó el código anterior para usar el sp [Asistencia].[spBuscarSaldosVacacionesPorAnios] 
									que ya existia.
***************************************************************************************************/
--select * from RH.tblEmpleados where IDEmpleado = 20314
--select * from RH.tblCatTiposPrestaciones

CREATE PROCEDURE [Asistencia].[spBuscarVacacionesPendientesEmpleado] --20314,1,'2018-06-21','2019-08-16',1
(
	@IDEmpleado int,
	@IDTipoPrestacion int = null,
	@FechaIni Date = null,
	@FechaFin Date = null,
	@IDUsuario int	 
)
AS
BEGIN
	declare @saldosVacaciones [Asistencia].[dtSaldosDeVacaciones] ;

	insert @saldosVacaciones
	exec [Asistencia].[spBuscarSaldosVacacionesPorAnios] @IDEmpleado=@IDEmpleado,@IDUsuario=@IDUsuario

	select sum(isnull(DiasDisponibles,0)) as Saldo, @IDEmpleado as IDEmpleado from @saldosVacaciones

	--DECLARE @VacacionesTomadas int,
	--		@Antiguedad decimal(18,2),
			
	--		@VacacionesCompletas int,
	--		@VacacionesParciales decimal(18,4),
	--		@Saldo decimal(18,2) = 0

	--Select @VacacionesTomadas = [Asistencia].[fnBuscarIncidenciasEmpleado](@IDEmpleado,'V',@FechaIni,@FechaFin)
	----select @VacacionesTomadas as VacacionesTomadas

	--Select @Antiguedad = Cast(DATEDIFF(DAY,@FechaIni,@FechaFin) as decimal)/365.0
	----select @Antiguedad

	--Select @VacacionesCompletas = SUM(DiasVacaciones) 
	--from [RH].[tblCatTiposPrestacionesDetalle]
	--where IDTipoPrestacion = @IDTipoPrestacion
	--	and Antiguedad <= case when @Antiguedad < 1 then 1 Else @Antiguedad END
	----select @VacacionesCompletas as VacacionesCompletas


	--Select top 1 @VacacionesParciales = (CAST(DiasVacaciones as decimal)/365) * (365 * (@Antiguedad - CAST(@Antiguedad as int)))
	--from [RH].[tblCatTiposPrestacionesDetalle]
	--where IDTipoPrestacion = @IDTipoPrestacion
	--	and Antiguedad > case when @Antiguedad < 1 then 1 Else @Antiguedad END
	--ORDER BY Antiguedad ASC
	----select @VacacionesParciales as VacacionesParciales

	--Select @Saldo = case when @Antiguedad < 1 then @VacacionesParciales - @VacacionesTomadas Else (@VacacionesCompletas+@VacacionesParciales) - @VacacionesTomadas END
	

	--select @Saldo as Saldo
END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*

[Nomina].[spBuscarFondoAhorroDisponibleParaSolicitudesPrestamos] 1279

*/

CREATE proc [Nomina].[spBuscarFondoAhorroDisponibleParaSolicitudesPrestamos](
	@IDEmpleado int,
	@IDUsuario int
) as
	declare 
		@IDTipoNomina int
	;
	select @IDTipoNomina = IDTipoNomina from RH.tblEmpleadosMaster with (nolock) where IDEmpleado = @IDEmpleado

	select 
		fa.IDFondoAhorro,
		cast(fa.Ejercicio as varchar(4))+' - '+tn.Descripcion as FondoAhorro
	from Nomina.tblCatFondosAhorro fa with (nolock)
		join Nomina.tblCatTipoNomina tn on tn.IDTipoNomina = fa.IDTipoNomina
		left join Nomina.tblCatPeriodos pInicial with (nolock) on pInicial.IDPeriodo = fa.IDPeriodoInicial and pInicial.IDTipoNomina = @IDTipoNomina
		left join Nomina.tblCatPeriodos pFinal with (nolock) on pFinal.IDPeriodo = fa.IDPeriodoFinal and pFinal.IDTipoNomina = @IDTipoNomina
	where fa.IDTipoNomina = @IDTipoNomina and (cast(getdate() as date) between isnull(pInicial.FechaInicioPago,'1990-01-01') and isnull(pFinal.FechaFinPago,'2100-12-31'))
GO

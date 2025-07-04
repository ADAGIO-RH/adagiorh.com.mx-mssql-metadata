USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Procedimiento para obtener los días de pago para un finiquito
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 08-08-2019
** Paremetros		:              

[Nomina].[spBuscarDiasDePagoFiniquito] 1279, '2019-08-05',1

****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00		NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE [Nomina].[spBuscarDiasDePagoFiniquito](
	@IDEmpleado int,
	@FechaBaja Date,
	@IDUsuario int
)
AS
BEGIN
	--declare 
	--	@IDEmpleado int = 1279,
	--	@Fecha Date	= '2019-08-05'
	--	;

	declare 
		@IDTipoNomina int = 0
		,@FechaInicioPago date
		;

	select @IDTipoNomina = IDTipoNomina
	from RH.tblEmpleadosMaster with (nolock)
	where IDEmpleado = @IDEmpleado

	--select *
	--from Nomina.tblHistorialesEmpleadosPeriodos with (nolock)
	--where IDEmpleado = @IDEmpleado

	select top 1 @FechaInicioPago = FechaInicioPago
	from Nomina.tblCatPeriodos with (nolock)
	where IDTipoNomina = @IDTipoNomina 
		and isnull(General,0) = 1 
		and isnull(Cerrado,0) = 0 
		and @FechaBaja between FechaInicioPago and FechaFinPago

	select isnull(CAST(DATEDIFF(DAY,@FechaInicioPago,@FechaBaja) + 1 as decimal(18,2)),0) as Saldo
END
GO

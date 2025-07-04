USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBuscarTipoTrabajadorEmpleado]
(
	@IDEmpleado int
)
AS
BEGIN
	Select 
		PE.IDTipoTrabajadorEmpleado,
		PE.IDEmpleado,
		ISNULL(PE.IDTipoTrabajador,0) as IDTipoTrabajador,
		P.Descripcion as TipoTrabajador,
		isnull(PE.IDTipoContrato,0) as IDTipoContrato,
		TC.Descripcion as TipoContrato,
		isnull(PE.IDTipoSalario,0) as IDTipoSalario,
		TS.Descripcion as TipoSalario,
		isnull(PE.IDTipoPension,0) as IDTipoPension,
		TP.Descripcion as TipoPension

	From RH.tblTipoTrabajadorEmpleado PE with (nolock) 
		left join IMSS.tblCatTipoTrabajador P with (nolock) 
			on PE.IDTipoTrabajador = P.IDTipoTrabajador
		left join SAT.tblCatTiposContrato TC with (nolock) 
			on TC.IDTipoContrato = PE.IDTipoContrato
		left join IMSS.tblCatTipoSalario TS with(nolock)
			on PE.IDTipoSalario = TS.IDTipoSalario
		left join IMSS.tblcatTipoPension TP with(nolock)
			on TP.IDTipoPension = PE.IDTipoPension
	Where PE.IDEmpleado = @IDEmpleado

END
GO

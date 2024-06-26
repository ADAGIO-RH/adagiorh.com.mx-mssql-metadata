USE [readOnly_adagioRHHotelesGDLPlaza]
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
		TC.Descripcion as TipoContrato
	From RH.tblTipoTrabajadorEmpleado PE with (nolock) 
		left join IMSS.tblCatTipoTrabajador P with (nolock) 
			on PE.IDTipoTrabajador = P.IDTipoTrabajador
		left join SAT.tblCatTiposContrato TC with (nolock) 
			on TC.IDTipoContrato = PE.IDTipoContrato
	Where PE.IDEmpleado = @IDEmpleado

END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Procom.spBuscarClienteEstatus(
	@IDCliente int,
	@IDUsuario int
)
AS
BEGIN
	SELECT TOP 1 CE.IDClienteEstatus
				,CE.IDCliente
				,C.NombreComercial as Cliente
				,CE.IDCatEstatusCliente
				,EC.Descripcion as EstatusCliente
	FROM Procom.tblClienteEstatus CE with(nolock)
		inner join Procom.tblCatEstatusCliente EC with(nolock)
			on CE.IDCatEstatusCliente = EC.IDCatEstatusCliente
		inner join RH.tblCatClientes C
			on C.IDCliente = CE.IDCliente
	WHERE CE.IDCliente = @IDCliente
END
GO

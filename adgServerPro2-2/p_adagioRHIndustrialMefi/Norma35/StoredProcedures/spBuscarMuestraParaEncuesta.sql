USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Norma35].[spBuscarMuestraParaEncuesta](
	@IDEmpresa int = 0,
	@IDSucursal int = 0,
	@IDCliente int = 0
)
AS
BEGIN
	DECLARE @TotalMuestra decimal(18,2) = 0,
			@MuestraFormulada decimal(18,2) = 0;

	IF(ISNULL(@IDEmpresa,0)<> 0)
	BEGIN
		SELECT @TotalMuestra = count(*) 
		FROM RH.tblEmpleadosMaster M
		WHERE M.Vigente = 1
		and IDEmpresa = @IDEmpresa

		SELECT @MuestraFormulada = ((0.9604*count(*))/((0.0025*count(*))+ 0.9604))
		FROM RH.tblEmpleadosMaster M
		WHERE M.Vigente = 1
		and IDEmpresa = @IDEmpresa
	END
	ELSE IF(ISNULL(@IDSucursal,0)<> 0)
	BEGIN
		SELECT @TotalMuestra = count(*) 
		FROM RH.tblEmpleadosMaster M
		WHERE M.Vigente = 1
		and IDSucursal = @IDSucursal

		SELECT @MuestraFormulada = ((0.9604*cast(count(*) as decimal(18,2)))/((0.0025*cast(count(*) as decimal(18,2)))+ 0.9604))
		FROM RH.tblEmpleadosMaster M
		WHERE M.Vigente = 1
		and IDSucursal = @IDSucursal
	END ELSE IF(ISNULL(@IDCliente,0)<> 0)
	BEGIN
		SELECT @TotalMuestra = count(*) 
		FROM RH.tblEmpleadosMaster M
		WHERE M.Vigente = 1
		and IDCliente = @IDCliente

		SELECT @MuestraFormulada = ((0.9604*cast(count(*) as decimal(18,2)))/((0.0025*cast(count(*) as decimal(18,2)))+ 0.9604))
		FROM RH.tblEmpleadosMaster M
		WHERE M.Vigente = 1
		and IDCliente = @IDCliente
	END

	Select CEILING(@TotalMuestra) as TotalMuestra,
		   CEILING(@MuestraFormulada) as MuestraFormulada
END
GO

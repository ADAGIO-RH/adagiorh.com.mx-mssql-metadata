USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spBorrarCatCentroCosto]
(
	@IDCentroCosto INT,
	@IDUsuario int
)
AS
BEGIN

IF EXISTS(Select Top 1 1 from Nomina.tblHistorialesEmpleadosPeriodos where IDCentroCosto = @IDCentroCosto)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END

	IF EXISTS(Select Top 1 1 from RH.tblCentroCostoEmpleado where IDCentroCosto = @IDCentroCosto)
	BEGIN
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
		return 0;
	END

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

		select @OldJSON = (SELECT IDCentroCosto
                                ,Codigo
                                ,CuentaContable
                                ,ConfiguracionEventoCalendario                                                 
                             ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('esmx', '-','')), 'Descripcion')) as Descripcion
                            FROM  [RH].[tblCatCentroCosto]
                            WHERE IDCentroCosto=@IDCentroCosto FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCentroCostoEmpleado]','[RH].[spBorrarCatCentroCosto]','DELETE','',@OldJSON



	SELECT
	IDCentroCosto
	,Codigo
	,Descripcion
	,CuentaContable
	FROM RH.tblCatCentroCosto
	WHERE IDCentroCosto = @IDCentroCosto

	DELETE RH.[tblCatCentroCosto]
	WHERE IDCentroCosto = @IDCentroCosto
END
GO

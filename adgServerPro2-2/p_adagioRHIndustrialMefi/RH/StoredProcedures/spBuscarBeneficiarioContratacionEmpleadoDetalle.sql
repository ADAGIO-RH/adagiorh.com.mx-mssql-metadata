USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [RH].[spBuscarBeneficiarioContratacionEmpleadoDetalle]
(
  @IDBeneficiarioContratacionEmpleadoDetalle int = 0
 ,@IDBeneficiarioContratacionEmpleado int = 0
 ,@IDUsuario int  
)
AS

BEGIN

	DECLARE @IDIdioma VARCHAR(20)
				;

		SELECT @IDIdioma = [App].[fnGetPreferencia]('Idioma', CASE WHEN ISNULL(@IDUsuario,0) = 0 THEN 1 ELSE @IDUsuario END, 'esmx');

		Select 
		     DE.IDBeneficiarioContratacionEmpleadoDetalle,
			 DE.IDBeneficiarioContratacionEmpleado,
			 DE.IDCatBeneficiarioContratacion,
			 BC.RFC,
			 BC.RazonSocial,
			 isnull(DE.Porcentaje,0) as Porcentaje
		From RH.tblBeneficiarioContratacionEmpleadoDetalle DE with(nolock)
			INNER JOIN RH.tblCatBeneficiariosContratacion BC with(nolock)
				on DE.IDCatBeneficiarioContratacion = BC.IDCatBeneficiarioContratacion
		Where (DE.IDBeneficiarioContratacionEmpleadoDetalle = @IDBeneficiarioContratacionEmpleadoDetalle OR isnull(@IDBeneficiarioContratacionEmpleadoDetalle,0) = 0)
		AND (DE.IDBeneficiarioContratacionEmpleado = @IDBeneficiarioContratacionEmpleado OR isnull(@IDBeneficiarioContratacionEmpleado,0) = 0)
		ORDER BY DE.Porcentaje DESC
END
GO

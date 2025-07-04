USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Elimina staff configurado en sucursal, departamento y puesto
** Autor			: Alejandro Paredes
** Email			: aparedes@adagio.com.mx
** FechaCreacion	: 2023-12-20
** Paremetros		: @CodigoSucursal			- Identificador de la sucursal.
					  @CodigoPuesto				- Identificador del puesto.
					  @PorcentajeInicial 		- Rango inicial de porcentaje
					  @PorcentajeFinal 			- Rango final de porcentaje					  
					  @IDUsuario				- Identificador del usuario.				  
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE   PROCEDURE [Staffing].[spBorrarStaffConfigurado]
(
	@CodigoSucursal		VARCHAR(100),
	@CodigoDepartamento	VARCHAR(100),
	@CodigoPuesto		VARCHAR(100),
	@PorcentajeInicial	INT = 0,
	@PorcentajeFinal	INT = 0,
	@IDUsuario			INT = 0
)
AS		

	BEGIN TRY		

		DECLARE	@IDStaff INT = 0
				,@IDMapeo INT = 0
				,@IDSucursal INT = 0
				,@IDDepartamento INT = 0
				,@IDPuesto INT = 0
				,@IDPorcentaje INT = 0
				;
	
		
		SELECT @IDSucursal = IDSucursal FROM [RH].[tblCatSucursales] WHERE Codigo = @CodigoSucursal;	
		SELECT @IDDepartamento = IDDepartamento FROM [RH].[tblCatDepartamentos] WHERE Codigo = @CodigoDepartamento;
		SELECT @IDPuesto = IDPuesto FROM [RH].[tblCatPuestos] WHERE Codigo = @CodigoPuesto;
		SELECT @IDPorcentaje = IDPorcentaje FROM [Staffing].[tblCatPorcentajes] WHERE IDSucursal = @IDSucursal AND PorcentajeInicial = @PorcentajeInicial AND PorcentajeFinal = @PorcentajeFinal;
		SELECT @IDMapeo = IDMapeo FROM [Staffing].[tblCatMapeoPuestos] WHERE IDSucursal = @IDSucursal AND IDDepartamento = @IDDepartamento AND IDPuesto = @IDPuesto;
		SELECT @IDStaff = IDStaff FROM [Staffing].[tblCatStaff] WHERE IDMapeo = @IDMapeo AND IDPorcentaje = @IDPorcentaje;


		IF EXISTS(SELECT IDStaff FROM [Staffing].[tblCatStaff] WHERE IDStaff = @IDStaff)
			BEGIN					
				BEGIN TRAN

					DELETE [Staffing].[tblCatStaff] 
					WHERE IDStaff = @IDStaff

				IF @@ROWCOUNT = 1
						COMMIT TRAN
					ELSE
						ROLLBACK TRAN

			END

	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		SELECT ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
GO

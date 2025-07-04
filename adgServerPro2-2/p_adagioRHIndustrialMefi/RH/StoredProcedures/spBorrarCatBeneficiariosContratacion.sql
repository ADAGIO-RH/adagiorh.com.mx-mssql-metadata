USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Borrar Catalogo de Beneficiarios de contratacion
** Autor			: Jose Roman
** Email			: jroman@adagio.com.mx
** FechaCreacion	: 2024-06-04
** Paremetros		:     
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE   PROCEDURE [RH].[spBorrarCatBeneficiariosContratacion]
(
	@IDCatBeneficiarioContratacion int,
	@IDUsuario int
)
AS
BEGIN


	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	--IF EXISTS(Select Top 1 1 from RH.tblBeneficiarioContratacionEmpleadoDetalle where IDCatBeneficiarioContratacion = @IDCatBeneficiarioContratacion)
	--BEGIN
	--	EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	--	return 0;
	--END

		select @OldJSON = a.JSON from [RH].[tblCatBeneficiariosContratacion] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCatBeneficiarioContratacion = @IDCatBeneficiarioContratacion

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatBeneficiariosContratacion]','[RH].[spBorrarCatBeneficiariosContratacion]','DELETE',@NewJSON,@OldJSON


		BEGIN TRY  
		    DELETE [RH].[tblCatBeneficiariosContratacion]
			WHERE IDCatBeneficiarioContratacion = @IDCatBeneficiarioContratacion
		END TRY  
		BEGIN CATCH  
		EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
			return 0;
		END CATCH ;
END
GO

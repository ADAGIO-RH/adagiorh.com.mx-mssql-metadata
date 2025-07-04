USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Create/update Catalogo de Beneficiarios de contratacion
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

CREATE   PROCEDURE RH.spIUCatBeneficiariosContratacion(
	@IDCatBeneficiarioContratacion int = 0
	,@RFC varchar(20)
	,@RazonSocial varchar(255)
	,@IDUsuario int 
)
AS
BEGIN
	SET @RFC				= UPPER(@RFC			)
	SET @RazonSocial 		= UPPER(@RazonSocial 	)

		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	IF(@IDCatBeneficiarioContratacion = 0 OR @IDCatBeneficiarioContratacion Is null)
	BEGIN

		IF EXISTS(Select Top 1 1 from RH.[tblCatBeneficiariosContratacion] where RFC = @RFC)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		INSERT INTO [RH].[tblCatBeneficiariosContratacion]
				   (
					 [RFC]
					,[RazonSocial]
				   )
			 VALUES
				   (
				      @RFC
					,@RazonSocial
				   )

		Set @IDCatBeneficiarioContratacion = @@IDENTITY

		select @NewJSON = a.JSON from [RH].[tblCatBeneficiariosContratacion] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCatBeneficiarioContratacion = @IDCatBeneficiarioContratacion

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatBeneficiariosContratacion]','[RH].[spIUCatBeneficiariosContratacion]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN
		IF EXISTS(Select Top 1 1 from RH.[tblCatBeneficiariosContratacion] where RFC = @RFC and IDCatBeneficiarioContratacion <> @IDCatBeneficiarioContratacion)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		select @OldJSON = a.JSON from [RH].[tblCatBeneficiariosContratacion] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCatBeneficiarioContratacion = @IDCatBeneficiarioContratacion

		UPDATE [RH].[tblCatBeneficiariosContratacion]
		   SET [RFC] = @RFC,
				[RazonSocial] = @RazonSocial
		 WHERE IDCatBeneficiarioContratacion = @IDCatBeneficiarioContratacion

		select @NewJSON = a.JSON from [RH].[tblCatBeneficiariosContratacion] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCatBeneficiarioContratacion = @IDCatBeneficiarioContratacion

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatBeneficiariosContratacion]','[RH].[spIUCatBeneficiariosContratacion]','UPDATE',@NewJSON,@OldJSON
	END

END
GO

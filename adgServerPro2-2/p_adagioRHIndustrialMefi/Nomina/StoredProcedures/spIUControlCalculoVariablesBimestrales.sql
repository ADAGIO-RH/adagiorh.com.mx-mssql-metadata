USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/**************************************************************************************************** 
** Descripción		: Procedimiento de creacion y actualizacion de Control de calculo de variables 
					  bimestrales.
** Autor			: Jose Roman
** Email			: jroman@adagio.com.mx
** FechaCreacion	: 2024-07-08
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/

CREATE   PROCEDURE [Nomina].[spIUControlCalculoVariablesBimestrales](
	@IDControlCalculoVariables int = 0,
	@Ejercicio int,
	@IDRegPatronal int,
	@IDBimestre int,
	@Aplicar bit = 0,
	@IDUsuario int
)
AS
BEGIN

		DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	IF(@IDControlCalculoVariables = 0 OR @IDControlCalculoVariables Is null)
	BEGIN

	  IF EXISTS(Select Top 1 1 from [Nomina].[tblControlCalculoVariablesBimestrales] where Ejercicio = @Ejercicio and IDRegPatronal = @IDRegPatronal and IDBimestre = @IDBimestre)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = 1, @CodigoError = '0302003'
			RETURN 0;
		END

		INSERT INTO [Nomina].[tblControlCalculoVariablesBimestrales]
				   (
					Ejercicio
					,IDRegPatronal
					,IDBimestre
					,Aplicar
                    ,IDUsuario
				   )
			 VALUES
				   (
				     @Ejercicio
					,@IDRegPatronal
					,@IDBimestre
					,isnull(@Aplicar,0)
                    ,@IDUsuario
				   )

		Set @IDControlCalculoVariables = @@IDENTITY
		

		

		select @NewJSON = a.JSON from [Nomina].[tblControlCalculoVariablesBimestrales] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDControlCalculoVariables = @IDControlCalculoVariables

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Nomina].[tblControlCalculoVariablesBimestrales]','[Nomina].[spIUControlCalculoVariablesBimestrales]','INSERT',@NewJSON,''


	END
	ELSE
	BEGIN
	IF EXISTS(Select Top 1 1 from  [Nomina].[tblControlCalculoVariablesBimestrales] where Ejercicio = @Ejercicio and IDRegPatronal = @IDRegPatronal and IDBimestre = @IDBimestre and IDControlCalculoVariables <> @IDControlCalculoVariables)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		select @OldJSON = a.JSON from [Nomina].[tblControlCalculoVariablesBimestrales] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDControlCalculoVariables = @IDControlCalculoVariables

		UPDATE [Nomina].[tblControlCalculoVariablesBimestrales]
		   SET  [Ejercicio] = @Ejercicio,
				[IDRegPatronal] = @IDRegPatronal,
				[IDBimestre] = @IDBimestre,
				[Aplicar] = isnull(@Aplicar,0)
		 WHERE IDControlCalculoVariables = @IDControlCalculoVariables

		select @NewJSON = a.JSON from [Nomina].[tblControlCalculoVariablesBimestrales] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDControlCalculoVariables = @IDControlCalculoVariables

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Nomina].[tblControlCalculoVariablesBimestrales]','[Nomina].[spIUControlCalculoVariablesBimestrales]','UPDATE',@NewJSON,@OldJSON
	END
END
GO

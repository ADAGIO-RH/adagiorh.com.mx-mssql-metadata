USE [p_adagioRHCorporativoCet]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RH].[spIUCatTiposPrestacionesDetalle]
(
	@IDTipoPrestacionDetalle int = 0
	,@IDTipoPrestacion int
	,@Antiguedad int
	,@DiasAguinaldo int
	,@DiasVacaciones int
	,@PrimaVacacional float
	,@PorcentajeExtra float
	,@DiasExtras int
	,@Factor float
	,@IDUsuario int
)
AS
BEGIN

DECLARE @OldJSON Varchar(Max),
	@NewJSON Varchar(Max)

	IF (@IDTipoPrestacionDetalle = 0 or @IDTipoPrestacionDetalle is null)
	BEGIN

		INSERT INTO [RH].[tblCatTiposPrestacionesDetalle]
				   (
					IDTipoPrestacion
					,Antiguedad
					,DiasAguinaldo
					,DiasVacaciones
					,PrimaVacacional
					,PorcentajeExtra
					,DiasExtras
					--,Factor
				
				   )
			 VALUES
				   (
				    @IDTipoPrestacion
					,@Antiguedad
					,@DiasAguinaldo
					,@DiasVacaciones
					,@PrimaVacacional
					,@PorcentajeExtra
					,@DiasExtras
				--	,@Factor
				
				   )
			SET @IDTipoPrestacionDetalle = @@IDENTITY

		select @NewJSON = a.JSON from [RH].[tblCatTiposPrestacionesDetalle] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoPrestacionDetalle = @IDTipoPrestacionDetalle

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTiposPrestacionesDetalle]','[RH].[spIUCatTiposPrestacionesDetalle]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN

	
		select @OldJSON = a.JSON from [RH].[tblCatTiposPrestacionesDetalle] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoPrestacionDetalle = @IDTipoPrestacionDetalle

		UPDATE [RH].[tblCatTiposPrestacionesDetalle]
		   SET  Antiguedad = @Antiguedad
				,DiasAguinaldo = @DiasAguinaldo
				,DiasVacaciones = @DiasVacaciones
				,PrimaVacacional = @PrimaVacacional
				,PorcentajeExtra = @PorcentajeExtra
				,DiasExtras = @DiasExtras
				--,Factor = @Factor
		 WHERE [IDTipoPrestacion] = @IDTipoPrestacion
			and [IDTipoPrestacionDetalle] = @IDTipoPrestacionDetalle

		select @NewJSON = a.JSON from [RH].[tblCatTiposPrestacionesDetalle] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoPrestacionDetalle = @IDTipoPrestacionDetalle

	    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[RH].[tblCatTiposPrestacionesDetalle]','[RH].[spIUCatTiposPrestacionesDetalle]','UPDATE',@NewJSON,@OldJSON

	END
END
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [IMSS].[spIUCatCesantiaVejezPatronalDetalle]
(
	@IDCesantiaVejezPatronalDetalle int = 0
	,@IDCesantiaVejezPatronal int
	,@Desde decimal(18,2)
	,@Hasta decimal(18,2)
	--,@MinimoGeneral decimal(18,2)
	--,@MaximoGeneral decimal(18,2)
	--,@MinimoFronterizo decimal(18,2)
	--,@MaximoFronterizo decimal(18,2)
	,@CuotaPatronal decimal(18,6)
	,@IDUsuario int
)
AS
BEGIN

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
    

	IF(@IDCesantiaVejezPatronalDetalle = 0 or @IDCesantiaVejezPatronalDetalle is null)
	BEGIN
		INSERT INTO IMSS.tblCatCesantiaVejezPatronalDetalle(
			IDCesantiaVejezPatronal
			,Desde
			,Hasta
			--,MinimoGeneral
			--,MaximoGeneral
			--,MinimoFronterizo
			--,MaximoFronterizo
			,CuotaPatronal
		)
		VALUES (
			 @IDCesantiaVejezPatronal
			 ,@Desde
			 ,@Hasta
			--,@MinimoGeneral
			--,@MaximoGeneral
			--,@MinimoFronterizo
			--,@MaximoFronterizo
			,@CuotaPatronal
		)
			
		set @IDCesantiaVejezPatronalDetalle = @@IDENTITY

		select @NewJSON = a.JSON from [IMSS].[tblCatCesantiaVejezPatronalDetalle] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCesantiaVejezPatronalDetalle = @IDCesantiaVejezPatronalDetalle

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblCatCesantiaVejezPatronalDetalle]','[IMSS].[spIUCatCesantiaVejezPatronalDetalle]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN
		
		select @OldJSON = a.JSON from [IMSS].[tblCatCesantiaVejezPatronalDetalle] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCesantiaVejezPatronalDetalle = @IDCesantiaVejezPatronalDetalle

		UPDATE [IMSS].[tblCatCesantiaVejezPatronalDetalle]
		set 
			Desde = @Desde
			,Hasta = @Hasta
			-- MinimoGeneral		= @MinimoGeneral
			--,MaximoGeneral		= @MaximoGeneral
			--,MinimoFronterizo	= @MinimoFronterizo
			--,MaximoFronterizo	= @MaximoFronterizo
			,CuotaPatronal		= @CuotaPatronal
		Where IDCesantiaVejezPatronalDetalle = @IDCesantiaVejezPatronalDetalle

		select @NewJSON = a.JSON from [IMSS].[tblCatCesantiaVejezPatronalDetalle] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCesantiaVejezPatronalDetalle = @IDCesantiaVejezPatronalDetalle

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblCatCesantiaVejezPatronalDetalle]','[IMSS].[spIUCatCesantiaVejezPatronalDetalle]','UPDATE',@NewJSON,@OldJSON
	END

END
GO

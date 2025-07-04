USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [IMSS].[spIUCatCesantiaVejezPatronal]
(
	@IDCesantiaVejezPatronal int = 0,
	@FechaInicial DATE,
	@FechaFinal DATE,
	@IDUsuario int
)
AS
BEGIN
    

	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)
    

	IF(@IDCesantiaVejezPatronal = 0 or @IDCesantiaVejezPatronal is null)
	BEGIN
		INSERT INTO IMSS.tblCatCesantiaVejezPatronal
			(
			[FechaInicial]
			,[FechaFinal]
			)
		VALUES(
			@FechaInicial ,
			@FechaFinal 
			)
			
			set @IDCesantiaVejezPatronal = @@IDENTITY

		select @NewJSON = a.JSON from [IMSS].[tblCatCesantiaVejezPatronal] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCesantiaVejezPatronal = @IDCesantiaVejezPatronal

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblCatCesantiaVejezPatronal]','[IMSS].[spIUCatCesantiaVejezPatronal]','INSERT',@NewJSON,''

	END
	ELSE
	BEGIN
		
		select @OldJSON = a.JSON from [IMSS].[tblCatCesantiaVejezPatronal] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCesantiaVejezPatronal = @IDCesantiaVejezPatronal

		UPDATE [IMSS].[tblCatCesantiaVejezPatronal]
		set [FechaInicial] = @FechaInicial
			,[FechaFinal] = @FechaFinal
		Where IDCesantiaVejezPatronal = @IDCesantiaVejezPatronal

			select @NewJSON = a.JSON from [IMSS].[tblCatCesantiaVejezPatronal] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDCesantiaVejezPatronal = @IDCesantiaVejezPatronal

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[IMSS].[tblCatCesantiaVejezPatronal]','[IMSS].[spIUCatCesantiaVejezPatronal]','UPDATE',@NewJSON,@OldJSON
	END

END
GO

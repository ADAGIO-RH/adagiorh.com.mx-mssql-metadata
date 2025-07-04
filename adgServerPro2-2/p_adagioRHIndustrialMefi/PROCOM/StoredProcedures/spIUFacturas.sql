USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [PROCOM].[spIUFacturas](
	@IDFactura int = 0,
	@Fecha Date ,
	@Folio int ,
	@RFC Varchar(20) ,
	@RazonSocial Varchar(100) null,
	@Total Decimal(18,2),
	@Consolidado bit,
	@IDUsuario int
)
AS
BEGIN
	SET @Folio				= UPPER(@Folio			)
	SET @RazonSocial 		= UPPER(@RazonSocial 	)
	
	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max)

	IF EXISTS(Select Top 1 1 from Procom.TblFacturas where Folio = @Folio and Fecha = @Fecha and RFC = @RFC)
	BEGIN
		Select Top 1 @IDFactura = IDFactura from Procom.TblFacturas where Folio = @Folio and Fecha = @Fecha and RFC = @RFC	
	END

	IF(@IDFactura = 0 OR @IDFactura Is null)
	BEGIN

		INSERT INTO [Procom].[TblFacturas]
				   (
					Fecha
					,Folio 
					,RFC 
					,RazonSocial
					,Total 
					,Consolidado
				   )
			 VALUES
				   (
				     @Fecha
					,@Folio 
					,@RFC 
					,@RazonSocial
					,@Total 
					,@Consolidado
				   )

		Set @IDFactura = @@IDENTITY
		

		select @NewJSON = a.JSON from [Procom].[TblFacturas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDFactura = @IDFactura

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[TblFacturas]','[Procom].[spIUFacturas]','INSERT',@NewJSON,''


	END
	ELSE
	BEGIN
	
		select @OldJSON = a.JSON from [Procom].[TblFacturas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDFactura = @IDFactura

		UPDATE [Procom].[tblFacturas]
		   SET [Total] = @Total,
				[RazonSocial] = @RazonSocial,
				[Consolidado] = @Consolidado
		 WHERE IDFactura = @IDFactura


		select @NewJSON =  a.JSON from [Procom].[TblFacturas] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDFactura = @IDFactura

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Procom].[TblFacturas]','[Procom].[spIUFacturas]','UPDATE',@NewJSON,@OldJSON
	END

END
GO

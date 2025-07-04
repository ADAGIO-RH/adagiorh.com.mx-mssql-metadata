USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [ELE].[spUICatTipoServicio]
(
	@IDTipoServicio int = 0
	,@Descripcion nvarchar(255) = 0	
	,@IDUsuario int	

)
AS
BEGIN
		
	
  DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);
	


	IF(@IDTipoServicio = 0 OR @IDTipoServicio Is null)
	BEGIN

			
		IF EXISTS(Select Top 1 1 from ELE.tblCatTiposServicios where Descripcion = @Descripcion)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END

		INSERT INTO [ELE].[tblCatTiposServicios]
				   ([Descripcion]
				   )
			 VALUES
				   (
				   @Descripcion
            )
		  set @IDTipoServicio = @@IDENTITY

		select @NewJSON = a.JSON from [ELE].[tblCatTiposServicios] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoServicio=@IDTipoServicio;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[ELE].[tblCatTiposServicios]','[ELE].[spUICatTipoServicio]','INSERT',@NewJSON,''

		
	END
	ELSE
	BEGIN
		IF EXISTS(Select Top 1 1 from ELE.tblCatTiposServicios where Descripcion = @Descripcion and IDTipoServicio <> @IDTipoServicio)
		BEGIN
			EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302003'
			RETURN 0;
		END
			   	select @OldJSON = a.JSON from [ELE].[tblCatTiposServicios] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoServicio=@IDTipoServicio;

		UPDATE [ELE].[tblCatTiposServicios]
		   SET 
			  [Descripcion] = @Descripcion			  
		 WHERE IDTipoServicio = @IDTipoServicio
		
		select @NewJSON = a.JSON from [ELE].[tblCatTiposServicios] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTipoServicio=@IDTipoServicio;

		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[ELE].[tblCatTiposServicios]','[ELE].[spIUCatTipoServicio]','UPDATE',@NewJSON,@OldJSON
	END
	 
    exec [ELE].[spBuscarCatTipoServicio] @IDTipoServicio=@IDTipoServicio,@IDUsuario = @IDUsuario
END
GO

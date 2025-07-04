USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROC [App].[spIUTemplateNotificaciones](
	@IDTemplateNotificacion int = 0,
	@IDTipoNotificacion varchar(50),
	@IDMedioNotificacion varchar(50),
	@Template varchar(max) = '',
	@IDIdioma varchar(10) = NULL,
	@IDUsuario int
	)
AS
BEGIN
	DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);
	SET @IDIdioma = isnull(@IDIdioma,'es-MX')

	BEGIN TRY
	
	IF(@IDTemplateNotificacion = 0 OR @IDTemplateNotificacion IS NULL)
		BEGIN
			IF EXISTS(
				Select Top 1 1 
				from App.tblTemplateNotificaciones 
				where IDTipoNotificacion = @IDTipoNotificacion 
					and IDMedioNotificacion = @IDMedioNotificacion 
					and IDIdioma = @IDIdioma)
			BEGIN
				DECLARE @ErrorMessage NVARCHAR(500)
				SET @ErrorMessage = 'El registro insertado ya existe'
				RAISERROR (@ErrorMessage, 16, 1)
				RETURN 0;
			END

			BEGIN TRAN
				--------CODE
				
				INSERT INTO [App].[tblTemplateNotificaciones]([IDTipoNotificacion],[IDMedioNotificacion], Template,[IDIdioma])
				VALUES(@IDTipoNotificacion,@IDMedioNotificacion,@Template,@IDIdioma)

				SET @IDTemplateNotificacion = @@IDENTITY

				select @NewJSON = a.JSON from [App].[tblTemplateNotificaciones] b
				Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
				WHERE b.IDTemplateNotificacion=@IDTemplateNotificacion;

				EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[App].[tblTemplateNotificaciones]','[App].[spIUTemplateNotificaciones]','INSERT',@NewJSON,''

				exec [App].[spBuscarTemplateNotificaciones] @IDTemplateNotificacion=@IDTemplateNotificacion

			IF @@ROWCOUNT = 1
					begin
						COMMIT TRAN
					end
			ELSE
				begin
					ROLLBACK TRAN
				end
		END

	ELSE BEGIN
		
		IF EXISTS(
			Select Top 1 1 
			from App.tblTemplateNotificaciones 
			where IDTipoNotificacion = @IDTipoNotificacion 
				and IDMedioNotificacion = @IDMedioNotificacion 
				and IDIdioma = @IDIdioma
				AND IDTemplateNotificacion <> @IDTemplateNotificacion 
		)
		BEGIN
			DECLARE @ErrorMessage2 NVARCHAR(500)
			SET @ErrorMessage2 = 'Error al buscar el registro, intenta de nuevo'
			RAISERROR (@ErrorMessage2, 16, 1)
			RETURN 0;
		END

		BEGIN TRAN
		-------CODE
		select @OldJSON = a.JSON from [App].[tblTemplateNotificaciones] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE  b.IDTemplateNotificacion=@IDTemplateNotificacion;

		UPDATE [App].[tblTemplateNotificaciones]
			SET IDTipoNotificacion = @IDTipoNotificacion
				,IDMedioNotificacion = @IDMedioNotificacion
				,Template = @Template
				,IDIdioma = @IDIdioma
		WHERE IDTemplateNotificacion = @IDTemplateNotificacion

		select @NewJSON = a.JSON from [App].[tblTemplateNotificaciones] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDTemplateNotificacion=@IDTemplateNotificacion;

		IF @@ROWCOUNT = 1
				begin
					COMMIT TRAN
				end
		ELSE
			begin
				ROLLBACK TRAN
			end

			EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[App].[tblTemplateNotificaciones]','[App].[spIUTemplateNotificaciones]','UPDATE',@NewJSON,@OldJSON

			exec [App].[spBuscarTemplateNotificaciones] @IDTemplateNotificacion=@IDTemplateNotificacion

	END
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage1 NVARCHAR(500)
		SET @ErrorMessage1 = 'SP error - '--+ERROR_MESSAGE()
		RAISERROR (@ErrorMessage1, 16, 1)
	END CATCH
END

/*
exec [App].[spIUTemplateNotificaciones]
	@IDTemplateNotificacion = 65,
	@IDTipoNotificacion = 'AprobacionDocumentos',
	@IDMedioNotificacion = 'Celular',
	@Template = 'd-4e88b279aa2e4d6d82b171921f6ec289',
	@IDIdioma = 'en-US'


	select * from app.tblTemplateNotificaciones
*/
GO

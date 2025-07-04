USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create   proc [App].[spBorrarTemplateNotificaciones](
						@IDTemplateNotificacion int
						,@IDUsuario int
						)
as
begin
	begin try
		--code
		DECLARE @OldJSON Varchar(Max)

		if not exists(select top 1 1 from App.tblTemplateNotificaciones where IDTemplateNotificacion = @IDTemplateNotificacion)
		begin
			DECLARE @ErrorMessage2 NVARCHAR(500)
			SET @ErrorMessage2 = 'Este template no existe, intenta con otro registro diferente'
			RAISERROR (@ErrorMessage2, 16, 1)
			RETURN 0;
		end

		else
		begin
			--code
				select @OldJSON = a.JSON from [App].[tblTemplateNotificaciones] b
				Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
				WHERE b.IDTemplateNotificacion = @IDTemplateNotificacion

			begin tran
				--code
				EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[App].[tblTemplateNotificaciones]','[App].[spBorrarTemplateNotificaciones]','DELETE','',@OldJSON

				SELECT
					--IDTemplateNotificacion
					IDTipoNotificacion
					,IDMedioNotificacion
					,Template
					,IDIdioma
					FROM App.tblTemplateNotificaciones
					WHERE IDTemplateNotificacion = @IDTemplateNotificacion;

			delete from [App].[tblTemplateNotificaciones]
					where IDTemplateNotificacion = @IDTemplateNotificacion

			IF @@ROWCOUNT = 1
				COMMIT TRAN
			ELSE
				ROLLBACK TRAN
		end
	end try
	begin catch
		--code
		DECLARE @ErrorMessage1 NVARCHAR(500)
		SET @ErrorMessage1 = 'SP error, not possible to delete row - '+ ERROR_MESSAGE()
		RAISERROR (@ErrorMessage1, 16, 1)
	end catch
end


/*
exec [App].[spBorrarTemplateNotificaciones]
						@IDTemplateNotificacion = 65


*/
GO

USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [App].[spIUComentario](
	 @IDComentario		int		
	,@IDTipoComentario	int		
	,@IDReferencia		int		
	,@Comentario				nvarchar(max)
	,@IDUsuario				int		
) as

	set @Comentario = replace(@Comentario,'"','''')

	if (@IDComentario = 0)
	begin
		insert [App].[tblComentarios](IDTipoComentario,IDReferencia,Comentario,IDUsuario)
		values(@IDTipoComentario,@IDReferencia,@Comentario,@IDUsuario)
		set @IDComentario = @@IDENTITY

		IF(@IDTipoComentario = 1) -- INTRANET COMENTARIOS
		BEGIN
			EXEC [App].[INotificacionSolicitudIntranetComentario] 
				@IDSolicitud = @IDReferencia
				,@IDComentario = @IDComentario
				,@TipoCambio = 'CREATE-SUPERVISOR'
			EXEC [App].[INotificacionSolicitudIntranetComentario] 
				@IDSolicitud = @IDReferencia
				,@IDComentario = @IDComentario
				,@TipoCambio = 'CREATE-USUARIO'
		END

	end else
	begin
		update [App].[tblComentarios]
			set Comentario = @Comentario
		where IDComentario = @IDComentario

		IF(@IDTipoComentario = 1) -- INTRANET COMENTARIOS
		BEGIN
			EXEC [App].[INotificacionSolicitudIntranetComentario] 
				@IDSolicitud = @IDReferencia
				,@IDComentario = @IDComentario
				,@TipoCambio = 'UPDATE-SUPERVISOR'
			EXEC [App].[INotificacionSolicitudIntranetComentario] 
				@IDSolicitud = @IDReferencia
				,@IDComentario = @IDComentario
				,@TipoCambio = 'UPDATE-USUARIO'
		END
	end;
GO

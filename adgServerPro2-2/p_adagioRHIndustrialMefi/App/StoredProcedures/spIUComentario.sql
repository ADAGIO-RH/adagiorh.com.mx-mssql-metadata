USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: CREAR LOS COMENTARIOS EN LOS DIFERENTES MÓDULOS
** Autor			: ?
** Email			: 
** FechaCreacion	: 
** Paremetros		:              
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
2024-03-14          Jose Vargas          Se añade una ejecucción del sp '[Tareas].[spActualizarTotalComentarios]' para actualizar los totales de comentarios
                                        En la tabla de tareas.tblTareas
***************************************************************************************************/
CREATE proc [App].[spIUComentario](
	 @IDComentario		int		
	,@IDTipoComentario	int		
	,@IDReferencia		int		
	,@Comentario				nvarchar(max)
	,@IDUsuario				int		
) as


    DECLARE  @totalComentarios int 
    DECLARE @TIPO_COMENTARIOS_TAREAS int 
    set  @TIPO_COMENTARIOS_TAREAS=7

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
        ELSE IF( @IDTipoComentario=@TIPO_COMENTARIOS_TAREAS) -- TAREAS 
        BEGIN
            
            select @totalComentarios = count(*) from app.tblComentarios where IDTipoComentario=@TIPO_COMENTARIOS_TAREAS and IDReferencia=@IDReferencia
            EXEC [Tareas].[spActualizarTotalComentarios]
                @IDTarea =@IDReferencia ,     
                @TotalComentarios =@totalComentarios, 
                @IDUsuario =@IDUsuario
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
        ELSE IF( @IDTipoComentario=@TIPO_COMENTARIOS_TAREAS) -- TAREAS 
        BEGIN
            
            select @totalComentarios = count(*) from app.tblComentarios where IDTipoComentario=@TIPO_COMENTARIOS_TAREAS and IDReferencia=@IDReferencia
            EXEC [Tareas].[spActualizarTotalComentarios]
                @IDTarea =@IDReferencia ,     
                @TotalComentarios =@totalComentarios, 
                @IDUsuario =@IDUsuario
        END    
	end;
GO

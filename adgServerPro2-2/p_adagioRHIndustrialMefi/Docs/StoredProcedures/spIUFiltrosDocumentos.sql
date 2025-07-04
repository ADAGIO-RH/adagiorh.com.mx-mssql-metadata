USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Procedimiento para insertar filtros de Documentos a los usuarios  
** Autor   : Jose Roman  
** Email   : jose.roman@adagio.com.mx   
** FechaCreacion : 2019-05-10  
** Paremetros  :                
  
** DataTypes Relacionados:   
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
2019-05-10  Jose Roman   @ValidaExistencia int = 1  Este parametro siempre va a validar   
            la existencia de filtros en la tabla de filtros para dicho usuario  
         en el caso de no validar existencia inserta el filtro obligatoriamente.  
  
***************************************************************************************************/  
CREATE proc [Docs].[spIUFiltrosDocumentos](    
	@IDFiltrosDocumentos int    
	,@IDDocumento int     
	,@Filtro varchar(255)     
	,@ID varchar(255)     
	,@Descripcion varchar(255)    
	,@IDUsuarioLogin int  
	,@ValidaExistencia bit = 1    
	,@IDCatFiltroDocumento int = 0
) as    
 --IF(@IDUsuario = @IDUsuarioLogin)  
 --BEGIN  
 --Exec app.spObtenerError @IDUsuario = @IDUsuarioLogin,@CodigoError = '0102001',@CustomMessage = ''  
 --Return;  
 --END  
    
	if (@IDFiltrosDocumentos = 0)     
	begin    
		IF(@Filtro <> 'Eliminar Usuario')  
		BEGIN  
			IF(@ValidaExistencia = 1 and Exists(Select top 1 1 from [Docs].[tblFiltrosDocumentos] where IDDocumento = @IDDocumento and Filtro = @Filtro))  
			BEGIN  
				insert into [Docs].[tblFiltrosDocumentos](IDDocumento,Filtro,ID,Descripcion,IDCatFiltroDocumento)    
				select @IDDocumento,@Filtro,@ID,@Descripcion,@IDCatFiltroDocumento  
				set @IDFiltrosDocumentos = @@IDENTITY    
			END ELSE IF(@ValidaExistencia = 0)  
			BEGIN  
				insert into [Docs].[tblFiltrosDocumentos](IDDocumento,Filtro,ID,Descripcion,IDCatFiltroDocumento)    
				select @IDDocumento,@Filtro,@ID,@Descripcion,@IDCatFiltroDocumento   
				set @IDFiltrosDocumentos = @@IDENTITY    
			END  
		END  
		IF(@Filtro = 'Excluir Usuario' OR @Filtro = 'Eliminar Usuario')  
		BEGIN  
			DELETE [Docs].[tblFiltrosDocumentos]  
			WHERE IDDocumento = @IDDocumento 
				AND Filtro = 'Usuario'  
				AND ID = @ID  

			DELETE [Docs].[tblDetalleFiltrosDocumentosUsuarios]  
			WHERE IDDocumento = @IDDocumento  
				AND IDUsuario = @ID  
		END  
	END 
	ELSE    
	BEGIN    
		UPDATE [Docs].[tblFiltrosDocumentos]    
		SET Filtro = @Filtro    
			,ID = @ID    
			,Descripcion = @Descripcion    
		WHERE IDFiltrosDocumentos = @IDFiltrosDocumentos   
	END;     
    
	-- Hay que hacer las asignaciones automaticas

	exec [Docs].[spAsignarEmpleadosADocumentosPorFiltro] @IDDocumento = @IDDocumento    
	exec [Docs].[spBuscarFiltrosDocumentos] @IDFiltrosDocumentos = @IDFiltrosDocumentos
GO

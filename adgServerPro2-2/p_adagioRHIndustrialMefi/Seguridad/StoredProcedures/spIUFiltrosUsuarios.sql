USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Procedimiento para insertar filtros de empleados a los usuarios  
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
CREATE proc [Seguridad].[spIUFiltrosUsuarios](    
	@IDFiltrosUsuarios int    
	,@IDUsuario int     
	,@Filtro varchar(255)     
	,@ID varchar(255)     
	,@Descripcion varchar(255)    
	,@IDUsuarioLogin int  
	,@ValidaExistencia bit = 1    
	,@IDCatFiltroUsuario int = 0
) as    
 --IF(@IDUsuario = @IDUsuarioLogin)  
 --BEGIN  
 --Exec app.spObtenerError @IDUsuario = @IDUsuarioLogin,@CodigoError = '0102001',@CustomMessage = ''  
 --Return;  
 --END  
    DECLARE @OldJSON Varchar(Max),
		@NewJSON Varchar(Max);
    
	if (@IDFiltrosUsuarios = 0)     
	begin    
		IF(@Filtro <> 'Eliminar Empleado')  
		BEGIN  
			IF(@ValidaExistencia = 1 and Exists(Select top 1 1 from [Seguridad].[tblFiltrosUsuarios] where IDUsuario = @IDUsuario and Filtro = @Filtro))  
			BEGIN  
				insert into [Seguridad].[tblFiltrosUsuarios](IDUsuario,Filtro,ID,Descripcion,IDCatFiltroUsuario)    
				select @IDUsuario,@Filtro,@ID,@Descripcion,@IDCatFiltroUsuario    
				set @IDFiltrosUsuarios = @@IDENTITY    
			END ELSE IF(@ValidaExistencia = 0)  
			BEGIN  
				insert into [Seguridad].[tblFiltrosUsuarios](IDUsuario,Filtro,ID,Descripcion,IDCatFiltroUsuario)    
				select @IDUsuario,@Filtro,@ID,@Descripcion,@IDCatFiltroUsuario   
				set @IDFiltrosUsuarios = @@IDENTITY    
			END  

              Select @NewJSON = (SELECT * FROM Seguridad.tblFiltrosUsuarios WHERE IDFiltrosUsuarios = @IDFiltrosUsuarios FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

        	EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogin,'[Seguridad].[tblFiltrosUsuarios]','[Seguridad].[spIUFiltrosUsuarios]','INSERT',@NewJSON,''
		END  
		IF(@Filtro = 'Excluir Empleado' OR @Filtro = 'Eliminar Empleado')  
		BEGIN  
			DELETE [Seguridad].[tblFiltrosUsuarios]  
			WHERE IDUsuario = @IDUsuario  
				AND Filtro = 'Empleados'  
				AND ID = @ID  

			DELETE [Seguridad].[tblDetalleFiltrosEmpleadosUsuarios]  
			WHERE IDUsuario = @IDUsuario  
				AND IDEmpleado = @ID  
		END  
	END 
	ELSE    
	BEGIN   
       Select @OldJSON = (SELECT * FROM Seguridad.tblFiltrosUsuarios WHERE IDFiltrosUsuarios = @IDFiltrosUsuarios FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

        	
		UPDATE [Seguridad].[tblFiltrosUsuarios]    
		SET Filtro = @Filtro    
			,ID = @ID    
			,Descripcion = @Descripcion    
		WHERE IDFiltrosUsuarios = @IDFiltrosUsuarios    

         Select @NewJSON = (SELECT * FROM Seguridad.tblFiltrosUsuarios WHERE IDFiltrosUsuarios = @IDFiltrosUsuarios FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

        EXEC [Auditoria].[spIAuditoria] @IDUsuarioLogin,'[Seguridad].[tblFiltrosUsuarios]','[Seguridad].[spIUFiltrosUsuarios]','UPDATE',@NewJSON,@OldJSON
	END;     
    
	exec [Seguridad].[spAsginarEmpleadosAUsuarioPorFiltro] @IDUsuario = @IDUsuario, @IDUsuarioLogin = @IDUsuarioLogin    
	exec [Seguridad].[spBuscarFiltrosUsuarios] @IDFiltrosUsuarios = @IDFiltrosUsuarios
GO

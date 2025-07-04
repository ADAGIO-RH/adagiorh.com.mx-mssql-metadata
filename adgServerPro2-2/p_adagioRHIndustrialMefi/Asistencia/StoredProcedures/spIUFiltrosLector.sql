USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************   
** Descripción  : Procedimiento para insertar filtros de empleados a los Lectores  
** Autor   : Jose Roman  
** Email   : jose.roman@adagio.com.mx   
** FechaCreacion : 2023-10-12  
** Paremetros  :                
  
** DataTypes Relacionados:   
****************************************************************************************************  
HISTORIAL DE CAMBIOS  
Fecha(yyyy-mm-dd) Autor   Comentario  
------------------- ------------------- ------------------------------------------------------------  
0000-00-00  NombreCompleto  ¿Qué cambió?  
2023-10-12    Jose Roman   @ValidaExistencia int = 1  Este parametro siempre va a validar   
							la existencia de filtros en la tabla de filtros para dicho usuario  
							en el caso de no validar existencia inserta el filtro obligatoriamente.  
  
***************************************************************************************************/  
CREATE proc [Asistencia].[spIUFiltrosLector](    
	@IDFiltroLector int    
	,@IDLector int     
	,@Filtro varchar(255)     
	,@ID varchar(255)     
	,@Descripcion varchar(255)    
	,@IDUsuarioLogin int  
	,@ValidaExistencia bit = 1    
	,@IDGrupoFiltrosLector int = 0
) as    
 --IF(@IDUsuario = @IDUsuarioLogin)  
 --BEGIN  
 --Exec app.spObtenerError @IDUsuario = @IDUsuarioLogin,@CodigoError = '0102001',@CustomMessage = ''  
 --Return;  
 --END  
    
	if (@IDFiltroLector = 0)     
	begin    
		IF(@Filtro <> 'Eliminar Empleado')  
		BEGIN  
			IF(@ValidaExistencia = 1 and Exists(Select top 1 1 from [Asistencia].[tblFiltrosLector] where IDLector = @IDLector and Filtro = @Filtro))  
			BEGIN  
				insert into [Asistencia].[tblFiltrosLector](IDLector,Filtro,ID,Descripcion,IDGrupoFiltrosLector)    
				select @IDLector,@Filtro,@ID,@Descripcion,@IDGrupoFiltrosLector    
				set @IDFiltroLector = @@IDENTITY    
			END ELSE IF(@ValidaExistencia = 0)  
			BEGIN  
				insert into [Asistencia].[tblFiltrosLector](IDLector,Filtro,ID,Descripcion,IDGrupoFiltrosLector)   
				select @IDLector,@Filtro,@ID,@Descripcion,@IDGrupoFiltrosLector   
				set @IDFiltroLector = @@IDENTITY    
			END  
		END  
		IF(@Filtro = 'Excluir Empleado' OR @Filtro = 'Eliminar Empleado')  
		BEGIN  
			DELETE [Asistencia].[tblFiltrosLector]  
			WHERE IDLector = @IDLector  
				AND Filtro = 'Empleados'  
				AND ID = @ID  

			--DELETE [Seguridad].[tblDetalleFiltrosEmpleadosUsuarios]  
			--WHERE IDUsuario = @IDUsuario  
			--	AND IDEmpleado = @ID  
		END  
	END 
	ELSE    
	BEGIN    
		UPDATE [Asistencia].[tblFiltrosLector]    
		SET Filtro = @Filtro    
			,ID = @ID    
			,Descripcion = @Descripcion    
		WHERE IDFiltroLector = @IDFiltroLector  
	END;     
    
	exec [Asistencia].[spAsignarEmpleadosALectoresPorFiltro] @IDLector = @IDLector, @IDUsuarioLogin = @IDUsuarioLogin 
	exec [Asistencia].[spBuscarFiltrosLector] @IDFiltroLector = @IDFiltroLector
GO

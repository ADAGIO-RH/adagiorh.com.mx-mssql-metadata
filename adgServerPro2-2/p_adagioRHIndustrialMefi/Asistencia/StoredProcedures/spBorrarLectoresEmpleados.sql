USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Asistencia].[spBorrarLectoresEmpleados] --166,25,1
(
	@IDEmpleado int,
	@IDLector int,
	@IDUsuario int
)
AS
BEGIN

   DECLARE @OldJSON Varchar(Max),
			@NewJSON Varchar(Max),
			@IDGrupoFiltrosLector int = 0,
			@NombreEmpleado Varchar(255),
			@DevSN VArchar(50),
		    @Configuracion Varchar(max)
	;

	select @DevSN = NumeroSerial, @Configuracion = Configuracion from Asistencia.tblLectores with(nolock) where IDLector = @IDLector

	IF EXISTS(Select top 1 1 from Asistencia.tblLectoresEmpleados with(nolock) where IDLector = @IDLector and IDEmpleado = @IDEmpleado)
	BEGIN

		select @OldJSON = a.JSON from [Asistencia].[tblLectoresEmpleados] b
		Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
		WHERE b.IDLector = @IDLector and IDEmpleado = @IDEmpleado

		SELECT TOP 1 @IDGrupoFiltrosLector = isnull(IDGrupoFiltrosLector,0) 
			,@NombreEmpleado = m.ClaveEmpleado +' - '+ m.NOMBRECOMPLETO
		FROM [Asistencia].[tbllectoresEmpleados]  LE with(nolock)
			inner join RH.tblEmpleadosMaster m with(nolock)
				on M.IDEmpleado = LE.IDEmpleado
		WHERE LE.IDLector = @IDLector and LE.IDEmpleado = @IDEmpleado

		select @IDGrupoFiltrosLector

		IF(isnull(@IDGrupoFiltrosLector,0) > 0)
		BEGIN
			EXEC [Asistencia].[spIUFiltrosLector]    
				@IDFiltroLector  = 0   
				,@IDLector = @IDLector     
				,@Filtro = 'Excluir Empleado'     
				,@ID = @IDEmpleado   
				,@Descripcion = @NombreEmpleado   
				,@IDUsuarioLogin = @IDUsuario  
				,@ValidaExistencia = 0    
				,@IDGrupoFiltrosLector  = @IDGrupoFiltrosLector

		END
		--ELSE
		--BEGIN
		--	IF NOT EXISTS (Select top 1 1 FROM Asistencia.tblGrupoFiltrosLector with(nolock) where IDLector = @IDLector)
		--	BEGIN
		--		EXEC [Asistencia].[spIUGrupoFiltrosLector]
		--			 @IDLector = @IDLector			
		--			,@Nombre = 'EXCLUSIÓN GENERAL'	
		--			,@IDUsuarioCreo = @IDUsuario	
				
		--		Select top 1 @IDGrupoFiltrosLector = IDGrupoFiltrosLector 
		--		FROM Asistencia.tblGrupoFiltrosLector with(nolock) 
		--		where IDLector = @IDLector

		--		select @NombreEmpleado = ClaveEmpleado +' - '+ NOMBRECOMPLETO 
		--		from RH.tblEmpleadosMaster with(nolock) 
		--		where IDEmpleado = @IDEmpleado

		--		EXEC [Asistencia].[spIUFiltrosLector]    
		--		@IDFiltroLector  = 0   
		--		,@IDLector = @IDLector     
		--		,@Filtro = 'Excluir Empleado'     
		--		,@ID = @IDEmpleado   
		--		,@Descripcion = @NombreEmpleado   
		--		,@IDUsuarioLogin = @IDUsuario  
		--		,@ValidaExistencia = 0    
		--		,@IDGrupoFiltrosLector  = @IDGrupoFiltrosLector

		--	END
		--	ELSE
		--	BEGIN
		--		Select top 1 @IDGrupoFiltrosLector = IDGrupoFiltrosLector 
		--		FROM Asistencia.tblGrupoFiltrosLector with(nolock) 
		--		where IDLector = @IDLector

		--		select @NombreEmpleado = ClaveEmpleado +' - '+ NOMBRECOMPLETO 
		--		from RH.tblEmpleadosMaster with(nolock) 
		--		where IDEmpleado = @IDEmpleado

		--		EXEC [Asistencia].[spIUFiltrosLector]    
		--		@IDFiltroLector  = 0   
		--		,@IDLector = @IDLector     
		--		,@Filtro = 'Excluir Empleado'     
		--		,@ID = @IDEmpleado   
		--		,@Descripcion = @NombreEmpleado   
		--		,@IDUsuarioLogin = @IDUsuario  
		--		,@ValidaExistencia = 0    
		--		,@IDGrupoFiltrosLector  = @IDGrupoFiltrosLector
				
				
		--	END
		--END
		
		IF(isjson(@Configuracion) > 0 and (json_value(@Configuracion, '$.connectivity') = 'ADMS'))
		BEGIN
			EXEC [zkteco].[spCoreCommand_DeleteUser] @DevSN = @DevSN, @IDEmpleado = @IDEmpleado, @IDUsuario = @IDUsuario
			EXEC [zkteco].[spCoreBorrarUserInfo] @DevSN = @DevSN, @IDEmpleado = @IDEmpleado, @IDUsuario = @IDUsuario
		END

		DELETE Asistencia.tblLectoresEmpleados  
		where IDLector = @IDLector and IDEmpleado = @IDEmpleado
		
		EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Asistencia].[tblLectoresEmpleados]','[Asistencia].[spBorrarLectoresEmpleados]','DELETE','',@OldJSON
	END

END
GO

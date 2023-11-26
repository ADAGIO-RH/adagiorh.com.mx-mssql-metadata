USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Modificar Parcialmente Usuarios del sistema
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2021-02-18
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
CREATE PROCEDURE [Seguridad].[spUIUsuarioAdministracion]
(
	@IDUsuario int = 0
	,@Cuenta VARCHAR(50)
	,@Nombre VARCHAR(255)
	,@Apellido VARCHAR(255)
	,@Email VARCHAR(255)
	,@Activo bit = 1
	,@IDPerfil Int
	,@EsColaborador bit
	,@EsSupervisor bit
	,@IDUsuarioQueCrea int
)
AS
BEGIN
	declare @Sexo char(1) = null
	;

	select @Nombre = UPPER(@Nombre)
		 ,@Apellido = UPPER(@Apellido)
	;	

	IF(isnull(@IDUsuario,0) <> 0)
	BEGIN
	if exists (select top 1 1 
		from [Seguridad].[tblUsuarios]
		where (Cuenta = @Cuenta or (Email = @Email)) and IDUsuario <> @IDUsuario)
	BEGIN
		exec [App].[spObtenerError] @IDUsuario = @IDUsuarioQueCrea, @CodigoError = '0000006'
		return 0;
	END;
	   
	IF(
		(Select IDPerfil 
			from Seguridad.tblUsuarios with (NOLOCK) 
			where IDUsuario= @IDUsuario) <> @IDPerfil
			)
	BEGIN
		exec Seguridad.spTransferirPermisosPerfilUsuario @IDUsuario, @IDPerfil
	END

	UPDATE Seguridad.tblUsuarios
	set Cuenta		= case when isnull(@EsColaborador,0) = 0 then @Cuenta else Cuenta end
		,Nombre		= case when isnull(@EsColaborador,0) = 0 then @Nombre else Nombre end 
		,Apellido	= case when isnull(@EsColaborador,0) = 0 then @Apellido else Apellido end 
		,Email		= @Email
		,Activo		= @Activo
		,Supervisor		= @EsSupervisor
		,IDPerfil	= @IDPerfil
	WHERE IDUsuario	= @IDUsuario
	END
	ELSE
	BEGIN
		INSERT INTO Seguridad.tblUsuarios(Cuenta, Nombre, Apellido, Email, Activo, IDPerfil, Supervisor)
		VALUES (
		 @Cuenta 
		,@Nombre 
		,@Apellido 
		,@Email 
		,@Activo 
		,@IDPerfil  
		,@EsSupervisor
		)

		SET @IDUsuario = @@IDENTITY

		exec Seguridad.spTransferirPermisosPerfilUsuario @IDUsuario, @IDPerfil

	END

	exec [Seguridad].[spBuscarUsuarios] @IDUsuario = @IDUsuario
END
GO

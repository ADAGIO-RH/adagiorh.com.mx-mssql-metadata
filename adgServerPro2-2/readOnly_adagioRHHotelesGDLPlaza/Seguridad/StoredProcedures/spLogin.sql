USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Valida el acceso al sistema adagioRH
** Autor			: José Román
** Email			: jose.roman@adagio.com.mx
** FechaCreacion	: 2017-08-01
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
2018-09-20			Aneudy Abreu	Se cambió la forma de validar el acceso para agregar la llamada 
									del SP  [Seguridad].[spBuscarUsuario]
2021-02-05			Aneudy Abreu	Se agregó una validación para que los colaboradores que no estén 
									vigentes no puedan ingresar al sistema.
***************************************************************************************************/
CREATE PROCEDURE [Seguridad].[spLogin]
(
	@Usuario Varchar(50),
	@Password Varchar(50)
)
AS
BEGIN
	declare @IDUsuario int = null;

	Select top 1 @IDUsuario=u.IDUsuario 
	from Seguridad.tblUsuarios u with(nolock)
		left join RH.tblEmpleadosMaster e on e.IDEmpleado = u.IDEmpleado
	Where (u.Cuenta = @Usuario or u.Email=@Usuario) and 
		u.Password = @Password and 
		isnull(u.Activo,0) = 1 and
		(isnull(u.IDEmpleado,0) = 0 or isnull(e.Vigente, 0) = 1)


	IF (@IDUsuario is not null)
	BEGIN
		exec [Seguridad].[spBuscarUsuario] @IDUsuario=@IDUsuario
	END
	ELSE
	BEGIN
		--RAISERROR('Cuenta o Clave Incorrecto.',16,1);
		exec [App].[spObtenerError] null,'0000001', 'Es probable que el colaborador no se encuentre vigente.'
	END
END
GO

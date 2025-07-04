USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Valida el acceso al sistema adagioRH por personId
** Autor			: Aneudy Abreu
** Email			: aneudy.abreu@adagio.com.mx
** FechaCreacion	: 2021-09-21
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------
***************************************************************************************************/
create PROCEDURE [Seguridad].[spLoginByPersonId](
	@personId varchar(255)
)
AS
BEGIN
	declare @IDUsuario int = null;

	Select top 1 @IDUsuario=u.IDUsuario 
	from Seguridad.tblUsuarios u with(nolock)
		join RH.tblEmpleadosMaster e on e.IDEmpleado = u.IDEmpleado
		join AzureCognitiveServices.tblPersons p on p.IDEmpleado = e.IDEmpleado
	where p.PersonId = @personId and 
		isnull(u.Activo,0) = 1 and (isnull(u.IDEmpleado,0) = 0 or isnull(e.Vigente, 0) = 1)


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

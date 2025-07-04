USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [RH].[spBorrarAprobadiorFijoPlazaPosicion](
	@IDAprobadorFijoPlazaPosicion int,
	@IDUsuario int
)
AS
BEGIN

	DECLARE 
		@OldJSON Varchar(Max),
		@NewJSON Varchar(Max),
		@IDIdioma varchar(max)
	;
	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select @OldJSON = a.JSON 
	from (
		select
				afpp.*,
				c.Codigo as CodigoCliente,
				JSON_VALUE(c.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'NombreComercial')) as Cliente,
				u.Cuenta, 
				coalesce(u.Nombre, '') + ' ' +  coalesce(u.Apellido, '')  as NombreUsuario, 
				u.Email, 
				u.IDEmpleado
			from RH.tblAprobadoresFijosPlazasPosiciones afpp 
				join RH.tblCatClientes c on c.IDCliente = afpp.IDCliente
				join Seguridad.tblUsuarios u on u.IDUsuario = afpp.IDUsuario
			where IDAprobadorFijoPlazaPosicion = @IDAprobadorFijoPlazaPosicion
	) b
	cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

	EXEC [Auditoria].[spIAuditoria] 
		@IDUsuario,
		'[RH].[tblAprobadoresFijosPlazasPosiciones]',
		'[RH].[spIUAprobadiorFijoPlazaPosicion]',
		'DELETE',
		'',
		@OldJSON
	
    BEGIN TRY  
		DELETE RH.tblAprobadoresFijosPlazasPosiciones
		WHERE IDAprobadorFijoPlazaPosicion = @IDAprobadorFijoPlazaPosicion
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
END
GO

USE [p_adagioRHGrupoEnergy]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [RH].[spBorrarAprobadorPredeterminadoPlazaPosicion](
	@IDAprobadorPredeterminadoPlazaPosicion int,
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
			from RH.tblAprobadoresPredeterminadosPlazasPosiciones afpp 
				join RH.tblCatClientes c on c.IDCliente = afpp.IDCliente
				join Seguridad.tblUsuarios u on u.IDUsuario = afpp.IDUsuario
			where IDAprobadorPredeterminadoPlazaPosicion = @IDAprobadorPredeterminadoPlazaPosicion
	) b
	cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a

	EXEC [Auditoria].[spIAuditoria] 
		@IDUsuario,
		'[RH].[tblAprobadoresPredeterminadosPlazasPosiciones]',
		'[RH].[spIUAprobadiorPredeterminadoPlazaPosicion]',
		'DELETE',
		'',
		@OldJSON
	
    BEGIN TRY  
		DELETE RH.tblAprobadoresPredeterminadosPlazasPosiciones
		WHERE IDAprobadorPredeterminadoPlazaPosicion = @IDAprobadorPredeterminadoPlazaPosicion
    END TRY  
    BEGIN CATCH  
	   EXEC [App].[spObtenerError] @IDUsuario = @IDUsuario, @CodigoError = '0302002'
	   return 0;
    END CATCH ;
END
GO

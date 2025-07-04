USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create   proc [RH].[spBuscarIdiomaEmpleado](
	@IDEmpleado int
) as
	declare
		@IDUsuario int , 
		@IDIdioma varchar(20)
	;

	select 
		@IDUsuario = IDUsuario
	from Seguridad.tblUsuarios
	where IDEmpleado = @IDEmpleado

	select IDIdioma = App.fnGetPreferencia('Idioma', @IDUsuario, 'es-MX')
GO

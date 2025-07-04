USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Intranet].[spBuscarConfigDashboardNomina](
	@IDEmpleado int,
	@Ejercicio int,
	@IDUsuario int
)
AS
BEGIN
	declare 
		@IDPais int,
		@IDIdioma varchar(20)
	;

	select @IDIdioma=App.fnGetPreferencia('Idioma', @IDUsuario, 'esmx')

	select top 1 @IDPais = isnull(ctn.IDPais, 151)
	from RH.tblEmpleadosMaster e
		join Nomina.tblCatTipoNomina ctn on ctn.IDTipoNomina = e.IDTipoNomina
	where e.IDEmpleado = @IDEmpleado

	select IDConfigDashboardNomina
		   ,JSON_VALUE(Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace(@IDIdioma, '-','')), 'BotonLabel')) as BotonLabel
		   ,Filtro 
		   ,@IDEmpleado as IDEmpleado
		   ,@Ejercicio as Ejercicio
	from Intranet.tblConfigDashboardNomina
	where isnull(IDPais, 151) = @IDPais
END
GO

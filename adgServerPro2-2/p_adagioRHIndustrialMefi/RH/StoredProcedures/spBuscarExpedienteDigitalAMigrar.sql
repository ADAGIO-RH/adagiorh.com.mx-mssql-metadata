USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create   Proc RH.spBuscarExpedienteDigitalAMigrar(
	@IDEmpleado int
) as
	declare
		@RutaFisica varchar(max)
	;

	set @RutaFisica = App.fnGetConfiguracionGeneral('RutaFisica', 1, '')
	select 
		ede.IDEmpleado, 
		ede.[Name], 
		FORMATMESSAGE('%s_%s_%s', e.ClaveEmpleado, isnull(ed.Codigo, '000'), ede.[Name]) as [NameFile],
		FORMATMESSAGE('Docs/ExpDig/%s/', e.ClaveEmpleado) as  [PathFile],
		FORMATMESSAGE('%sDocs\ExpDig\%s\', @RutaFisica, e.ClaveEmpleado) as  [PathFileLocal],
		ede.IDExpedienteDigital, 
		ede.ContentType,
		ede.[Data]
	from RH.ExpedienteDigitalEmpleado ede
		join RH.tblCatExpedientesDigitales ed on ed.IDExpedienteDigital = ede.IDExpedienteDigital
		join RH.tblEmpleadosMaster e on e.IDEmpleado = ede.IDEmpleado
	where ede.IDEmpleado = @IDEmpleado
GO

USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [ChecadorDelphi].[spBuscarConfiguracionChecador]
as	
	declare
		@PathLogoCliente varchar(max),
		@ValidarContratos bit,
		@ChecadaSinHorario bit,
		@TiempoEntreChecadas time
	;

	select @PathLogoCliente		= Valor from App.tblConfiguracionesGenerales cg where IDConfiguracion = 'PathLogoCliente'
	select @ValidarContratos	= isnull(cast(Valor as bit),cast(0 as bit)) from App.tblConfiguracionesGenerales cg where IDConfiguracion = 'ValidarContratos'
	select @ChecadaSinHorario	= isnull(cast(Valor as bit),cast(0 as bit)) from App.tblConfiguracionesGenerales cg where IDConfiguracion = 'ChecadaSinHorario'
	select @TiempoEntreChecadas = cast(isnull(dateadd(MINUTE,cast(Valor as int),'00:00:00'),'01:00') as time) from App.tblConfiguracionesGenerales cg where IDConfiguracion = 'TiempoEntreChecadas'

	select 
		@PathLogoCliente		as PathLogoCliente  
		,@ValidarContratos		as ValidarContratos 
		,@ChecadaSinHorario		as ChecadaSinHorario
		,@TiempoEntreChecadas	as TiempoEntreChecadas
GO

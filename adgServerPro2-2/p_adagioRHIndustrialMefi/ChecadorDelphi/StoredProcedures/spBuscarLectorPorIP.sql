USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create proc [ChecadorDelphi].spBuscarLectorPorIP(
	@IP varchar(50)
) as
	select IDLector
	,Lector
	,CodigoLector
	,IDTipoLector
	,IDZonaHoraria
	,IP
	,Puerto
	,Estatus
	,IDCliente
	,EsComedor
	,Comida 
	from Asistencia.tblLectores with (nolock)
	where IP = @IP
GO

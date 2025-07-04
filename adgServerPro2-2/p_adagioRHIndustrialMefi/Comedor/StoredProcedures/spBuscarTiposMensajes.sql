USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc Comedor.spBuscarTiposMensajes as
begin
	declare @resp as table (
		[value] varchar(10),
		[text] varchar(100),
		[icon] varchar(100)
	)

	insert @resp([value], [text], [icon])
	values
		('info', 'Información', 'fa fa-info-circle')
		,('warning', 'Notificación', 'fa fa-exclamation-triangle')

	select *
	from @resp
end
GO

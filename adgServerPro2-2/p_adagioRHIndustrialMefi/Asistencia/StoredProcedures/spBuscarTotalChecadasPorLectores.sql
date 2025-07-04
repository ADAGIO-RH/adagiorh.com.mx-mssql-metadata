USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc Asistencia.spBuscarTotalChecadasPorLectores(
		@Fecha date  
		,@IDLector int = 0
		,@IDUsuario int
) as
	select coalesce(l.CodigoLector,'')+'-'+coalesce(l.Lector, '') as Lector, count(*) as Total
	from Asistencia.tblChecadas c
		join Asistencia.tblLectores l on l.IDLector = c.IDLector
	where c.FechaOrigen = @Fecha
	group by l.CodigoLector, l.Lector
GO

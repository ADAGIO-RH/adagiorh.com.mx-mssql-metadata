USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc RH.spBuscarAprobadorActualPlaza(
	@IDPlaza int,
	@IDUsuario int
) as

	declare 
		@Secuencia int
	;

	select @Secuencia = MAX(Secuencia) from RH.tblAprobadoresPlazas where IDPlaza = @IDPlaza

	select top 1
		IDAprobadorPlaza,
		IDPlaza,
		IDUsuario,
		Secuencia,
		isnull(Orden, 0) as Orden
	from RH.tblAprobadoresPlazas
	where IDPlaza = @IDPlaza and Secuencia = @Secuencia and ISNULL(Aprobacion, 0) = 0
	order by Orden asc
GO

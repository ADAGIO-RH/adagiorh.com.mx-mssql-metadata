USE [p_adagioRHThangos]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Asistencia].[spBorrarAjustesSaldosVacacionesEmpleado] (
	@IDAjusteSaldo int,
	@IDUsuario int
) as

	delete from [Asistencia].[tblAjustesSaldoVacacionesEmpleado] 
	where IDAjusteSaldo = @IDAjusteSaldo
GO

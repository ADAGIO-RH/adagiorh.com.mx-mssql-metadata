USE [readOnly_adagioRHHotelesGDLPlaza]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [bk].[spPruebaTask]
as

insert Bk.TestScheduler(FechaHora)
select GETDATE()
GO

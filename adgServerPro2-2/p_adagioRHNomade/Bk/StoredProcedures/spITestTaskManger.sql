USE [p_adagioRHNomade]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure Bk.spITestTaskManger
as

    insert into Bk.tblTestTaskManager(value)
    select cast(getdate() as Varchar)
GO

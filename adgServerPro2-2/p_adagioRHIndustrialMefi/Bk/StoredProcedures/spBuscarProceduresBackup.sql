USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Bk].[spBuscarProceduresBackup](
    @BKID varchar(50)
)
as

select *
from [Bk].[tblStoredProcedures]
where BKID = @BKID
GO

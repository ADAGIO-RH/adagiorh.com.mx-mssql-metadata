USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc Bk.spIEmpleadoActualizado(
	@IDEmpleado int			 
    ,@Tabla varchar(255)		 
    ,@IDUsuario int			 
) as
    insert into [Bk].[TblEmpleadoActualizado](IDEmpleado, Tabla, IDUsuario)
    select @IDEmpleado,@Tabla,@IDUsuario
GO

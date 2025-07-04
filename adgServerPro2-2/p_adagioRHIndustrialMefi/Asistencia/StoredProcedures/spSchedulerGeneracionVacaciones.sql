USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Asistencia].[spSchedulerGeneracionVacaciones]  
(  
     @IDUsuario int = 0
    ,@IDCliente int  = 0
    ,@IDTipoPrestacion int = 0
    ,@IDEmpleado int = 0
)  
AS  
BEGIN  
  
    DECLARE @FechaHora datetime = dateadd(MINUTE,2,getdate())
    DECLARE @sp varchar(max)
    
    select @sp = concat(' [Asistencia].[spCoreGenerarSaldosVacacionesPorAniosMasivo] @IDUsuario=' ,@IDUsuario,',@IDCliente=',@IDCliente,',@IDTipoPrestacion=',@IDTipoPrestacion,',@IDEmpleado=',@IDEmpleado)    
    insert into app.tblScheduleVacaciones(StoredProcedure,FechaHoraCreacion,Generado,Masivo) values (@sp,GETDATE(),0,Case when @IDEmpleado <> 0 Then 0 Else 1 End)

END
GO

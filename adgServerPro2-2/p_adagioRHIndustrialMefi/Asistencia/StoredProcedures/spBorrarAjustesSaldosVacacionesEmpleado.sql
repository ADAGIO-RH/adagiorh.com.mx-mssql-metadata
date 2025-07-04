USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [Asistencia].[spBorrarAjustesSaldosVacacionesEmpleado] (
	@IDAjusteSaldo int,
	@IDUsuario int
) as

    DECLARE 
    @IDEmpleado INT = (SELECT IDempleado FROM Asistencia.tblAjustesSaldoVacacionesEmpleado WHERE IDAjusteSaldo = @IDAjusteSaldo)
   ,@IDMovAfiliatorio INT = (SELECT IDMovAfiliatorio FROM Asistencia.tblAjustesSaldoVacacionesEmpleado WHERE IDAjusteSaldo = @IDAjusteSaldo)


    DELETE FROM Asistencia.tblSaldoVacacionesEmpleado 
    WHERE IDEmpleado = IDEmpleado and IDMovAfiliatorio = @IDMovAfiliatorio

	DELETE FROM [Asistencia].[tblAjustesSaldoVacacionesEmpleado] 
	WHERE IDAjusteSaldo = @IDAjusteSaldo
GO

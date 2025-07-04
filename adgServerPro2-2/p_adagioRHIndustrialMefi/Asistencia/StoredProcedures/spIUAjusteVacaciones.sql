USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Asistencia].[spIUAjusteVacaciones]( 
	@IDAjusteSaldo int = 0
	,@IDEmpleado int = 0    
	,@SaldoFinal int      
	,@FechaAjuste Date     
	,@IDUsuario int 
) as    
	declare @IDMovAfiliatorio int;

	IF(isnull(@IDAjusteSaldo, 0) = 0)
	BEGIN
		SELECT 
			@IDMovAfiliatorio = mov.IDMovAfiliatorio 
		FROM IMSS.tblMovAfiliatorios Mov WITH(NOLOCK)
			INNER JOIN RH.tblEmpleadosMaster  M WITH(NOLOCK)
				ON Mov.IDEmpleado = M.IDEmpleado AND Mov.Fecha =  M.FechaAntiguedad 
		WHERE M.IDEmpleado = @IDEmpleado

		IF Exists(Select top 1 1 
				from Asistencia.tblAjustesSaldoVacacionesEmpleado 
				where IDEmpleado = @IDEmpleado AND IDMovAfiliatorio = @IDMovAfiliatorio
		)
		BEGIN
			UPDATE Asistencia.tblAjustesSaldoVacacionesEmpleado
			SET SaldoFinal = @SaldoFinal,@FechaAjuste = @FechaAjuste
			WHERE IDEmpleado = @IDEmpleado AND IDMovAfiliatorio = @IDMovAfiliatorio
		END
		ELSE
		BEGIN
			Insert Into Asistencia.tblAjustesSaldoVacacionesEmpleado
			Select @IDEmpleado,@SaldoFinal,@FechaAjuste,@IDMovAfiliatorio
		END
	END
	ELSE 
	BEGIN
		UPDATE Asistencia.tblAjustesSaldoVacacionesEmpleado
			SET 
				SaldoFinal = @SaldoFinal,
				FechaAjuste = @FechaAjuste
		WHERE IDAjusteSaldo = @IDAjusteSaldo
	END
GO

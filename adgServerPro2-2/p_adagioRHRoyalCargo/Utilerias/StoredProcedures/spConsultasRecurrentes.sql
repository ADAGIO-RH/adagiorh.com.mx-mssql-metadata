USE [p_adagioRHRoyalCargo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Utilerias].[spConsultasRecurrentes]

	


AS

BEGIN

	DECLARE @Querys AS TABLE (Query VARCHAR(MAX))

	INSERT INTO @Querys (Query) VALUES
	
	 ('SELECT * FROM RH.tblEmpleadosMaster WHERE ClaveEmpleado = ')
	,('SELECT * FROM RH.tblEmpleadosMaster WHERE IDEmpleado = ')
	,('SELECT * FROM Nomina.tblCatPeriodos WHERE IDPeriodo = '	  )
	,('SELECT * FROM Nomina.tblCatPeriodos WHERE ClavePeriodo = ' )
	



	SELECT * FROM @Querys

END
GO

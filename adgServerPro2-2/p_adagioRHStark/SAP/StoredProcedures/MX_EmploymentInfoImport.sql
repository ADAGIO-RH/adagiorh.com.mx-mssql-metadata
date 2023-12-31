USE [p_adagioRHStark]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jose Vargas
-- Create date: 2022-01-27
-- Description:	Importación a SAP
-- =============================================
CREATE PROCEDURE SAP.MX_EmploymentInfoImport
	-- Add the parameters for the stored procedure here	
AS
BEGIN


	SELECT  
	COALESCE(u.IDUsuario,0) [user-id],
	e.IDEmpleado [person-id-external],
	e.FechaPrimerIngreso [start-date],
	e.FechaAntiguedad [originalStartDate],
	e.FechaAntiguedad [seniorityDate],
	'' [benefits-eligibility-start-date],
	e.ClaveEmpleado [prevEmployeeId],
	'' [serviceDate],
	'' [jobNumber]
	FROM rh.tblEmpleadosMaster e
	left join Seguridad.tblUsuarios u on u.IDEmpleado =e.IDEmpleado


END
GO

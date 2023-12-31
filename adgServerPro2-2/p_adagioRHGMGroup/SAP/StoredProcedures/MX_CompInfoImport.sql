USE [p_adagioRHGMGroup]
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
CREATE PROCEDURE [SAP].[MX_CompInfoImport]
	-- Add the parameters for the stored procedure here	
AS
BEGIN

	
	select 
	isnull(dd.Valor,e.ClaveEmpleado) [user-id],
	 convert(varchar, getdate() , 101) [start-date],
	'' [end-date],
	'' [pay-grade],
	'Salaried' [pay-type],
	'BWK' [pay-group],
	'CURRACTIVE' [event-reason]
    from rh.tblEmpleadosMaster  e
    left join rh.tblDatosExtraEmpleados dd on dd.IDEmpleado=e.IDEmpleado and dd.IDDatoExtra=5
    where e.Vigente=1

END
GO

USE [p_adagioRHAvilab]
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
CREATE PROCEDURE [SAP].[MX_PayComponentRecurringImport]
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	select 
		isnull(dd.Valor,e.ClaveEmpleado) [user-id],
        convert(varchar, getdate() , 101) [start-date],
		
		'' [end-date]	,
		1 [seq-number]	,
		100 [pay-component]	,
		e.SalarioDiario*365 [paycompvalue]	,
		'MXN' [currency-code]	,
		'ANN' [frequency]	,
		'' [notes]	,
		'' [operation]
        from rh.tblEmpleadosMaster E
        left join rh.tblDatosExtraEmpleados dd on dd.IDEmpleado=e.IDEmpleado and dd.IDDatoExtra=5
        where e.Vigente=1
END
GO

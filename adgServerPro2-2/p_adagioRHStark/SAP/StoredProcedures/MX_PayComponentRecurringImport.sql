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
CREATE PROCEDURE SAP.MX_PayComponentRecurringImport
	-- Add the parameters for the stored procedure here	
AS
BEGIN

	
	select 
	'' [user-id],
	'' [start-date],	
	'' [end-date]	,
	'' [seq-number]	,
	'' [pay-component]	,
	'' [paycompvalue]	,
	'' [currency-code]	,
	'' [frequency]	,
	'' [notes]	,
	'' [operation]
END
GO

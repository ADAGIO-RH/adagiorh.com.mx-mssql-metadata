USE [p_adagioRHCorporativoCet]
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
CREATE PROCEDURE SAP.MX_JobInfoImport
	-- Add the parameters for the stored procedure here	
AS
BEGIN

	
	select 
	''[user-id]	,
	''[custom-string1]	,
	''[end-date]	,
	''[custom-string2]	,
	''[custom-string3]	,
	''[custom-string5]	,
	''[custom-string10]	,
	''[start-date]	,
	''[job-title]	,
	''[job-code]	,
	''[department]	,
	''[division]	,
	''[location]	,
	''[notes]	,
	''[company]	,
	''[business-unit]	,
	''[cost-center]	,
	''[employee-class]	,
	''[employment-type]	,
	''[fte]	,
	''[regular-temp]	,
	''[standard-hours]	,
	''[workingDaysPerWeek]	,
	''[position]	,
	''[local-job-title]	,
	''[is-fulltime-employee]	,
	''[pay-grade]	,
	''[is-shift-employee]	,
	''[shift-code]	,
	''[seq-number]	,
	''[manager-id]	,
	''[expected-return-date]	,
	''[timezone]	,
	''[event-reason]	,
	''[notice-period]	,
	''[flsa-status]	,
	''[contract-type]	,
	''[eeo-class]	,
	''[work-location]	,
	''[labor-Protection]	,
	''[probation-period-end-date]	,
	''[operation]


END
GO

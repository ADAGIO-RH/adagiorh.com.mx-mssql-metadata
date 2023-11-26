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
CREATE PROCEDURE SAP.MX_NationalIdCardImport
	-- Add the parameters for the stored procedure here	
AS
BEGIN

	
	SELECT 
	'' [person-id-external]	,
	'' [country]	,
	'' [card-type]	,
	'' [national-id]	,
	'' [isPrimary]	,
	'' [notes]	,
	'' [operation]


END
GO

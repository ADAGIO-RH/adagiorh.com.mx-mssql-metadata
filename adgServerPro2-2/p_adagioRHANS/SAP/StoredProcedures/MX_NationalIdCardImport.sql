USE [p_adagioRHANS]
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
CREATE PROCEDURE [SAP].[MX_NationalIdCardImport]
	-- Add the parameters for the stored procedure here	
AS
BEGIN

	
	SELECT 
		isnull(dd.Valor,e.ClaveEmpleado) as [person-id-external]	,
		p.Codigo	as [country],
		'PR'		as[card-type]	,
		e.CURP	as [national-id]	,
		'Y'		as [isPrimary]	,
		'' [notes]	,
		'' [operation]
	from RH.tblEmpleadosMaster e
		left join Sat.tblCatPaises p on p.IDPais = e.IDPaisNacimiento
        left join rh.tblDatosExtraEmpleados dd on dd.IDEmpleado=e.IDEmpleado and dd.IDDatoExtra=5
	where isnull(e.IDPaisNacimiento, 0) <> 0 and e.Vigente=1


END
GO

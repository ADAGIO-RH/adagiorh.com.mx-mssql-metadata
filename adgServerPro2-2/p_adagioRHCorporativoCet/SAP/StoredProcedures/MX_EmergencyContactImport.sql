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
CREATE PROCEDURE SAP.MX_EmergencyContactImport
	-- Add the parameters for the stored procedure here	
AS
BEGIN

	select 
	e.IDEmpleado [personal-id-external],
	fm.NombreCompleto [name],
	fm.TelefonoCelular [phone],
	fm.TelefonoMovil [second-phone],
	cf.Descripcion [relationship],
	'Y' [primary_flag],
	'' [email],
	'' [operation]

	from rh.tblEmpleadosMaster e
	inner join  RH.tblFamiliaresBenificiariosEmpleados fm on e.IDEmpleado=fm.IDEmpleado
	inner join  RH.tblCatParentescos cf on cf.IDParentesco=fm.IDParentesco


END
GO

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
CREATE PROCEDURE SAP.MX_CompoundDependentsImport
	-- Add the parameters for the stored procedure here	
AS
BEGIN

		select 
			e.IDEmpleado [personal-id-external],
			fm.IDFamiliarBenificiarioEmpleado [related-person-id-external],
			case  fm.Beneficiario  when  '0' then 'No' when 1 then 'YES' Else 'Desconocido' end [is-beneficiary],
			'' [start-date],
			cf.Descripcion [relationship-type],
			'' [is-address-same-as-person] ,
			'' [operation] ,
 			convert(varchar, fm.FechaNacimiento , 101)  [date-of-birth],
 			'' [first-name],
 			'' [last-name],
 			'' [middle-name],
 			fm.Sexo [gender]
			from rh.tblEmpleadosMaster e
			inner join  RH.tblFamiliaresBenificiariosEmpleados fm on e.IDEmpleado=fm.IDEmpleado
			inner join  RH.tblCatParentescos cf on cf.IDParentesco=fm.IDParentesco


END
GO

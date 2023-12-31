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
CREATE PROCEDURE SAP.MX_AddressImport
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	select 
		e.IDEmpleado [person-id-external],
		de.FechaIni [start-date],
		case de.FechaFin  when  '9999-12-31' then ''  Else convert(varchar, de.FechaFin , 101) end [end-date],
		concat(de.Calle,' ',COALESCE(de.Exterior,''),COALESCE(de.Interior,'')) [address1],
		'' [address2],
		de.[Colonia] [address3],
	de.Municipio [city],
	'' [county],
	de.[Estado] [state],
	'' [province],
	de.[CodigoPostal] [zip-code],
	cp.[Codigo] [country],
	'' [notes],
	'' [address4],
	'' [address5],
	'home' [address-type],
	'' [operation]
	from	 RH.tblEmpleadosMaster e
	left join RH.tblDireccionEmpleado de on de.IDEmpleado =e.IDEmpleado
	inner join Sat.tblCatPaises cp on cp.IDPais=de.IDPais


	
END
GO

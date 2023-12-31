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
CREATE PROCEDURE [SAP].[MX_GlobalInfoImport]
	-- Add the parameters for the stored procedure here	
AS
BEGIN

	select 
	e.IDEmpleado [person-id-external],
	e.FechaIniContrato [start-date],
	case e.FechaFinContrato  when  '9999-12-31' then ''  Else convert(varchar, e.FechaFinContrato , 101)  end [end-date],
	cp.[Codigo] [country],
	'' [genericString1],
	'' [genericNumber1],
	'' [genericNumber9],
	'' [genericString2],
	'' [genericString10],
	'' [genericString11],
	'' [genericString12],
	'' [genericString13],
	'' [genericString14],
	'' [genericNumber2],
	e.RFC [genericNumber3],
	e.IMSS [genericNumber4],
	'' [genericNumber7],
	'' [genericString16],
	'' [genericString3],
	'' [genericString4],
	'' [genericDate1],
	'' [genericDate2],
	'' [genericString5],
	'' [genericString6],
	'' [genericString7],
	'' [genericString8],
	e.Materno [custom-string2],
	e.Paterno [custom-string3],
	'' [genericNumber] 
	from RH.tblEmpleadosMaster e
	inner join Sat.tblCatPaises cp on cp.IDPais=e.IDPaisNacimiento

END
GO

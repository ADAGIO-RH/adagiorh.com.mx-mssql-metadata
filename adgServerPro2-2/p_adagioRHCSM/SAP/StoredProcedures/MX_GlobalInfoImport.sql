USE [p_adagioRHCSM]
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
		isnull(dd.Valor,e.ClaveEmpleado) [person-id-external],        
		convert(varchar, e.FechaPrimerIngreso , 101) [start-date],
		''  [end-date],
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
		'' [genericNumber3],
		'' [genericNumber4],
		'' [genericNumber7],
		'' [genericString16],
		e.RFC [genericString3],
		e.IMSS [genericString4],
		'' [genericDate1],
		'' [genericDate2],
		'' [genericString5],
		'' [genericString6],
		'' [genericString7],
		'' [genericString8],
		Utilerias.fnEliminarAcentos(COALESCE(e.Materno,'')) [custom-string2],
		Utilerias.fnEliminarAcentos(COALESCE(e.Paterno,'')) [custom-string3],
		'' [genericNumber5] 
	from RH.tblEmpleadosMaster e
		inner join Sat.tblCatPaises cp on cp.IDPais=e.IDPaisNacimiento
        left join rh.tblDatosExtraEmpleados dd on dd.IDEmpleado=e.IDEmpleado and dd.IDDatoExtra=5
    where e.Vigente=1

END
GO

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
CREATE PROCEDURE [SAP].[MX_CompoundDependentsImport]
	-- Add the parameters for the stored procedure here	
AS
BEGIN
        declare @tempResponse as table (      
            [IDParentesco] int,                                
            [DescripcionIngles] VARCHAR (100)               
        );   
        insert @tempResponse(IDParentesco,DescripcionIngles)
        values 
            (1,'FATHER'),
            (2,'MOTHER'),
            (3,'SPOUSE'),
            (4,'CHILD'),
            (5,'DAUGHTER'),
            (6,'OTHER')

		select 
			isnull(dd.Valor,e.ClaveEmpleado) [personal-id-external],
			formatmessage('D%s%s',isnull(dd.Valor,e.ClaveEmpleado), app.fnAddString( 3, cast(ROW_NUMBER()over(order by e.ClaveEmpleado)  as varchar),'0',1)) [related-person-id-external],
			case  fm.Beneficiario  when  '0' then 'NO' when 1 then 'YES' else 'UNKNOWN' end [is-beneficiary],
			'' [start-date],
			CI.DescripcionIngles [relationship-type],
			'' [is-address-same-as-person] ,
			'' [operation] ,
 			convert(varchar, fm.FechaNacimiento , 101)  [date-of-birth],
 			Utilerias.fnEliminarAcentos(fm.NombreCompleto) [first-name],
 			'' [last-name],
 			'' [middle-name],
 			fm.Sexo [gender] 
		from rh.tblEmpleadosMaster e
			inner join  RH.tblFamiliaresBenificiariosEmpleados fm on e.IDEmpleado=fm.IDEmpleado
			inner join  RH.tblCatParentescos cf on cf.IDParentesco=fm.IDParentesco
            INNER JOIN @tempResponse CI ON CI.IDParentesco=cf.IDParentesco
            left join rh.tblDatosExtraEmpleados dd on dd.IDEmpleado=e.IDEmpleado and dd.IDDatoExtra=5
        where e.Vigente=1
		order by e.ClaveEmpleado
END
GO

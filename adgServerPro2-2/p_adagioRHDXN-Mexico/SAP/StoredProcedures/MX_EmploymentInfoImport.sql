USE [p_adagioRHDXN-Mexico]
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
CREATE PROCEDURE [SAP].[MX_EmploymentInfoImport]
	-- Add the parameters for the stored procedure here	
AS
BEGIN
    -- CAMBIO PARA OBTENER SOLAMENTE LOS CLIENTES DE RUGGEDTECH -- 28 JULIO 2023
    declare @IDClienteRuggedtech  INT  ;
    set @IDClienteRuggedtech =1;    

	SELECT  
		isnull(dd.Valor,e.ClaveEmpleado) [user-id],
		isnull(dd.Valor,e.ClaveEmpleado) [person-id-external],
		convert(varchar, e.FechaPrimerIngreso , 101) [start-date],
		convert(varchar, e.FechaPrimerIngreso , 101)  [originalStartDate],
		convert(varchar, e.FechaPrimerIngreso , 101)   [seniorityDate],
		convert(varchar, e.FechaPrimerIngreso , 101) [benefits-eligibility-start-date],
		e.ClaveEmpleado [prevEmployeeId],
		'' [serviceDate],
		'' [jobNumber]
	FROM rh.tblEmpleadosMaster e
	    left join Seguridad.tblUsuarios u on u.IDEmpleado =e.IDEmpleado
        left join rh.tblDatosExtraEmpleados dd on dd.IDEmpleado=e.IDEmpleado and dd.IDDatoExtra=5
    where e.Vigente=1 and e.IDCliente=@IDClienteRuggedtech

END
GO

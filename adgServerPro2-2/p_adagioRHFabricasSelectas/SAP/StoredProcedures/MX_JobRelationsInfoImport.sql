USE [p_adagioRHFabricasSelectas]
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
CREATE PROCEDURE [SAP].[MX_JobRelationsInfoImport]
	-- Add the parameters for the stored procedure here	
AS
BEGIN

    -- CAMBIO PARA OBTENER SOLAMENTE LOS CLIENTES DE RUGGEDTECH -- 28 JULIO 2023
    declare @IDClienteRuggedtech  INT  ;
    set @IDClienteRuggedtech =1;      

	SELECT 
		isnull(dd.Valor,e.ClaveEmpleado) as [user-id]	 ,
	    convert(varchar, getdate() , 101) [start-date],
		'' [end-date]	 ,
		'HR Representative' [relationship-type]	 ,
		'55006687' [rel-user-id]	 ,
		'' [operation] 
	from RH.tblEmpleadosMaster e		
        left join rh.tblDatosExtraEmpleados dd on dd.IDEmpleado=e.IDEmpleado and dd.IDDatoExtra=5 
    --    left join rh.tblDatosExtraEmpleados dd2 on dd2.IDEmpleado=e.IDEmpleado and dd2.IDDatoExtra=6 
		where e.Vigente=1 and e.IDCliente=@IDClienteRuggedtech 

END
GO

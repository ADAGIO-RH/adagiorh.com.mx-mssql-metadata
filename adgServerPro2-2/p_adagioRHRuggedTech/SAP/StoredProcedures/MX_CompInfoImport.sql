USE [p_adagioRHRuggedTech]
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
CREATE PROCEDURE [SAP].[MX_CompInfoImport]
	-- Add the parameters for the stored procedure here	
AS
BEGIN


    -- CAMBIO PARA OBTENER SOLAMENTE LOS CLIENTES DE RUGGEDTECH -- 28 JULIO 2023
    declare @IDClienteRuggedtech  INT  ;
    set @IDClienteRuggedtech =1;
	
	select 
		isnull(dd.Valor,e.ClaveEmpleado) [user-id],
		 convert(varchar, getdate() , 101) [start-date],
		'' [end-date],
		--'' [pay-grade],
		'Salaried' [pay-type],
		'BWK' [pay-group],
		'CURRACTIVE' [event-reason]
    from rh.tblEmpleadosMaster  e
    left join rh.tblDatosExtraEmpleados dd on dd.IDEmpleado=e.IDEmpleado and dd.IDDatoExtra=5
    where e.Vigente=1 and e.IDCliente=@IDClienteRuggedtech

END
GO

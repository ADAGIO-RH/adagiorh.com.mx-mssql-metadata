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
CREATE PROCEDURE [SAP].[MX_PhoneInfoImport]
	-- Add the parameters for the stored procedure here	
AS
BEGIN

-- CAMBIO PARA OBTENER SOLAMENTE LOS CLIENTES DE RUGGEDTECH -- 28 JULIO 2023
    declare @IDClienteRuggedtech  INT  ;
    set @IDClienteRuggedtech =1;

	select 
		isnull(dd.Valor,e.ClaveEmpleado)	[person-id-external],
		'Other'		[phone-type],
		c.[Value]			[phone-number],
		'' Extension, 
		'Y'[IsPrimary],
        '' as [Operation]  
	FROM RH.tblContactoEmpleado   as c
		inner join RH.tblEmpleadosMaster e on e.IDEmpleado = c.IDEmpleado
		inner join RH.tblCatTipoContactoEmpleado  t on t.IDTipoContacto = c.IDTipoContactoEmpleado
        left join rh.tblDatosExtraEmpleados dd on dd.IDEmpleado=e.IDEmpleado and dd.IDDatoExtra=5
	where t.IDMedioNotificacion in (
        'TelefonoFijo'
        ,'Celular'
        ,'TelefonoFijo'
    ) and e.Vigente=1 and e.IDCliente=@IDClienteRuggedtech 
END
GO

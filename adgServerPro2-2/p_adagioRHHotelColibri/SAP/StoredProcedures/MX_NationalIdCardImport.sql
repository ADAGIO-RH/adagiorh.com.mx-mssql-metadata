USE [p_adagioRHHotelColibri]
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
CREATE PROCEDURE [SAP].[MX_NationalIdCardImport]
	-- Add the parameters for the stored procedure here	
AS
BEGIN

    -- CAMBIO PARA OBTENER SOLAMENTE LOS CLIENTES DE RUGGEDTECH -- 28 JULIO 2023
    declare @IDClienteRuggedtech  INT  ;
    set @IDClienteRuggedtech =1;
	
	SELECT 
		isnull(dd.Valor,e.ClaveEmpleado) as [person-id-external]	,
		p.Codigo	as [country],
		'PR'		as[card-type]	,
		e.CURP	as [national-id]	,
		'Y'		as [isPrimary]	,
		'' [notes]	,
		'' [operation]
	from RH.tblEmpleadosMaster e
		left join Sat.tblCatPaises p on p.IDPais = e.IDPaisNacimiento
        left join rh.tblDatosExtraEmpleados dd on dd.IDEmpleado=e.IDEmpleado and dd.IDDatoExtra=5
	where isnull(e.IDPaisNacimiento, 0) <> 0 and e.Vigente=1 and e.IDCliente=@IDClienteRuggedtech 


END
GO

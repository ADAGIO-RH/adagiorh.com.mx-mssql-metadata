USE [p_adagioRHEdman]
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
CREATE PROCEDURE [SAP].[MX_EmailInfoImport]
	-- Add the parameters for the stored procedure here	
AS
BEGIN


	select 
		isnull(dd.Valor,e.ClaveEmpleado) [person-id-external] ,
		'Business' [email-type], 
		c.[Value] [email-address],
		case Predeterminado  when  null then 'N' when 1 then 'Y' Else 'N' end [IsPrimary], 
		'' [operation]
	From RH.tblEmpleadosMaster e
		left join rh.tblContactoEmpleado c on c.IDEmpleado=e.IDEmpleado 
		left join RH.tblCatTipoContactoEmpleado t on t.IDTipoContacto=c.IDTipoContactoEmpleado
        left join rh.tblDatosExtraEmpleados dd on dd.IDEmpleado=e.IDEmpleado and dd.IDDatoExtra=5
	where t.Descripcion like '%Email%'  and c.[Value] like '%CARHARTT%'

END
GO

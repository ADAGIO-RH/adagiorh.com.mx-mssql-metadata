USE [p_adagioRHStark]
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
CREATE PROCEDURE SAP.MX_PhoneInfoImport
	-- Add the parameters for the stored procedure here	
AS
BEGIN

	select c.IDEmpleado [person-id-external],t.Descripcion [phone-type],c.[Value] [phone-number],'' Extension, 
	case Predeterminado  when  null then 'N' when 1 then 'Y' Else 'N' end [IsPrimary],'' as [Operation]  FROM RH.tblContactoEmpleado   as c
	inner join RH.tblCatTipoContactoEmpleado  t on t.IDTipoContacto = c.IDContactoEmpleado
	--where t.IDMedioNotificacion is null



END
GO

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
CREATE PROCEDURE SAP.MX_PersonInfoImport
	-- Add the parameters for the stored procedure here	
AS
BEGIN

	select COALESCE(u.IDUsuario,0) [user-id],  convert(varchar, e.FechaNacimiento , 101)[date-of-birth] ,e.IDEmpleado [person-id-external] From RH.tblEmpleadosMaster  as e
	left join Seguridad.tblUsuarios u on u.IDEmpleado=e.IDEmpleado



END
GO

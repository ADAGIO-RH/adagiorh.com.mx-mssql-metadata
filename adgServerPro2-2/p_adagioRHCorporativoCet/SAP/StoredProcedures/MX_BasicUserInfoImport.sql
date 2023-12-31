USE [p_adagioRHCorporativoCet]
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
CREATE PROCEDURE SAP.MX_BasicUserInfoImport
	-- Add the parameters for the stored procedure here	
AS
BEGIN

				select case  e.Vigente  when  '0' then 'No Activo' when 1 then 'Activo' Else 'Desconocido' end [STATUS],
				u.IDUsuario [USERID],
				u.Cuenta,
				e.Nombre [FIRTNAME],
				CONCAT(e.Paterno,' ',e.Materno) [last-name],
				COALESCE(e.SegundoNombre,'') [middle-name],
				u.Email ,
				'' [MANAGER],
				'' [HR],
				e.Division [DIVISION],
				e.Departamento [DEPARTMENT],
				'' [LOCATION],
				'' [JOBCODE],
				'' [TIMEZONE],
				e.FechaAntiguedad [HIREDATE],
				e.IDEmpleado [EMPID],
				'' [TITLE],
				'' [BIZ_PHONE],
				'' [FAX],
				'' [ADDR1],
				'' [ADDR2],
				'' [CITY],
				'' [STATE],
				'' [ZIP],
				'' [COUNTRY],
				'' [CUSTOM01],
				'' [CUSTOM02],
				'' [CUSTOM03],
				'' [CUSTOM04],
				'' [CUSTOM05],
				'' [CUSTOM06],
				'' [CUSTOM07],
				'' [CUSTOM08],
				'' [CUSTOM09],
				'' [CUSTOM10],
				'' [CUSTOM11],
				'' [CUSTOM12],
				'' [CUSTOM13],
				'' [CUSTOM14],
				'' [CUSTOM15],
				'' [CUSTOM16],
				'' [DEFAULT_LOCALE],
				'' [PROXY],
				'' [CUSTOM_MANAGER],
				'' [SECOND_MANAGER],
				'' [PAYGRADE],
				'' [ONBOARDING_ID]
				from rh.tblEmpleadosMaster as e 
				inner join Seguridad.tblUsuarios u on u.IDEmpleado=e.IDEmpleado	
END
GO

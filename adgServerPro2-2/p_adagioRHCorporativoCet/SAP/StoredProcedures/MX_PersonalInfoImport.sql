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
CREATE PROCEDURE SAP.MX_PersonalInfoImport
	-- Add the parameters for the stored procedure here	
AS
BEGIN

	SELECT 
	e.IDEmpleado [person-id-external],
	convert(varchar, e.FechaIniContrato , 101) [start-date],
	case e.FechaFinContrato  when  '9999-12-31' then ''  Else convert(varchar, e.FechaFinContrato , 101) end [end-date],
	e.Nombre [first-name],
	CONCAT(e.Paterno,' ',e.Materno) [last-name],
	e.SegundoNombre [middle-name],
	'' [salutation],
	'' [suffix],
	case e.Sexo  when  'FEMENINO' then 'F'  when 'MASCULINO' then 'M' Else 'N' end  [gender],
	e.EstadoCivil [marital-status],
	'Spanish' [native-preferred-lang],
	e.Nombre [preferred-name],
	e.NOMBRECOMPLETO [formal-name],
	'' [Operation]
	FROM RH.tblEmpleadosMaster as e 


END
GO

USE [p_adagioRHANS]
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
CREATE PROCEDURE [SAP].[MX_BasicUserInfoImport]
	-- Add the parameters for the stored procedure here	
AS
BEGIN
        
	 

	select 
      
		case when isnull(e.Vigente,0) = 0 then 'inactive' else 'active' end [STATUS],
		isnull(dd.Valor,e.ClaveEmpleado) as  [USERID],
        COALESCE(REPLACE(case when isnull(ce.Value,'') != '' then (ce.Value) else u.Email end,'@carhartt.com',''),'') [UserName],
        Utilerias.fnEliminarAcentos(COALESCE(e.Nombre,'') )[FIRTNAME],
		Utilerias.fnEliminarAcentos(CONCAT(e.Paterno,' ',e.Materno) )[last-name],
		'' [middle-name],
        
        case when  e.Sexo is null or e.Sexo='' then  ''
             when e.Sexo='MASCULINO' then 'M'
             when e.Sexo='FEMENINO' then 'F' end [gender],

		case when isnull(ce.Value,'') != '' then (ce.Value) else u.Email end [email],
		isnull(dd2.Valor, 'NO_MANAGER') as [MANAGER],
		'NO_HR' [HR],
        case when e.Departamento ='RECURSOS HUMANOS' then 'FULHR' else 'WAGES' end  [DIVISION],        
        Utilerias.fnEliminarAcentos(COALESCE(de.Codigo,'')) [DEPARTMENT],
		'QRO' [LOCATION],
		'' [JOBCODE],
		'CST' as [TIMEZONE],				
        '' [HIREDATE],
        '' [EMPID],
		peng.Descripcion [TITLE],
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
		'es_MX' [DEFAULT_LOCALE],
		'' [PROXY],
		'' [CUSTOM_MANAGER],
		'' as [SECOND_MANAGER],
		'' [PAYGRADE],
		'' [ONBOARDING_ID]
		from rh.tblEmpleadosMaster as e 
			left join RH.tblContactoEmpleado ce with (nolock) on ce.IDEmpleado = e.IDEmpleado and ce.[Value] like '%carhartt%'
			left join rh.tblCatTipoContactoEmpleado tce with (nolock) on ce.IDTipoContactoEmpleado = tce.IDTipoContacto and tce.Descripcion  like '%EMAIL%' 
			LEFT join Seguridad.tblUsuarios u on u.IDEmpleado=e.IDEmpleado	
            left join rh.tblCatDepartamentos de on de.IDDepartamento=e.IDDepartamento
			LEFT JOIN SAP.tblCatPuestosEng peng on peng.IDPuesto=e.IDPuesto
            left join rh.tblDatosExtraEmpleados dd on dd.IDEmpleado=e.IDEmpleado and dd.IDDatoExtra=5
            left join rh.tblDatosExtraEmpleados dd2 on dd2.IDEmpleado=e.IDEmpleado and dd2.IDDatoExtra=6
        where e.Vigente=1
END
GO

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

CREATE PROCEDURE [SAP].[MX_JobInfoImport]
	-- Add the parameters for the stored procedure here	
AS
BEGIN

    -- CAMBIO PARA OBTENER SOLAMENTE LOS CLIENTES DE RUGGEDTECH -- 28 JULIO 2023
    declare @IDClienteRuggedtech  INT  ;
    set @IDClienteRuggedtech =1;      
	/*declare @tempJefesEmpleado as table (
		IDEmpleado int,
		IDJefe int,
		ClaveJefe varchar(20),
		RN int
	);

	insert @tempJefesEmpleado(IDEmpleado, IDJefe, ClaveJefe, RN)
	select 
		je.IDEmpleado,
		je.IDJefe,
		e.ClaveEmpleado as ClaveJefe,
		ROW_NUMBER()OVER(partition by je.IDEmpleado order by je.FechaReg) as RN
	from [RH].[tblJefesEmpleados] je
		join [RH].[tblEmpleadosMaster] e on e.IDEmpleado = je.IDJefe
    */

    select * From (
        select             
            isnull(dd.Valor,e.ClaveEmpleado) as [user-id]	,
            '' [custom-string1]	,
            '' [end-date]	,
            [custom-string2] = case when pp.Descripcion = 'Semanal' then 'MX-REG' else 'MX-CONF' end,
            ''[custom-string3]	,
            e.ClaveEmpleado as [custom-string5]	,
            'MEX' as [custom-string10]	,
            convert(varchar, e.FechaAntiguedad , 101) [start-date]	,
            '' as [job-title]	,
            '699999' as [job-code]	,
            'DFLT' [department]	,
            'DFLT' [division]	,
            'QRO' [location]	,
            
            '3004' [company]	,
            --''[notes]	,
            'DFLT' [business-unit]	,
            cc.CuentaContable [cost-center]	,
            'Associate' as [employee-class]	,        
            'Full-Time/Non-Union' as [employment-type]	,		
            '1' [fte]	,
            'Regular' [regular-temp]	,
            '45.5' as [standard-hours]	,
            '5'[workingDaysPerWeek]	,
            isnull(positionCode.Valor,'799999') [position]	,
            JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('enus', '-','')), 'Descripcion'))  [local-job-title]	,
            'Y' [is-fulltime-employee]	,
            payGrade.Valor [pay-grade]	,
            'Y'[is-shift-employee]	,
            'First Shift' as [shift-code]	,
            '1'[seq-number]	,
            'NO_MANAGER' as [manager-id]	,		
            'CST' [timezone]	,
            'HIRE' [event-reason]	,
            '' [notice-period]	,
            '' [flsa-status]	,
            '' [contract-type]	,
            '' [eeo-class]	,
            '' [work-location]	,
            '' [labor-Protection]	,
            '' [probation-period-end-date]	,
            '' [operation]
        from [RH].[tblEmpleadosMaster] e
            join [RH].[tblPuestoEmpleado] pe on pe.IDEmpleado = e.IDEmpleado and pe.FechaFin='9999-12-31'
            join [RH].[tblCatPuestos] p on p.IDPuesto = pe.IDPuesto
            JOIN RH.tblCatCentroCosto cc on cc.IDCentroCosto=e.IDCentroCosto            
            left join app.tblValoresDatosExtras positionCode on   positionCode.IDDatoExtra= 5  and positionCode.IDReferencia=e.IDPuesto-- POSITION CODE
            left join app.tblValoresDatosExtras payGrade on  payGrade.IDDatoExtra= 1  and payGrade.IDReferencia=e.IDPuesto -- PAYGRADE            
            -- left join sap.tblCatPuestosEng pee on pee.IDPuesto=p.IDPuesto            
            left join Nomina.tblCatTipoNomina tn on tn.IDTipoNomina = e.IDTipoNomina
            left join Sat.tblCatPeriodicidadesPago pp on pp.IDPeriodicidadPago = tn.IDPeriodicidadPago
            left join rh.tblDatosExtraEmpleados dd on dd.IDEmpleado=e.IDEmpleado and dd.IDDatoExtra=5
            where e.Vigente=1 and e.IDCliente =@IDClienteRuggedtech 
        union all
            select             
            isnull(dd.Valor,e.ClaveEmpleado) as [user-id]	,
            '' [custom-string1]	,
            '' [end-date]	,
            [custom-string2] = case when pp.Descripcion = 'Semanal' then 'MX-REG' else 'MX-CONF' end,
            ''[custom-string3]	,
            e.ClaveEmpleado as [custom-string5]	,
            'DFLT' as [custom-string10]	,
            convert(varchar, getdate() , 101) [start-date]	,
            '' as [job-title]	,
            isnull(jobCode.Valor, '699999') as [job-code]	,
            Utilerias.fnEliminarAcentos(de.Codigo) [department]	,
            case when e.Departamento ='RECURSOS HUMANOS' then 'FULHR' else 'WAGES' end  [division],
            'QRO' [location]	,
            
            '3004' [company]	,
            --''[notes]	,
            case when e.Departamento ='RECURSOS HUMANOS' then 'HMRES' 
             when e.Departamento ='Contabilidad' then 'ACCTG' else 'INFSV' end  [business-unit]	,
          
            cc.CuentaContable [cost-center]	,
            'Associate' as [employee-class]	,        
            'Full-Time/Non-Union' as [employment-type]	,		
            '1' [fte]	,
            'Regular' [regular-temp]	,
            '45.5' as [standard-hours]	,
            '5'[workingDaysPerWeek]	,
            isnull(positionCode.[Valor],'799999') [position]	,
            JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('enus', '-','')), 'Descripcion'))  [local-job-title]	,
            'Y' [is-fulltime-employee]	,
            band.[Valor] [pay-grade]	,
            'Y'[is-shift-employee]	,
            'First Shift' as [shift-code]	,
            '2'[seq-number]	,
            isnull(de2.Valor, 'NO_MANAGER') as [manager-id]	,		
            'CST' [timezone]	,
            'CURRACTIVE' [event-reason]	,
            '' [notice-period]	,
            '' [flsa-status]	,
            '' [contract-type]	,
            '' [eeo-class]	,
            '' [work-location]	,
            '' [labor-Protection]	,
            '' [probation-period-end-date]	,
            '' [operation]
        from [RH].[tblEmpleadosMaster] e
            join [RH].[tblPuestoEmpleado] pe on pe.IDEmpleado = e.IDEmpleado and pe.FechaFin='9999-12-31'
            join [RH].[tblCatPuestos] p on p.IDPuesto = pe.IDPuesto
            JOIN RH.tblCatCentroCosto cc on cc.IDCentroCosto=e.IDCentroCosto
            left join rh.tblCatDepartamentos de on de.IDDepartamento=e.IDDepartamento
            left join app.tblValoresDatosExtras positionCode on   positionCode.IDDatoExtra= 5  and positionCode.IDReferencia=e.IDPuesto-- POSITION NUMBER
            left join app.tblValoresDatosExtras band on  band.IDDatoExtra= 1  and band.IDReferencia=e.IDPuesto -- BAND            
            left join app.tblValoresDatosExtras jobCode on  jobCode.IDDatoExtra= 4  and jobCode.IDReferencia=e.IDPuesto -- JOB  CLASSS             
            -- left join sap.tblCatPuestosEng pee on pee.IDPuesto=p.IDPuesto            
            left join Nomina.tblCatTipoNomina tn on tn.IDTipoNomina = e.IDTipoNomina
            left join Sat.tblCatPeriodicidadesPago pp on pp.IDPeriodicidadPago = tn.IDPeriodicidadPago
            left join rh.tblDatosExtraEmpleados dd on dd.IDEmpleado=e.IDEmpleado and dd.IDDatoExtra=5
            left join rh.tblDatosExtraEmpleados de2 on de2.IDEmpleado=e.IDEmpleado and de2.IDDatoExtra=6
            where e.Vigente=1 and e.IDCliente =@IDClienteRuggedtech 
    ) as tabla 
    
    order by [user-id] , [seq-number]
END
GO

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

CREATE PROCEDURE [PERCEPTYX].[SPEmployees_01]
	-- Add the parameters for the stored procedure here	
AS
BEGIN

    -- CAMBIO PARA OBTENER SOLAMENTE LOS CLIENTES DE RUGGEDTECH -- 28 JULIO 2023
    declare @IDClienteRuggedtech  INT  ;
    set @IDClienteRuggedtech = 1;
    

	
    DECLARE 
    @empleados [RH].[dtEmpleados]   


    insert into @empleados                  
    Select * from RH.tblEmpleadosMaster


	DECLARE 		
    @IDTipoContactoEmail int,
    @IDActiveConcur int,
    @IDSupervisorConcur int ,
    @IDEmployee int,
    @IDSupervisorName int,
    @IDMovBaja int,
    @IDTipoContactoTelefono int,
    @IDTipoContactoTelefonoM int,
    @IDTipoContactoTelefonoC int  
	;

     
  


    Set @IDTipoContactoEmail = (Select IDTipoContacto from rh.tblCatTipoContactoEmpleado where Descripcion = 'EMAIL CORPORATIVO')
    Set @IDTipoContactoTelefono = (Select IDTipoContacto from rh.tblCatTipoContactoEmpleado where Descripcion = 'TELÉFONO')
    Set @IDTipoContactoTelefonoM = (Select IDTipoContacto from rh.tblCatTipoContactoEmpleado where Descripcion = 'TELÉFONO MOVIL')
    Set @IDTipoContactoTelefonoC = (Select IDTipoContacto from rh.tblCatTipoContactoEmpleado where Descripcion = 'TELEFONO CASA')
    Set @IDActiveConcur = (select IDDatoExtra from rh.tblCatDatosExtra where Nombre = 'CONCURACTIVE')
    Set @IDSupervisorConcur = (select IDDatoExtra from rh.tblCatDatosExtra where Nombre = 'SUPERVISORID')
    set @IDEmployee = (select IDDatoExtra from rh.tblCatDatosExtra where Nombre = 'SUCCESSFACTORID')
    set @IDSupervisorName = (select IDDatoExtra from rh.tblCatDatosExtra where Nombre = 'SUPERVISOR_NAME')
    set @IDMovBaja = (Select IDTipoMovimiento from IMSS.tblCatTipoMovimientos where Descripcion = 'BAJA')
   


   
    select     
         Isnull(employee.Valor,'') as [SSO ID]
        ,Isnull(employee.Valor,'') as HRID
        ,Utilerias.fnEliminarAcentos(ISNULL(e.Nombre,'')) as [FIRST NAME]
        ,Utilerias.fnEliminarAcentos(ISNULL(e.Paterno + COALESCE(' ' + e.Materno,''),'')) as [LAST NAME]
        ,ISNULL(ce.[Value],'') as EMAIL
        ,SAP.fnFormatUserName(isnull(ce.Value,'')) as [USERNAME]
        ,convert(varchar, e.FechaAntiguedad , 101) as [DATE OF HIRE]
        ,convert(varchar, e.FechaNacimiento , 101) as [DATE OF BIRTH]
        ,'0' as [OVERALL_RATING]
        ,'0' as [COMPETENCY_RATING]
        ,'0' as [GOAL_RATING]
        ,ISNULL(supervisor.Valor,'') as [SUPERVISOR ID]
        ,ISNULL(supervisorName.Valor,ISNULL(eCH.Nombre + COALESCE(' ' + eCH.Paterno,''),'')) as [SUPERVISOR NAME]
        ,ISNULL(e.Departamento,'') as DEPARTMENT
        ,'Mexico' as COUNTRY
        ,'Santiago de Queretaro' as [LOCATION]
        ,ISNULL(SUBSTRING(e.Sexo,1,1),'') as GENDER
        ,'' as [ETHNIC ID]
        ,ISNULL( case 
                    when e.EstadoCivil = 'CASADO (A)' then 'M' 
                    when e.EstadoCivil = 'SOLTERO (A)' then 'S' 
                    when e.EstadoCivil = 'VIUDO (A)' then 'W'
                    when e.EstadoCivil = 'DIVORCIADO (A)' then 'D'
                    end,'') as [MARITAL STATUS]

        ,UPPER(JSON_VALUE(p.Traduccion, FORMATMESSAGE('$.%s.%s', lower(replace('enus', '-','')), 'Descripcion')))  [TITLE]
        ,'A' as [PAY TYPE]
        ,'NU' as [UNION/NU]
        ,'FT' [FT/PT]
        ,Case when e.Vigente = 0 then convert(varchar, movBajas.fecha , 101) else '' end as [TERM DATE]
        ,Case when e.Vigente = 0 then Case  when movBajas.IDRazonMovimiento = 2  Then 'Voluntary Resignation' 
                                            when movBajas.IDRazonMovimiento = 3  Then 'Termination Due to Absences' 
                                            when movBajas.IDRazonMovimiento = 5  Then 'End of Contract' 
                                            when movBajas.IDRazonMovimiento = 6  Then 'Voluntary Separation' 
                                            when movBajas.IDRazonMovimiento = 7  Then 'Job Abandonment' 
                                            when movBajas.IDRazonMovimiento = 8  Then 'Death' 
                                            when movBajas.IDRazonMovimiento = 9  Then 'Closure' 
                                            when movBajas.IDRazonMovimiento = 10 Then 'Other' 
                                            when movBajas.IDRazonMovimiento = 11 Then 'Absenteeism' 
                                            when movBajas.IDRazonMovimiento = 12 Then 'Contract Termination' 
                                            when movBajas.IDRazonMovimiento = 13 Then 'Retirement' 
                                            when movBajas.IDRazonMovimiento = 14 Then 'Pension' 
                                        END else '' end as [TERM REASON]
        ,coalesce(ceCH.[Value],cej.[Value],ceCHX.[value],'') as [SUPERVISOR EMAIL]
        ,ISNULL(vx.Valor,'') as [JOB BAND]
        ,'' as [WORK CLASS]
        ,coalesce(cetel.[Value],ceTelM.[Value],ceTelC.[Value],'') as [HOME PHONE]


        
      
	FROM @empleados e 
     
     Left join rh.tblDatosExtraEmpleados supervisor on supervisor.IDEmpleado = e.IDEmpleado and supervisor.IDDatoExtra = @IDSupervisorConcur
     Left join rh.tblDatosExtraEmpleados supervisorName on supervisorName.IDEmpleado = e.IDEmpleado and supervisorName.IDDatoExtra = @IDSupervisorName
     Left join rh.tblContactoEmpleado ce on ce.IDEmpleado = e.IDEmpleado and ce.IDTipoContactoEmpleado = @IDTipoContactoEmail and ce.Predeterminado = 1
     left join rh.tblContactoEmpleado ceTel on ceTel.IDEmpleado = e.IDEmpleado and ceTel.IDTipoContactoEmpleado = @IDTipoContactoTelefono 
     left join rh.tblContactoEmpleado ceTelM on ceTelM.IDEmpleado = e.IDEmpleado and ceTelM.IDTipoContactoEmpleado = @IDTipoContactoTelefonoM 
     left join rh.tblContactoEmpleado ceTelC on ceTelC.IDEmpleado = e.IDEmpleado and ceTelC.IDTipoContactoEmpleado = @IDTipoContactoTelefonoC 
     Left join rh.tblDatosExtraEmpleados employee on employee.IDEmpleado = e.IDEmpleado and employee.IDDatoExtra = @IDEmployee
     Left join rh.tblCentroCostoEmpleado cce on cce.IDEmpleado = e.IDEmpleado
     Left join rh.tblCatCentroCosto cc on cce.IDCentroCosto = cc.IDCentroCosto
     Left join rh.tblPuestoEmpleado pe on pe.IDEmpleado = e.IDEmpleado and pe.FechaFin = '9999-12-31'
     Left join rh.tblCatPuestos p on pe.IDPuesto = p.IDPuesto
     left join app.tblValoresDatosExtras vx on vx.IDReferencia = p.IDPuesto and vx.IDDatoExtra = 1
     left join @empleados eCH on eCH.ClaveEmpleado = supervisor.Valor 
     left join rh.tblContactoEmpleado ceCH on eCH.IDEmpleado = ceCH.IDEmpleado and ceCH.IDTipoContactoEmpleado = @IDTipoContactoEmail and ceCh.Predeterminado = 1
     left join rh.tblJefesEmpleados je on je.IDEmpleado = e.IDEmpleado 
     left join rh.tblContactoEmpleado cej on cej.IDEmpleado = je.IDJefe and cej.IDTipoContactoEmpleado = @IDTipoContactoEmail and cej.Predeterminado = 1
     left join ( Select Fecha,IDEmpleado,IDRazonMovimiento, ROW_NUMBER()Over(Partition by IDEmpleado order by Fecha desc) as RN from IMSS.tblMovAfiliatorios where IDTipoMovimiento = 2 )  movBajas on movBajas.IDEmpleado = e.IDEmpleado and RN = 1
     left join ( Select e.IDEmpleado,ex2.IDEmpleado as IDJefe
                 from Rh.tblEmpleadosMaster e
                 left join rh.tblDatosExtraEmpleados ex on e.IDEmpleado = ex.IDEmpleado and ex.IDDatoExtra = @IDSupervisorConcur
                 left join rh.tblDatosExtraEmpleados ex2 on ex.Valor = ex2.Valor and ex2.IDDatoExtra = @IDEmployee ) mxJefes on mxJefes.IDEmpleado = e.IDEmpleado
    left join rh.tblContactoEmpleado ceCHX on ceCHX.idempleado = mxJefes.IDJefe and ceCHX.IDTipoContactoEmpleado = @IDTipoContactoEmail and ceCHX.Predeterminado = 1
    Where e.IDCliente = 1 

    


END
GO
